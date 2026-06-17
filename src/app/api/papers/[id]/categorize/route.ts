import { NextRequest, NextResponse } from "next/server";
import { prisma } from "@/lib/db";
import { categorizePaper } from "@/lib/ai";
import { AUTO_APPROVE_THRESHOLD } from "@/lib/constants";

export const maxDuration = 60;


// Module 2: run the categorization agent over a paper's rawText, creating
// tagged Question rows (and Topic rows as needed) in the question bank.
export async function POST(_req: NextRequest, ctx: { params: Promise<{ id: string }> }) {
  const { id } = await ctx.params;
  const paper = await prisma.paper.findUnique({ where: { id }, include: { subject: true } });
  if (!paper) return NextResponse.json({ error: "Paper not found" }, { status: 404 });
  if (!paper.rawText) {
    return NextResponse.json(
      { error: "Paper has no text to categorize. Add source text first." },
      { status: 400 },
    );
  }

  await prisma.paper.update({ where: { id }, data: { status: "categorizing" } });

  try {
    const { result, byAi } = await categorizePaper({
      subjectName: paper.subject.name,
      paperType: paper.paperType,
      year: paper.year,
      state: paper.state,
      paperNumber: paper.paperNumber,
      rawText: paper.rawText,
      markingScheme: paper.markingScheme,
    });

    // Replace any prior questions for this paper so re-running is idempotent.
    await prisma.question.deleteMany({ where: { paperId: id } });

    let created = 0;
    let autoApproved = 0;
    let pending = 0;
    for (const q of result.questions) {
      // Find or create the topic this question maps to.
      let topicId: string | null = null;
      if (q.form && q.chapter && q.chapterTitle) {
        const topic = await prisma.topic.upsert({
          where: {
            subjectId_form_chapter: {
              subjectId: paper.subjectId,
              form: q.form,
              chapter: q.chapter,
            },
          },
          update: { title: q.chapterTitle },
          create: {
            subjectId: paper.subjectId,
            form: q.form,
            chapter: q.chapter,
            title: q.chapterTitle,
            subtopics: "[]",
          },
        });
        topicId = topic.id;
      }

      // Confidence gate: high-confidence categorizations auto-approve; the rest
      // are flagged `pending` so the moderator only reviews the doubtful ones.
      const confidence = typeof q.confidence === "number" ? Math.max(0, Math.min(1, q.confidence)) : 0.5;
      const auto = confidence >= AUTO_APPROVE_THRESHOLD;

      await prisma.question.create({
        data: {
          subjectId: paper.subjectId,
          topicId,
          paperId: id,
          paperNumber: paper.paperNumber,
          questionType: q.questionType,
          number: q.number ?? null,
          stem: q.stem,
          options: JSON.stringify(q.options ?? []),
          answer: q.answer ?? null,
          markingScheme: q.markingScheme ?? null,
          marks: q.marks || (q.questionType === "mcq" ? 1 : 4),
          isKbat: !!q.isKbat,
          subtopic: q.subtopic ?? null,
          year: paper.year,
          source: "past_paper",
          confidence,
          status: auto ? "approved" : "pending",
          autoApproved: auto,
          reviewNote: auto ? `Auto-approved (AI confidence ${Math.round(confidence * 100)}%)` : null,
          reviewedAt: auto ? new Date() : null,
        },
      });
      created++;
      if (auto) autoApproved++;
      else pending++;
    }

    await prisma.paper.update({
      where: { id },
      data: { status: "categorized", categorizedAt: new Date() },
    });

    return NextResponse.json({ created, autoApproved, pending, byAi, threshold: AUTO_APPROVE_THRESHOLD });
  } catch (e) {
    await prisma.paper.update({ where: { id }, data: { status: "failed" } });
    return NextResponse.json(
      { error: e instanceof Error ? e.message : "Categorization failed" },
      { status: 500 },
    );
  }
}
