import { NextRequest, NextResponse } from "next/server";
import { prisma } from "@/lib/db";

// Module 6: assemble a mock paper from the question bank for a subject.
// Picks a spread across topics; optionally biases toward KBAT.
export async function POST(req: NextRequest) {
  const { subjectId, paperNumber, count, kbatBias } = await req.json();
  if (!subjectId) return NextResponse.json({ error: "subjectId is required" }, { status: 400 });

  const pn = Number(paperNumber) || 1;
  const want = Math.min(Number(count) || 10, 40);

  const pool = await prisma.question.findMany({
    where: { subjectId, paperNumber: pn },
    include: { topic: true },
  });
  if (pool.length === 0) {
    return NextResponse.json({ error: "No questions available for this subject/paper." }, { status: 400 });
  }

  // Shuffle, optionally float KBAT items up, then take `want`, spreading topics.
  const shuffled = [...pool].sort(() => Math.random() - 0.5);
  if (kbatBias) shuffled.sort((a, b) => Number(b.isKbat) - Number(a.isKbat));

  const picked: typeof shuffled = [];
  const seenTopics = new Set<string>();
  for (const q of shuffled) {
    if (picked.length >= want) break;
    const tk = q.topicId ?? "none";
    // Prefer topic spread first pass.
    if (!seenTopics.has(tk) || picked.length > pool.length / 2) {
      picked.push(q);
      seenTopics.add(tk);
    }
  }
  for (const q of shuffled) {
    if (picked.length >= want) break;
    if (!picked.find((p) => p.id === q.id)) picked.push(q);
  }

  const subject = await prisma.subject.findUnique({ where: { id: subjectId } });
  const mock = await prisma.mockPaper.create({
    data: {
      title: `Mock ${subject?.name ?? ""} Kertas ${pn} — ${new Date().toLocaleDateString("en-MY")}`,
      subjectId,
      paperNumber: pn,
      questionIds: JSON.stringify(picked.map((q) => q.id)),
    },
  });

  return NextResponse.json({
    mock,
    questions: picked.map((q) => ({
      id: q.id,
      stem: q.stem,
      marks: q.marks,
      isKbat: q.isKbat,
      topic: q.topic?.title ?? null,
      questionType: q.questionType,
    })),
  });
}

export async function GET() {
  const mocks = await prisma.mockPaper.findMany({ orderBy: { createdAt: "desc" } });
  return NextResponse.json(mocks);
}
