import { NextResponse } from "next/server";
import { prisma } from "@/lib/db";
import { getSessionStudent } from "@/lib/student";

// Adaptive "next best question": prioritise (1) anything due for spaced-repetition
// review, then (2) an unattempted question from the student's weakest topic, then
// (3) any unattempted approved question in an enrolled subject.
export async function GET() {
  const student = await getSessionStudent();
  if (!student) return NextResponse.json({ error: "Not signed in" }, { status: 401 });

  // 1. Due review item
  const due = await prisma.reviewItem.findFirst({
    where: { studentId: student.id, dueAt: { lte: new Date() } },
    orderBy: { dueAt: "asc" },
  });
  if (due) return NextResponse.json({ questionId: due.questionId, reason: "review" });

  const enrollments = await prisma.enrollment.findMany({ where: { studentId: student.id }, select: { subjectId: true } });
  const subjectIds = enrollments.map((e) => e.subjectId);
  if (subjectIds.length === 0) return NextResponse.json({ questionId: null });

  const attempts = await prisma.attempt.findMany({
    where: { studentId: student.id },
    select: { questionId: true, score: true, maxScore: true, question: { select: { topicId: true } } },
  });
  const attemptedIds = new Set(attempts.map((a) => a.questionId));

  // Weakest topic by average %.
  const byTopic = new Map<string, { sum: number; n: number }>();
  for (const a of attempts) {
    if (!a.question.topicId) continue;
    const cur = byTopic.get(a.question.topicId) ?? { sum: 0, n: 0 };
    cur.sum += a.maxScore ? (a.score / a.maxScore) * 100 : 0;
    cur.n += 1;
    byTopic.set(a.question.topicId, cur);
  }
  const weakTopics = [...byTopic.entries()]
    .map(([topicId, v]) => ({ topicId, avg: v.sum / v.n }))
    .sort((a, b) => a.avg - b.avg)
    .map((t) => t.topicId);

  // 2. Unattempted question in the weakest topics first.
  for (const topicId of weakTopics) {
    const q = await prisma.question.findFirst({
      where: { topicId, status: "approved", id: { notIn: [...attemptedIds] } },
    });
    if (q) return NextResponse.json({ questionId: q.id, reason: "weak-topic" });
  }

  // 3. Any unattempted approved question in an enrolled subject.
  const q = await prisma.question.findFirst({
    where: { subjectId: { in: subjectIds }, status: "approved", id: { notIn: [...attemptedIds] } },
    orderBy: { createdAt: "asc" },
  });
  return NextResponse.json({ questionId: q?.id ?? null, reason: q ? "new" : "none" });
}
