import { NextRequest, NextResponse } from "next/server";
import { prisma } from "@/lib/db";
import { gradeAnswer } from "@/lib/ai";
import { getSessionStudent } from "@/lib/student";
import type { McqOption } from "@/lib/types";

export const maxDuration = 60;

// Module 4: submit a student answer → instant AI (or deterministic) grade.
export async function POST(req: NextRequest) {
  const { questionId, answer, timeSpentSec } = await req.json();
  if (!questionId || answer === undefined) {
    return NextResponse.json({ error: "questionId and answer are required" }, { status: 400 });
  }

  const question = await prisma.question.findUnique({
    where: { id: questionId },
    include: { subject: true },
  });
  if (!question) return NextResponse.json({ error: "Question not found" }, { status: 404 });

  const student = await getSessionStudent();
  if (!student) return NextResponse.json({ error: "Not signed in as a student" }, { status: 401 });

  const { result, byAi } = await gradeAnswer({
    questionType: question.questionType,
    stem: question.stem,
    options: JSON.parse(question.options || "[]") as McqOption[],
    answer: question.answer,
    markingScheme: question.markingScheme,
    rubric: question.rubric,
    marks: question.marks,
    studentAnswer: String(answer),
    subjectName: question.subject.name,
  });

  const attempt = await prisma.attempt.create({
    data: {
      studentId: student.id,
      questionId,
      answer: String(answer),
      score: result.score,
      maxScore: result.maxScore,
      band: result.band,
      isCorrect: result.isCorrect,
      feedback: JSON.stringify(result),
      gradedByAi: byAi,
      timeSpentSec: Number(timeSpentSec) || 0,
    },
  });

  // Spaced repetition (Leitner): schedule a review unless well-mastered.
  // <50% → reset to box 0 (due now-ish); ≥50% → advance a box (longer interval).
  const pct = result.maxScore ? (result.score / result.maxScore) * 100 : 0;
  const DAYS = [0, 1, 3, 7, 16, 35]; // box → days until next review
  const existing = await prisma.reviewItem.findUnique({
    where: { studentId_questionId: { studentId: student.id, questionId } },
  });
  const passed = pct >= 50;
  const box = passed ? Math.min(5, (existing?.box ?? 0) + 1) : 0;
  const dueAt = new Date(Date.now() + DAYS[box] * 86400000);
  if (passed && box >= 5) {
    // Mastered — drop from the review queue.
    if (existing) await prisma.reviewItem.delete({ where: { id: existing.id } });
  } else {
    await prisma.reviewItem.upsert({
      where: { studentId_questionId: { studentId: student.id, questionId } },
      update: { box, dueAt, lastScorePct: pct, reps: { increment: 1 } },
      create: { studentId: student.id, questionId, box, dueAt, lastScorePct: pct, reps: 1 },
    });
  }

  return NextResponse.json({ attempt, grade: result, byAi });
}
