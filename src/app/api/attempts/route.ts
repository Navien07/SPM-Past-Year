import { NextRequest, NextResponse } from "next/server";
import { prisma } from "@/lib/db";
import { gradeAnswer } from "@/lib/ai";
import { getCurrentStudent } from "@/lib/student";
import type { McqOption } from "@/lib/types";

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

  const student = await getCurrentStudent();

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

  return NextResponse.json({ attempt, grade: result, byAi });
}
