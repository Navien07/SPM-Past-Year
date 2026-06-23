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

// AI topic-tagger for both questions and knowledge (textbook) docs. Subject is
// known → classify into that subject's KSSM topic, which also gives the form.
// Processes one bounded batch per call and reports `remaining`, so a client (or
// the unsupervised scraper session via the import token) can loop until done.
// Body: { target?: "questions" | "knowledge", limit?: number }
export async function POST(req: NextRequest) {
  const actor = await authorizeImport(req);
  if (!actor) return NextResponse.json({ error: "Forbidden" }, { status: 403 });
  if (!aiEnabled()) return NextResponse.json({ error: "AI is offline (set ANTHROPIC_API_KEY)." }, { status: 503 });

  const body = await req.json().catch(() => ({}));
  const target = body.target === "knowledge" ? "knowledge" : "questions";
  const limit = Math.min(Math.max(Number(body.limit) || 60, 1), 120);

  // Pull a batch of untagged items (with subject), grouped by subject.
  type Item = { id: string; text: string; subjectId: string; subjectName: string };
  let items: Item[] = [];
  if (target === "questions") {
    const rows = await prisma.question.findMany({
      where: { topicId: null },
      take: limit, orderBy: { createdAt: "asc" },
      select: { id: true, stem: true, subjectId: true, subject: { select: { name: true } } },
    });
    items = rows.map((r) => ({ id: r.id, text: r.stem, subjectId: r.subjectId, subjectName: r.subject.name }));
  } else {
    const rows = await prisma.knowledgeDoc.findMany({
      where: { topicId: null, subjectId: { not: null } },
      take: limit, orderBy: { createdAt: "asc" },
      select: { id: true, title: true, content: true, subjectId: true, subject: { select: { name: true } } },
    });
    items = rows.map((r) => ({ id: r.id, text: `${r.title}\n${r.content}`, subjectId: r.subjectId!, subjectName: r.subject?.name ?? "" }));
  }

  if (items.length === 0) return NextResponse.json({ target, tagged: 0, processed: 0, remaining: 0, done: true });

  const bySubject = new Map<string, Item[]>();
  for (const it of items) {
    const arr = bySubject.get(it.subjectId) ?? [];
    arr.push(it);
    bySubject.set(it.subjectId, arr);
  }

  let tagged = 0;
  for (const [subjectId, group] of bySubject) {
    const topics = await prisma.topic.findMany({
      where: { subjectId },
      orderBy: [{ form: "asc" }, { chapter: "asc" }],
      select: { id: true, form: true, chapter: true, title: true },
    });
    if (topics.length === 0) continue;
    for (const sub of chunk(group, 25)) {
      const picks = await classifyQuestionTopics(sub[0].subjectName, topics, sub.map((g) => ({ stem: g.text })));
      for (let i = 0; i < sub.length; i++) {
        const idx = picks[i];
        if (idx < 0) continue;
        const t = topics[idx];
        if (target === "questions") {
          await prisma.question.update({ where: { id: sub[i].id }, data: { topicId: t.id } });
        } else {
          // Textbook chunk → topic + form + chapter, so the knowledge base is
          // navigable by subject/form/topic like the question bank.
          await prisma.knowledgeDoc.update({ where: { id: sub[i].id }, data: { topicId: t.id, form: t.form, chapter: t.chapter } });
        }
        tagged++;
      }
    }
  }

  const remaining = target === "questions"
    ? await prisma.question.count({ where: { topicId: null } })
    : await prisma.knowledgeDoc.count({ where: { topicId: null, subjectId: { not: null } } });

  await logActivity({ userId: actor.id ?? undefined, name: actor.name, role: actor.role, action: "tag_topics",
    detail: `${target}: ${tagged}/${items.length} tagged, ${remaining} remaining`, ip: clientIp(req) });

  return NextResponse.json({ target, tagged, processed: items.length, remaining, done: remaining === 0 });
}

// Counts of what still needs a topic.
export async function GET() {
  const [questions, knowledge] = await Promise.all([
    prisma.question.count({ where: { topicId: null } }),
    prisma.knowledgeDoc.count({ where: { topicId: null, subjectId: { not: null } } }),
  ]);
  return NextResponse.json({ untagged: questions, untaggedKnowledge: knowledge });
}
