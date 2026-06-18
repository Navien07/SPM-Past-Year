import { NextRequest, NextResponse } from "next/server";
import { prisma } from "@/lib/db";
import { chatAnswer, type ChatTurn } from "@/lib/ai";
import { retrieveKnowledge } from "@/lib/knowledge";
import { getSessionStudent } from "@/lib/student";
import { logActivity, clientIp } from "@/lib/activity";
import type { McqOption } from "@/lib/types";

export const maxDuration = 60;

// AI chat — context-aware tutor. The client sends the conversation (with any
// attached screenshots/images) plus light page context; if a questionId is
// present we hydrate the exact question so answers are grounded.
export async function POST(req: NextRequest) {
  const body = await req.json();
  const history = (body.history ?? []) as ChatTurn[];
  const { questionId, pathHint } = body as { questionId?: string; pathHint?: string };

  if (!Array.isArray(history) || history.length === 0) {
    return NextResponse.json({ error: "history is required" }, { status: 400 });
  }

  // Build context: current page + (if discussing a question) its full details.
  const parts: string[] = [];
  parts.push("App: SPM AI — a Malaysian SPM revision platform.");
  if (pathHint) parts.push(`Student is on page: ${pathHint}`);

  if (questionId) {
    const q = await prisma.question.findUnique({
      where: { id: questionId },
      include: { subject: true, topic: true },
    });
    if (q) {
      const opts = JSON.parse(q.options || "[]") as McqOption[];
      parts.push(
        [
          "The student is looking at this exam question:",
          `Subject: ${q.subject.name}`,
          q.topic ? `Topic: Tingkatan ${q.topic.form} · ${q.topic.title}` : "",
          `Type: ${q.questionType} · ${q.marks} marks${q.isKbat ? " · KBAT" : ""}`,
          `Question: ${q.stem}`,
          opts.length ? `Options:\n${opts.map((o) => `${o.key}. ${o.text}`).join("\n")}` : "",
          q.answer ? `Correct answer / model answer: ${q.answer}` : "",
          q.markingScheme ? `Marking scheme: ${q.markingScheme}` : "",
        ]
          .filter(Boolean)
          .join("\n"),
      );
    }
  }

  // Ground the answer in the admin knowledge base ("main brain"). Retrieve
  // bounded snippets relevant to the student's last message + current subject.
  const lastUser = [...history].reverse().find((t) => t.role !== "assistant");
  let subjectIdForKb: string | null = null;
  if (questionId) {
    const q = await prisma.question.findUnique({ where: { id: questionId }, select: { subjectId: true } });
    subjectIdForKb = q?.subjectId ?? null;
  }
  const refs = lastUser?.text
    ? await retrieveKnowledge(lastUser.text, { subjectId: subjectIdForKb }).catch(() => [])
    : [];
  if (refs.length) {
    parts.push(
      "REFERENCE NOTES (from the knowledge base — explain in your own words, do not copy verbatim):\n" +
        refs.map((r) => `• ${r.title}: ${r.snippet}`).join("\n\n"),
    );
  }

  // Cap images per turn defensively (vision payload size).
  const safeHistory: ChatTurn[] = history.slice(-12).map((t) => ({
    role: t.role === "assistant" ? "assistant" : "user",
    text: String(t.text ?? ""),
    images: (t.images ?? []).slice(0, 3),
  }));

  const { reply, byAi } = await chatAnswer({ history: safeHistory, context: parts.join("\n\n") });

  const student = await getSessionStudent();
  await logActivity({
    studentId: student?.id ?? null,
    name: student?.name ?? null,
    role: "student",
    action: "chat.message",
    detail: (lastUser?.text || "").slice(0, 120),
    path: pathHint,
    ip: clientIp(req),
  });

  return NextResponse.json({ reply, byAi, groundedOn: refs.map((r) => r.title) });
}
