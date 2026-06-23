import { NextRequest, NextResponse } from "next/server";
import { prisma } from "@/lib/db";
import { authorizeImport } from "@/lib/importAuth";
import { classifyQuestionTopics, aiEnabled } from "@/lib/ai";
import { logActivity, clientIp } from "@/lib/activity";

export const maxDuration = 60;

function chunk<T>(arr: T[], n: number): T[][] {
  const out: T[][] = [];
  for (let i = 0; i < arr.length; i += n) out.push(arr.slice(i, i + n));
  return out;
}

// AI topic-tagger: assigns untagged questions to their KSSM topic (subject is
// known → classify into that subject's topics, which also gives the form).
// Processes one bounded batch per call and reports `remaining`, so a client can
// loop until done. Token-authed (scraper) or admin/teacher session.
export async function POST(req: NextRequest) {
  const actor = await authorizeImport(req);
  if (!actor) return NextResponse.json({ error: "Forbidden" }, { status: 403 });
  if (!aiEnabled()) return NextResponse.json({ error: "AI is offline (set ANTHROPIC_API_KEY)." }, { status: 503 });

  const body = await req.json().catch(() => ({}));
  const limit = Math.min(Math.max(Number(body.limit) || 60, 1), 120);

  // Pull a batch of untagged questions (approved or pending), with their subject.
  const untagged = await prisma.question.findMany({
    where: { topicId: null },
    take: limit,
    orderBy: { createdAt: "asc" },
    select: { id: true, stem: true, subjectId: true, subject: { select: { name: true } } },
  });

  if (untagged.length === 0) {
    return NextResponse.json({ tagged: 0, processed: 0, remaining: 0, done: true });
  }

  // Group by subject; load each subject's KSSM topics once.
  const bySubject = new Map<string, typeof untagged>();
  for (const q of untagged) {
    const arr = bySubject.get(q.subjectId) ?? [];
    arr.push(q);
    bySubject.set(q.subjectId, arr);
  }

  let tagged = 0;
  for (const [subjectId, qs] of bySubject) {
    const topics = await prisma.topic.findMany({
      where: { subjectId },
      orderBy: [{ form: "asc" }, { chapter: "asc" }],
      select: { id: true, form: true, chapter: true, title: true },
    });
    if (topics.length === 0) continue;
    // Classify in sub-batches of 25 for accuracy.
    for (const group of chunk(qs, 25)) {
      const picks = await classifyQuestionTopics(qs[0].subject.name, topics, group.map((g) => ({ stem: g.stem })));
      for (let i = 0; i < group.length; i++) {
        const idx = picks[i];
        if (idx >= 0) {
          await prisma.question.update({ where: { id: group[i].id }, data: { topicId: topics[idx].id } });
          tagged++;
        }
      }
    }
  }

  const remaining = await prisma.question.count({ where: { topicId: null } });
  await logActivity({ userId: actor.id ?? undefined, name: actor.name, role: actor.role, action: "questions.tag_topics",
    detail: `${tagged}/${untagged.length} tagged, ${remaining} remaining`, ip: clientIp(req) });

  return NextResponse.json({ tagged, processed: untagged.length, remaining, done: remaining === 0 });
}

// Quick count of how many questions still need a topic.
export async function GET() {
  const actor = await prisma.question.count({ where: { topicId: null } });
  return NextResponse.json({ untagged: actor });
}
