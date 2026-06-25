import { NextRequest, NextResponse } from "next/server";
import { prisma } from "@/lib/db";
import { authorizeImport } from "@/lib/importAuth";
import { logActivity, clientIp } from "@/lib/activity";

export const maxDuration = 60;

// Write topic assignments computed client-side (no server AI). Idempotent.
// Body: { target?: "questions"|"knowledge", items: [{ id, topicId }] }
// For knowledge, form + chapter are derived from the topic so the KB stays
// navigable by subject/form/topic.
export async function POST(req: NextRequest) {
  const actor = await authorizeImport(req);
  if (!actor) return NextResponse.json({ error: "Forbidden" }, { status: 403 });

  const body = await req.json().catch(() => ({}));
  const target = body.target === "knowledge" ? "knowledge" : "questions";
  const items = Array.isArray(body.items) ? body.items : [];
  if (items.length === 0) return NextResponse.json({ error: "Provide a non-empty `items` array." }, { status: 400 });
  if (items.length > 2000) return NextResponse.json({ error: "Max 2000 items per request." }, { status: 400 });

  // Group ids by topicId so we can updateMany once per distinct topic.
  const byTopic = new Map<string, string[]>();
  for (const it of items) {
    const id = String(it?.id ?? "");
    const topicId = String(it?.topicId ?? "");
    if (!id || !topicId) continue;
    const arr = byTopic.get(topicId) ?? [];
    arr.push(id);
    byTopic.set(topicId, arr);
  }
  if (byTopic.size === 0) return NextResponse.json({ error: "No valid {id, topicId} pairs." }, { status: 400 });

  // Validate topic ids and (for knowledge) get their form/chapter.
  const topics = await prisma.topic.findMany({
    where: { id: { in: [...byTopic.keys()] } },
    select: { id: true, form: true, chapter: true },
  });
  const topicMap = new Map(topics.map((t) => [t.id, t]));

  let updated = 0;
  for (const [topicId, ids] of byTopic) {
    const tpc = topicMap.get(topicId);
    if (!tpc) continue; // skip unknown topic ids
    if (target === "knowledge") {
      const r = await prisma.knowledgeDoc.updateMany({ where: { id: { in: ids } }, data: { topicId, form: tpc.form, chapter: tpc.chapter } });
      updated += r.count;
    } else {
      const r = await prisma.question.updateMany({ where: { id: { in: ids } }, data: { topicId } });
      updated += r.count;
    }
  }

  await logActivity({ userId: actor.id ?? undefined, name: actor.name, role: actor.role, action: "set_topics",
    detail: `${target}: ${updated} updated`, ip: clientIp(req) });

  const remaining = target === "questions"
    ? await prisma.question.count({ where: { topicId: null } })
    : await prisma.knowledgeDoc.count({ where: { topicId: null, subjectId: { not: null } } });

  return NextResponse.json({ target, updated, remaining });
}
