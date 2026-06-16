import { NextRequest, NextResponse } from "next/server";
import { prisma } from "@/lib/db";
import { generateQuestions } from "@/lib/ai";

// Module 5: generate new practice questions (incl. KBAT) in the pattern of the
// topic's real past-paper questions. Persists them as GeneratedQuestion rows.
export async function POST(req: NextRequest) {
  const { topicId, questionType, count, kbat } = await req.json();
  if (!topicId) return NextResponse.json({ error: "topicId is required" }, { status: 400 });

  const topic = await prisma.topic.findUnique({
    where: { id: topicId },
    include: { subject: true },
  });
  if (!topic) return NextResponse.json({ error: "Topic not found" }, { status: 404 });

  // Use real questions from this topic as style exemplars.
  const examples = await prisma.question.findMany({
    where: { topicId, source: "past_paper" },
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
    const g = await prisma.generatedQuestion.create({
      data: {
        topicId,
        questionType: item.questionType,
        stem: item.stem,
        options: JSON.stringify(item.options ?? []),
        answer: item.answer ?? null,
        markingScheme: item.markingScheme ?? null,
        marks: item.marks || (item.questionType === "mcq" ? 1 : 4),
        isKbat: item.isKbat ?? true,
        basedOn: item.basedOn ?? null,
      },
    });
    saved.push(g);
  }

  return NextResponse.json({ generated: saved, byAi });
}
