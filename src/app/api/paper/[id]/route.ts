import { NextRequest, NextResponse } from "next/server";
import { prisma } from "@/lib/db";
import { getSessionStudent } from "@/lib/student";
import type { McqOption } from "@/lib/types";

export const maxDuration = 60;

// Return a past paper's approved questions in order, for an end-to-end attempt.
export async function GET(_req: NextRequest, { params }: { params: Promise<{ id: string }> }) {
  const student = await getSessionStudent();
  if (!student) return NextResponse.json({ error: "Not signed in as a student" }, { status: 401 });
  const { id } = await params;

  const paper = await prisma.paper.findUnique({
    where: { id },
    select: { id: true, title: true, paperNumber: true, subject: { select: { name: true } } },
  });
  if (!paper) return NextResponse.json({ error: "Paper not found" }, { status: 404 });

  const questions = await prisma.question.findMany({
    where: { paperId: id, status: "approved" },
    orderBy: [{ number: "asc" }, { createdAt: "asc" }],
    select: { id: true, number: true, stem: true, questionType: true, options: true, marks: true, isKbat: true, topic: { select: { title: true } } },
  });

  return NextResponse.json({
    paper: { id: paper.id, title: paper.title, subject: paper.subject.name, paperNumber: paper.paperNumber },
    totalMarks: questions.reduce((a, q) => a + q.marks, 0),
    questions: questions.map((q) => ({
      id: q.id, number: q.number, stem: q.stem, questionType: q.questionType,
      options: JSON.parse(q.options || "[]") as McqOption[], marks: q.marks, isKbat: q.isKbat,
      topic: q.topic?.title ?? null,
    })),
  });
}
