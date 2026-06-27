import { NextRequest, NextResponse } from "next/server";
import { prisma } from "@/lib/db";
import { getSessionStudent } from "@/lib/student";
import { explainAnswer } from "@/lib/ai";
import { getLang } from "@/lib/lang-server";
import type { McqOption } from "@/lib/types";

export const maxDuration = 60;

// Returns a short "why is this the answer" explanation for a question.
// Generated once via AI and cached on the Question row, so every student after
// the first reads it for free.
export async function POST(req: NextRequest, { params }: { params: Promise<{ id: string }> }) {
  const student = await getSessionStudent();
  if (!student) return NextResponse.json({ error: "Not signed in" }, { status: 401 });
  const { id } = await params;

  const q = await prisma.question.findUnique({
    where: { id },
    include: { subject: { select: { name: true } } },
  });
  if (!q || q.status !== "approved") return NextResponse.json({ error: "Not found" }, { status: 404 });

  // Cached already → return immediately.
  if (q.explanation && q.explanation.trim()) {
    return NextResponse.json({ explanation: q.explanation, cached: true });
  }

  const lang = await getLang();
  const { text, byAi } = await explainAnswer({
    stem: q.stem,
    options: JSON.parse(q.options || "[]") as McqOption[],
    answer: q.answer,
    markingScheme: q.markingScheme,
    subjectName: q.subject.name,
    lang,
  });

  if (!text) {
    return NextResponse.json(
      { explanation: "", error: "AI is offline right now. Try again later." },
      { status: 503 },
    );
  }

  // Persist so it's reused for everyone (best-effort).
  if (byAi) {
    try {
      await prisma.question.update({ where: { id }, data: { explanation: text } });
    } catch {
      /* cache write is best-effort */
    }
  }
  return NextResponse.json({ explanation: text, cached: false });
}
