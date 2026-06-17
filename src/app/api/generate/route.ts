import { NextRequest, NextResponse } from "next/server";
import { prisma } from "@/lib/db";
import { generateQuestions } from "@/lib/ai";

export const maxDuration = 60;

// Module 5: generate new practice questions (incl. KBAT) in the pattern of the
// topic's real past-paper questions. Stored as approved Question rows with
// source "ai_generated" so students can attempt them anytime from Practice.
export async function POST(req: NextRequest) {
  const { topicId, questionType, count, kbat } = await req.json();
  if (!topicId) return NextResponse.json({ error: "topicId is required" }, { status: 400 });

  const topic = await prisma.topic.findUnique({
    where: { id: topicId },
    include: { subject: true },
  });
  if (!topic) return NextResponse.json({ error: "Topic not found" }, { status: 404 });

  // Use real past-paper questions on this topic as style exemplars.
  const examples = await prisma.question.findMany({
    where: { topicId, source: "past_paper", status: "approved" },
    take: 4,
    select: { stem: true },
  });

  const { result, byAi } = await generateQuestions({
    subjectName: topic.subject.name,
    topicTitle: topic.title,
    form: topic.form,
    questionType: questionType || "structured",
    count: Math.min(Number(count) || 3, 8),
    kbat: kbat ?? true,
    examples: examples.map((e) => e.stem),
  });

  const saved = [];
  for (const item of result) {
    const q = await prisma.question.create({
      data: {
        subjectId: topic.subjectId,
        topicId,
        paperNumber: item.questionType === "mcq" ? 1 : 2,
        questionType: item.questionType,
        stem: item.stem,
        options: JSON.stringify(item.options ?? []),
        answer: item.answer ?? null,
        markingScheme: item.markingScheme ?? null,
        marks: item.marks || (item.questionType === "mcq" ? 1 : 4),
        isKbat: item.isKbat ?? true,
        source: "ai_generated",
        status: "approved", // student-generated practice; available immediately
        confidence: 1,
        autoApproved: true,
        reviewNote: item.basedOn ?? "AI-generated practice",
      },
    });
    saved.push({
      id: q.id,
      questionType: q.questionType,
      stem: q.stem,
      options: q.options,
      answer: q.answer,
      markingScheme: q.markingScheme,
      marks: q.marks,
      isKbat: q.isKbat,
      basedOn: q.reviewNote,
    });
  }

  return NextResponse.json({ generated: saved, byAi });
}
