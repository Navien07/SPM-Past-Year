import Anthropic from "@anthropic-ai/sdk";
import { bandForPercent } from "./constants";
import type {
  CategorizationResult,
  GeneratedItem,
  GradeResult,
  McqOption,
  TutorRecommendation,
} from "./types";

const MODEL = process.env.SPM_AI_MODEL || "claude-sonnet-4-6";

export function aiEnabled(): boolean {
  return !!process.env.ANTHROPIC_API_KEY;
}

let _client: Anthropic | null = null;
function client(): Anthropic {
  if (!_client) _client = new Anthropic();
  return _client;
}

/**
 * Call Claude and parse a JSON object/array out of the response.
 * Uses adaptive thinking for these reasoning-heavy tasks. Robust to the model
 * wrapping JSON in prose or code fences.
 */
async function callClaudeJson<T>(system: string, user: string): Promise<T> {
  const res = await client().messages.create({
    model: MODEL,
    max_tokens: 16000,
    thinking: { type: "adaptive" },
    system,
    messages: [{ role: "user", content: user }],
  } as Anthropic.MessageCreateParamsNonStreaming);

  const text = res.content
    .filter((b): b is Anthropic.TextBlock => b.type === "text")
    .map((b) => b.text)
    .join("\n")
    .trim();

  return extractJson<T>(text);
}

function extractJson<T>(text: string): T {
  let s = text.trim();
  // Strip ```json ... ``` fences if present.
  const fence = s.match(/```(?:json)?\s*([\s\S]*?)```/i);
  if (fence) s = fence[1].trim();
  try {
    return JSON.parse(s) as T;
  } catch {
    // Fall back to the first balanced { } or [ ] span.
    const start = s.search(/[{[]/);
    const lastObj = s.lastIndexOf("}");
    const lastArr = s.lastIndexOf("]");
    const end = Math.max(lastObj, lastArr);
    if (start >= 0 && end > start) {
      return JSON.parse(s.slice(start, end + 1)) as T;
    }
    throw new Error("Could not parse JSON from model response");
  }
}

// ── Module 2: categorization agent ────────────────────────────────────────

export interface CategorizeInput {
  subjectName: string;
  paperType: string;
  year: number;
  state?: string | null;
  paperNumber: number;
  rawText: string;
  markingScheme?: string | null;
}

export async function categorizePaper(
  input: CategorizeInput,
): Promise<{ result: CategorizationResult; byAi: boolean }> {
  if (!aiEnabled()) return { result: mockCategorize(input), byAi: false };

  const system = `You are an expert Malaysian SPM examiner and curriculum mapper.
You receive the raw text of one exam paper and split it into individual questions,
then tag each question against the KSSM syllabus.

For EACH question, determine:
- questionType: "mcq" (objective with options), "structured" (short subjective), or "essay"
- stem: the full question text (clean, no leading number)
- options: for mcq, an array of {key,text} (A/B/C/D); otherwise []
- answer: correct option key for mcq, or a concise model answer otherwise (use the marking scheme if provided)
- markingScheme: marking notes for structured/essay
- marks: marks allocated (integer)
- isKbat: true if it is a higher-order-thinking (KBAT/HOTS) question
- form: 4 or 5 (best estimate of which form the topic belongs to)
- chapter: chapter number (best estimate)
- chapterTitle: chapter/topic title in the subject's language
- subtopic: a specific subtopic label
- confidence: a number from 0 to 1 — how certain you are about the subject, form and topic
  tagging for THIS question. Use 0.9+ only when you are very sure; use lower values when the
  topic is ambiguous or the question could belong to multiple chapters.

Return ONLY JSON: {"questions":[ ... ]}. No prose.`;

  const user = `Subject: ${input.subjectName}
Paper type: ${input.paperType}
Year: ${input.year}${input.state ? `\nState/Body: ${input.state}` : ""}
Paper number: ${input.paperNumber}
${input.markingScheme ? `\nMARKING SCHEME:\n${input.markingScheme}\n` : ""}
PAPER TEXT:
${input.rawText}`;

  try {
    const result = await callClaudeJson<CategorizationResult>(system, user);
    if (!result?.questions?.length) return { result: mockCategorize(input), byAi: false };
    return { result, byAi: true };
  } catch {
    return { result: mockCategorize(input), byAi: false };
  }
}

// ── Module 4/5: grading agent ─────────────────────────────────────────────

export interface GradeInput {
  questionType: string;
  stem: string;
  options?: McqOption[];
  answer?: string | null; // correct key / model answer
  markingScheme?: string | null;
  rubric?: string | null; // JSON rubric string
  marks: number;
  studentAnswer: string;
  subjectName: string;
}

export async function gradeAnswer(
  input: GradeInput,
): Promise<{ result: GradeResult; byAi: boolean }> {
  // MCQ is graded deterministically — no model needed.
  if (input.questionType === "mcq") {
    const correct =
      !!input.answer &&
      input.studentAnswer.trim().toUpperCase().startsWith(input.answer.trim().toUpperCase());
    const score = correct ? input.marks : 0;
    return {
      result: {
        score,
        maxScore: input.marks,
        band: bandForPercent(correct ? 100 : 0),
        isCorrect: correct,
        summary: correct
          ? "Correct answer."
          : `Incorrect. The correct answer is ${input.answer ?? "—"}.`,
        strengths: correct ? ["Selected the right option."] : [],
        improvements: correct ? [] : ["Review this subtopic and the reasoning behind the key."],
        criteria: [],
        modelAnswer: input.answer ?? undefined,
      },
      byAi: false,
    };
  }

  if (!aiEnabled()) return { result: mockGrade(input), byAi: false };

  const system = `You are a strict but fair Malaysian SPM examiner grading a written answer
against the official marking scheme / rubric. Award marks per criterion, never exceed the max.
Give specific, actionable feedback. Be encouraging but honest.

Return ONLY JSON of this shape:
{
  "score": number, "maxScore": number, "band": string,
  "summary": string,
  "strengths": string[], "improvements": string[],
  "criteria": [{"name": string, "awarded": number, "max": number, "comment": string}],
  "modelAnswer": string
}`;

  const user = `Subject: ${input.subjectName}
Question (${input.questionType}, ${input.marks} marks):
${input.stem}

${input.markingScheme ? `MARKING SCHEME:\n${input.markingScheme}\n` : ""}${
    input.rubric ? `RUBRIC (JSON):\n${input.rubric}\n` : ""
  }${input.answer ? `MODEL ANSWER:\n${input.answer}\n` : ""}
STUDENT ANSWER:
${input.studentAnswer}

Grade it now.`;

  try {
    const result = await callClaudeJson<GradeResult>(system, user);
    // Clamp + ensure consistency.
    result.maxScore = input.marks;
    result.score = Math.max(0, Math.min(input.marks, Number(result.score) || 0));
    if (!result.band) result.band = bandForPercent((result.score / input.marks) * 100);
    return { result, byAi: true };
  } catch {
    return { result: mockGrade(input), byAi: false };
  }
}

// ── Module 5: tutor agent ─────────────────────────────────────────────────

export interface TutorInput {
  studentName: string;
  perTopic: {
    subject: string;
    topic: string;
    attempts: number;
    avgPercent: number;
  }[];
}

export async function tutorRecommend(
  input: TutorInput,
): Promise<{ result: TutorRecommendation; byAi: boolean }> {
  if (!aiEnabled() || input.perTopic.length === 0) {
    return { result: mockTutor(input), byAi: false };
  }

  const system = `You are an encouraging Malaysian SPM tutor. Given a student's performance
per topic, identify weak subjects and topics, and produce a concrete focus plan.
Return ONLY JSON:
{
  "overview": string,
  "weakSubjects": [{"subject": string, "reason": string, "priority": number}],
  "weakTopics": [{"subject": string, "topic": string, "reason": string}],
  "focusPlan": [{"step": string, "detail": string}],
  "motivational": string
}`;

  const user = `Student: ${input.studentName}
Performance per topic (avgPercent is the average score %):
${JSON.stringify(input.perTopic, null, 2)}`;

  try {
    const result = await callClaudeJson<TutorRecommendation>(system, user);
    return { result, byAi: true };
  } catch {
    return { result: mockTutor(input), byAi: false };
  }
}

// ── Module 5: generator agent ─────────────────────────────────────────────

export interface GenerateInput {
  subjectName: string;
  topicTitle: string;
  form: number;
  questionType: string;
  count: number;
  kbat: boolean;
  examples: string[]; // stems of real past-paper questions to mimic the pattern
}

export async function generateQuestions(
  input: GenerateInput,
): Promise<{ result: GeneratedItem[]; byAi: boolean }> {
  if (!aiEnabled()) return { result: mockGenerate(input), byAi: false };

  const system = `You are an SPM question writer. Produce NEW practice questions in the
authentic style and difficulty of SPM past papers for the given topic. Match the format
of the provided examples. ${input.kbat ? "These MUST be KBAT (higher-order-thinking) questions." : ""}
For mcq, include 4 options {key,text} and the correct answer key. For structured/essay,
include a marking scheme and a model answer.
Return ONLY JSON: an array of
{"questionType": string, "stem": string, "options": [{"key","text"}], "answer": string,
 "markingScheme": string, "marks": number, "isKbat": boolean, "basedOn": string}`;

  const user = `Subject: ${input.subjectName}
Topic: ${input.topicTitle} (Form ${input.form})
Type: ${input.questionType}
Number to generate: ${input.count}
KBAT: ${input.kbat}

Examples of real past-paper questions on this topic (mimic their pattern, do not copy):
${input.examples.map((e, i) => `${i + 1}. ${e}`).join("\n") || "(none provided)"}`;

  try {
    const result = await callClaudeJson<GeneratedItem[]>(system, user);
    if (!Array.isArray(result) || result.length === 0) {
      return { result: mockGenerate(input), byAi: false };
    }
    return { result, byAi: true };
  } catch {
    return { result: mockGenerate(input), byAi: false };
  }
}

// ── AI chat (context-aware tutor, with screenshot/vision) ─────────────────

export interface ChatImage {
  mediaType: string; // e.g. "image/png"
  dataBase64: string; // base64 without the data: prefix
}
export interface ChatTurn {
  role: "user" | "assistant";
  text: string;
  images?: ChatImage[];
}
export interface ChatInput {
  history: ChatTurn[];
  context?: string; // app/page/question context, injected into the system prompt
}

export async function chatAnswer(
  input: ChatInput,
): Promise<{ reply: string; byAi: boolean }> {
  const hasImage = input.history.some((t) => (t.images?.length ?? 0) > 0);

  if (!aiEnabled()) {
    return { reply: mockChat(input, hasImage), byAi: false };
  }

  const system = `You are "Cikgu AI", a warm, encouraging Malaysian SPM tutor inside an SPM
revision app. Help students understand topics, exam questions, and marking schemes.
- Reply in the language the student uses (Bahasa Melayu or English); mirror their mix.
- Be clear and concise; use steps, bullet points and worked examples where helpful.
- For exam answers, show how to score marks against the SPM marking scheme / KBAT expectations.
- When the student attaches a screenshot or image, read it carefully and base your answer on it.
- If you are unsure, say so and suggest what to check. Never invent facts.
- You may be given REFERENCE NOTES from the school's knowledge base. Use them to ground your
  explanation, but teach the concept in your own words — explain and summarise, do not copy
  long passages verbatim.
${input.context ? `\nCURRENT CONTEXT:\n${input.context}` : ""}`;

  const messages: Anthropic.MessageParam[] = input.history.map((t) => {
    if (t.role === "user" && t.images?.length) {
      const blocks: Anthropic.ContentBlockParam[] = t.images.map((img) => ({
        type: "image",
        source: {
          type: "base64",
          media_type: img.mediaType as "image/png" | "image/jpeg" | "image/gif" | "image/webp",
          data: img.dataBase64,
        },
      }));
      blocks.push({ type: "text", text: t.text || "Tolong terangkan imej ini." });
      return { role: "user", content: blocks };
    }
    return { role: t.role, content: t.text };
  });

  try {
    const res = await client().messages.create({
      model: MODEL,
      max_tokens: 4096,
      thinking: { type: "adaptive" },
      system,
      messages,
    } as Anthropic.MessageCreateParamsNonStreaming);

    const reply = res.content
      .filter((b): b is Anthropic.TextBlock => b.type === "text")
      .map((b) => b.text)
      .join("\n")
      .trim();
    return { reply: reply || "(no response)", byAi: true };
  } catch (e) {
    return {
      reply:
        "Maaf, AI chat tidak dapat dihubungi sekarang. " +
        (e instanceof Error ? e.message : "Sila cuba lagi."),
      byAi: false,
    };
  }
}

function mockChat(input: ChatInput, hasImage: boolean): string {
  const last = [...input.history].reverse().find((t) => t.role === "user");
  return [
    "🔌 **AI chat is in offline mode** (no `ANTHROPIC_API_KEY` set).",
    "",
    hasImage
      ? "I can see you attached a screenshot — with a connected Anthropic API key I'd read it and explain it in detail."
      : "With a connected Anthropic API key I'd give a full, context-aware explanation here.",
    last?.text ? `\nYou asked: _"${last.text.slice(0, 200)}"_` : "",
    "",
    "In the meantime: break the question into what it's *asking*, recall the key syllabus facts for that topic, then structure your answer to match the marking scheme.",
  ]
    .filter(Boolean)
    .join("\n");
}

// ── Deterministic offline fallbacks (no API key) ──────────────────────────
// These keep the whole app demonstrable without a key, and clearly flag
// themselves as offline so real grading is never silently faked.

function mockCategorize(input: CategorizeInput): CategorizationResult {
  // Split the raw text into numbered chunks heuristically.
  const blocks = input.rawText
    .split(/\n(?=\s*\d{1,2}[.)]\s)/)
    .map((b) => b.trim())
    .filter((b) => b.length > 8);

  const chunks = blocks.length ? blocks : [input.rawText.trim()].filter(Boolean);

  return {
    questions: chunks.slice(0, 30).map((chunk, i) => {
      const isMcq = /\n\s*[A-D][.)]\s/.test(chunk);
      const stem = chunk.replace(/^\s*\d{1,2}[.)]\s*/, "").trim();
      // Offline confidence heuristic: longer/clearer stems → more confident;
      // mix in some lower values so the moderator queue is exercised.
      const confidence = Math.max(0.5, Math.min(0.97, 0.6 + (stem.length % 40) / 100 + (isMcq ? 0.2 : 0)));
      return {
        number: String(i + 1),
        questionType: isMcq ? "mcq" : stem.length > 160 ? "essay" : "structured",
        stem: stem.slice(0, 600),
        options: isMcq
          ? ["A", "B", "C", "D"].map((key) => ({ key, text: `Pilihan ${key}` }))
          : [],
        answer: isMcq ? "A" : undefined,
        markingScheme: isMcq ? undefined : "Mark per valid point (offline placeholder).",
        marks: isMcq ? 1 : stem.length > 160 ? 10 : 4,
        isKbat: /mengapa|huraikan|cadangkan|analisis|why|explain|evaluate/i.test(stem),
        form: input.year % 2 === 0 ? 4 : 5,
        chapter: (i % 6) + 1,
        chapterTitle: `${input.subjectName} — Bab ${(i % 6) + 1}`,
        subtopic: "Umum",
        confidence: Math.round(confidence * 100) / 100,
      };
    }),
  };
}

function mockGrade(input: GradeInput): GradeResult {
  const len = input.studentAnswer.trim().split(/\s+/).filter(Boolean).length;
  // Crude proxy: longer, keyword-bearing answers score higher. Clearly offline.
  const ratio = Math.max(0.2, Math.min(1, len / Math.max(20, input.marks * 12)));
  const score = Math.round(input.marks * ratio);
  const pct = (score / input.marks) * 100;
  return {
    score,
    maxScore: input.marks,
    band: bandForPercent(pct),
    summary:
      "Offline estimate (no API key set). Connect an Anthropic API key for real rubric-based grading.",
    strengths: len > 10 ? ["Attempted with reasonable detail."] : ["Answer submitted."],
    improvements: [
      "Add more syllabus-specific facts and keywords.",
      "Structure the answer to match the marking scheme.",
    ],
    criteria: [
      { name: "Content / Isi", awarded: Math.round(score * 0.7), max: Math.round(input.marks * 0.7), comment: "Estimated." },
      { name: "Elaboration / Huraian", awarded: score - Math.round(score * 0.7), max: input.marks - Math.round(input.marks * 0.7), comment: "Estimated." },
    ],
    modelAnswer: input.answer ?? undefined,
  };
}

function mockTutor(input: TutorInput): TutorRecommendation {
  const sorted = [...input.perTopic].sort((a, b) => a.avgPercent - b.avgPercent);
  const weak = sorted.slice(0, 3);
  return {
    overview:
      input.perTopic.length === 0
        ? `Hi ${input.studentName}! Attempt a few questions and I'll map out exactly what to focus on.`
        : `Hi ${input.studentName}, based on ${input.perTopic.length} topic(s) you've practised, here's where to focus next.`,
    weakSubjects: weak.map((w, i) => ({
      subject: w.subject,
      reason: `Average ${Math.round(w.avgPercent)}% across ${w.attempts} attempt(s).`,
      priority: i + 1,
    })),
    weakTopics: weak.map((w) => ({
      subject: w.subject,
      topic: w.topic,
      reason: `Scoring ${Math.round(w.avgPercent)}% — revise core concepts and practise more KBAT items.`,
    })),
    focusPlan: weak.map((w, i) => ({
      step: `Step ${i + 1}: ${w.subject} — ${w.topic}`,
      detail: `Review notes, then attempt 5 generated KBAT questions on this topic.`,
    })),
    motivational: "Konsisten setiap hari — small daily practice beats last-minute cramming!",
  };
}

function mockGenerate(input: GenerateInput): GeneratedItem[] {
  return Array.from({ length: input.count }).map((_, i) => {
    if (input.questionType === "mcq") {
      return {
        questionType: "mcq",
        stem: `[Offline sample ${i + 1}] Berkaitan ${input.topicTitle}, manakah pernyataan yang BENAR?`,
        options: ["A", "B", "C", "D"].map((key) => ({ key, text: `Pilihan ${key}` })),
        answer: "A",
        marks: 1,
        isKbat: input.kbat,
        basedOn: "Offline placeholder — set an API key for AI-generated items.",
      };
    }
    return {
      questionType: input.questionType === "essay" ? "essay" : "structured",
      stem: `[Offline sample ${i + 1}] ${input.kbat ? "Analisis dan huraikan" : "Terangkan"} aspek penting dalam topik "${input.topicTitle}".`,
      markingScheme: "1 mark per relevant point (offline placeholder).",
      answer: "Model answer available with a connected API key.",
      marks: input.questionType === "essay" ? 10 : 4,
      isKbat: input.kbat,
      basedOn: "Offline placeholder — set an API key for AI-generated items.",
    };
  });
}
