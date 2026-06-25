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

// AI topic-tagger for questions and knowledge (textbook) docs.
// CURSOR-BASED: fetches untagged rows with id > afterId, so genuinely
// un-taggable items are visited once and skipped (never re-processed at the
// queue head). The client loops, passing nextCursor, until done (a short page).
// Body: { target?: "questions"|"knowledge", limit?: number, afterId?: string }
export async function POST(req: NextRequest) {
  const actor = await authorizeImport(req);
  if (!actor) return NextResponse.json({ error: "Forbidden" }, { status: 403 });
  if (!aiEnabled()) return NextResponse.json({ error: "AI is offline (set ANTHROPIC_API_KEY)." }, { status: 503 });

  const body = await req.json().catch(() => ({}));
  const target = body.target === "knowledge" ? "knowledge" : "questions";
  const limit = Math.min(Math.max(Number(body.limit) || 80, 1), 150);
  const afterId: string | undefined = body.afterId || undefined;
  const idFilter = afterId ? { gt: afterId } : undefined;

  type Item = { id: string; text: string; subjectId: string; subjectName: string };
  let items: Item[] = [];
  if (target === "questions") {
    const rows = await prisma.question.findMany({
      where: { topicId: null, id: idFilter },
      take: limit, orderBy: { id: "asc" },
      select: { id: true, stem: true, subjectId: true, subject: { select: { name: true } } },
    });
    items = rows.map((r) => ({ id: r.id, text: r.stem, subjectId: r.subjectId, subjectName: r.subject.name }));
  } else {
    const rows = await prisma.knowledgeDoc.findMany({
      where: { topicId: null, subjectId: { not: null }, id: idFilter },
      take: limit, orderBy: { id: "asc" },
      select: { id: true, title: true, content: true, subjectId: true, subject: { select: { name: true } } },
    });
    items = rows.map((r) => ({ id: r.id, text: `${r.title}\n${r.content}`, subjectId: r.subjectId!, subjectName: r.subject?.name ?? "" }));
  }

  if (items.length === 0) {
    const remaining = await remainingCount(target);
    return NextResponse.json({ target, tagged: 0, processed: 0, nextCursor: null, done: true, remaining });
  }

  const nextCursor = items[items.length - 1].id;

  // Group by subject; cache topic lists.
  const bySubject = new Map<string, Item[]>();
  for (const it of items) {
    const arr = bySubject.get(it.subjectId) ?? [];
    arr.push(it);
    bySubject.set(it.subjectId, arr);
  }
  const topicCache = new Map<string, { id: string; form: number; chapter: number; title: string }[]>();

  let tagged = 0;
  for (const [subjectId, group] of bySubject) {
    let topics = topicCache.get(subjectId);
    if (!topics) {
      topics = await prisma.topic.findMany({
        where: { subjectId }, orderBy: [{ form: "asc" }, { chapter: "asc" }],
        select: { id: true, form: true, chapter: true, title: true },
      });
      topicCache.set(subjectId, topics);
    }
    if (topics.length === 0) continue;
    for (const sub of chunk(group, 40)) {
      let picks: number[];
      try {
        picks = await classifyQuestionTopics(sub[0].subjectName, topics, sub.map((g) => ({ stem: g.text })));
      } catch (e: unknown) {
        // Surface AI rate-limit / quota / auth failures clearly instead of
        // silently tagging nothing — so the client stops and can retry later.
        const status = (e as { status?: number })?.status;
        const rateLimited = status === 429 || status === 529;
        return NextResponse.json(
          {
            error: rateLimited
              ? "AI rate limit / quota reached. Raise the Anthropic limit, then re-run — already-tagged items are saved and skipped."
              : `AI tagging failed (status ${status ?? "unknown"}). Already-tagged items are saved.`,
            code: rateLimited ? "ai_rate_limited" : "ai_error",
            tagged, target,
          },
          { status: 503 },
        );
      }
      for (let i = 0; i < sub.length; i++) {
        const idx = picks[i];
        if (idx < 0) continue;
        const tpc = topics[idx];
        if (target === "questions") {
          await prisma.question.update({ where: { id: sub[i].id }, data: { topicId: tpc.id } });
        } else {
          await prisma.knowledgeDoc.update({ where: { id: sub[i].id }, data: { topicId: tpc.id, form: tpc.form, chapter: tpc.chapter } });
        }
        tagged++;
      }
    }
  }

  await logActivity({ userId: actor.id ?? undefined, name: actor.name, role: actor.role, action: "tag_topics",
    detail: `${target}: +${tagged} of ${items.length}`, ip: clientIp(req) });

  return NextResponse.json({ target, tagged, processed: items.length, nextCursor, done: items.length < limit });
}

async function remainingCount(target: string) {
  return target === "questions"
    ? prisma.question.count({ where: { topicId: null } })
    : prisma.knowledgeDoc.count({ where: { topicId: null, subjectId: { not: null } } });
}

// Counts of what still needs a topic.
export async function GET() {
  const [questions, knowledge] = await Promise.all([
    prisma.question.count({ where: { topicId: null } }),
    prisma.knowledgeDoc.count({ where: { topicId: null, subjectId: { not: null } } }),
  ]);
  return NextResponse.json({ untagged: questions, untaggedKnowledge: knowledge });
}
