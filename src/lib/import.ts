import { prisma } from "./db";
import { AUTO_APPROVE_THRESHOLD } from "./constants";

// ── Shared helpers for idempotent bulk import (papers, questions, textbooks) ──

export function normPaperType(t?: string): string {
  const s = (t || "").toLowerCase();
  if (s.includes("real") || s.includes("sebenar") || s === "past_year" || s === "spm") return "past_year";
  if (s.includes("mock")) return "mock";
  if (s.includes("state") || s.includes("negeri")) return "state";
  if (s === "trial" || s.includes("percubaan") || s.includes("trial")) return "trial";
  // MRSM / SBP / YIK etc. are bodies (go in `state`); default the type to trial.
  return "trial";
}

export function normType(t?: string): "mcq" | "structured" | "essay" {
  const s = (t || "").toLowerCase();
  if (s.startsWith("mcq") || s.includes("objektif") || s.includes("aneka")) return "mcq";
  if (s.includes("essay") || s.includes("esei") || s.includes("karangan")) return "essay";
  return "structured";
}

// Build subject lookup (code + name, case-insensitive) once per request.
export async function subjectResolver() {
  const subjects = await prisma.subject.findMany({ select: { id: true, code: true, name: true, nameEn: true } });
  const map = new Map<string, string>();
  for (const s of subjects) {
    map.set(s.code.toLowerCase(), s.id);
    map.set(s.name.toLowerCase(), s.id);
    if (s.nameEn) map.set(s.nameEn.toLowerCase(), s.id);
  }
  return (key?: string | null): string | null => {
    const k = String(key ?? "").toLowerCase().trim();
    return k ? map.get(k) ?? null : null;
  };
}

// Build a topic resolver for a subject: match by exact KSSM topic title, then by
// (form, chapter). Returns null when nothing matches (question stays untagged).
export async function topicResolver(subjectId: string) {
  const topics = await prisma.topic.findMany({
    where: { subjectId },
    select: { id: true, form: true, chapter: true, title: true },
  });
  const byTitle = new Map<string, string>();
  const byFormChapter = new Map<string, string>();
  for (const t of topics) {
    byTitle.set(t.title.toLowerCase(), t.id);
    byFormChapter.set(`${t.form}:${t.chapter}`, t.id);
  }
  return (opts: { topicTitle?: string | null; form?: number | null; chapter?: number | null }): string | null => {
    if (opts.topicTitle) {
      const hit = byTitle.get(String(opts.topicTitle).toLowerCase().trim());
      if (hit) return hit;
    }
    if (opts.form && opts.chapter) {
      const hit = byFormChapter.get(`${opts.form}:${opts.chapter}`);
      if (hit) return hit;
    }
    return null;
  };
}

export interface ParsedQuestion {
  number?: string;
  type?: string;
  stem?: string;
  options?: { key: string; text: string }[];
  answer?: string;
  markingScheme?: string;
  marks?: number;
  isKbat?: boolean;
  form?: number;
  chapter?: number;
  topicTitle?: string;
  subtopic?: string;
  confidence?: number;
}

// Validate a pre-parsed question. Returns the list of problems (empty = clean).
// Used both at import time (to decide approved vs pending) and by the QA view.
export function questionIssues(q: {
  questionType: string;
  stem: string;
  options: { key: string; text: string }[];
  answer: string | null;
  markingScheme?: string | null;
  marks: number;
  topicId?: string | null;
}): string[] {
  const issues: string[] = [];
  if (!q.stem || q.stem.trim().length < 5) issues.push("Empty/short stem");
  if (q.questionType === "mcq") {
    if (!q.options || q.options.length < 2) issues.push("MCQ has <2 options");
    if (!q.answer) issues.push("MCQ missing answer");
    else if (q.options?.length && !q.options.some((o) => o.key === q.answer)) issues.push("Answer key not among options");
  } else {
    if (!q.answer && !q.markingScheme) issues.push("No answer/marking scheme");
  }
  if (!q.marks || q.marks < 1) issues.push("Missing marks");
  if (q.topicId === null) issues.push("Not linked to a KSSM topic");
  return issues;
}

// Allow a question imported with a clean parse to go straight to students.
export function importStatus(issues: string[], confidence?: number): "approved" | "pending" {
  const blocking = issues.filter((i) => i !== "Not linked to a KSSM topic");
  if (blocking.length > 0) return "pending";
  if (confidence != null && confidence < AUTO_APPROVE_THRESHOLD) return "pending";
  return "approved";
}
