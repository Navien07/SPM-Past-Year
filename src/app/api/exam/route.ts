import { NextRequest, NextResponse } from "next/server";
import { prisma } from "@/lib/db";
import { getSessionStudent } from "@/lib/student";
import type { McqOption } from "@/lib/types";

export const maxDuration = 60;

// Assemble a timed exam: a spread of approved questions for a subject/paper.
// Returns full question payloads (incl. MCQ options) so the runner can present
// them all, then grade each via /api/attempts on submit.
export async function POST(req: NextRequest) {
  const student = await getSessionStudent();
  if (!student) return NextResponse.json({ error: "Not signed in as a student" }, { status: 401 });

  const { subjectId, paperNumber, count } = await req.json();
  if (!subjectId) return NextResponse.json({ error: "subjectId is required" }, { status: 400 });

  const pn = Number(paperNumber) || 1;
  const want = Math.min(Math.max(Number(count) || 10, 1), 40);

  const pool = await prisma.question.findMany({
    where: { subjectId, paperNumber: pn, status: "approved" },
    include: { topic: true },
  });
  if (pool.length === 0) {
    return NextResponse.json({ error: "No questions available for this subject/paper yet." }, { status: 400 });
  }

  // Shuffle, spread topics, take `want`.
  const shuffled = [...pool].sort(() => Math.random() - 0.5);
  const picked: typeof shuffled = [];
  const seen = new Set<string>();
  for (const q of shuffled) {
    if (picked.length >= want) break;
    const tk = q.topicId ?? "none";
    if (!seen.has(tk) || picked.length > pool.length / 2) {
      picked.push(q);
      seen.add(tk);
    }
  }
  for (const q of shuffled) {
    if (picked.length >= want) break;
    if (!picked.find((p) => p.id === q.id)) picked.push(q);
  }

  return NextResponse.json({
    questions: picked.map((q) => ({
      id: q.id,
      number: q.number,
      stem: q.stem,
      questionType: q.questionType,
      options: JSON.parse(q.options || "[]") as McqOption[],
      marks: q.marks,
      isKbat: q.isKbat,
      topic: q.topic?.title ?? null,
    })),
    totalMarks: picked.reduce((a, q) => a + q.marks, 0),
  });
}
