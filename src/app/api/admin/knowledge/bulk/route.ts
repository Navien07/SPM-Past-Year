import { NextRequest, NextResponse } from "next/server";
import { randomUUID } from "crypto";
import { prisma } from "@/lib/db";
import { authorizeImport } from "@/lib/importAuth";
import { logActivity, clientIp } from "@/lib/activity";
import { subjectResolver, topicResolver } from "@/lib/import";

export const maxDuration = 60;

function chunk<T>(arr: T[], n: number): T[][] {
  const out: T[][] = [];
  for (let i = 0; i < arr.length; i += n) out.push(arr.slice(i, i + n));
  return out;
}

// Bulk-import textbook/notes chunks into the knowledge base ("main brain").
// Idempotent by `sourceKey`. Auto-links each chunk to a KSSM topic when
// form+chapter or topicTitle is provided. Bulk createMany + sequential writes
// (one connection at a time) so large loads are fast and pool-safe.
export async function POST(req: NextRequest) {
  const admin = await authorizeImport(req);
  if (!admin) return NextResponse.json({ error: "Forbidden" }, { status: 403 });

  const body = await req.json();
  const docs = Array.isArray(body.docs) ? body.docs : [];
  if (docs.length === 0) return NextResponse.json({ error: "Provide a non-empty `docs` array." }, { status: 400 });
  if (docs.length > 1000) return NextResponse.json({ error: "Max 1000 chunks per request." }, { status: 400 });

  const resolveSubject = await subjectResolver();

  // Validate + dedupe; resolve subjects.
  interface Prep { sourceKey: string | null; subjectId: string | null; form: number | null; chapter: number | null; topicTitle?: string; data: Record<string, unknown> }
  const prep: Prep[] = [];
  const skipped: { title?: string; reason: string }[] = [];
  const seen = new Set<string>();
  for (const d of docs) {
    const content = String(d.content ?? "").trim();
    if (!d.title || !content) { skipped.push({ title: d.title, reason: "Missing title or content" }); continue; }
    const sourceKey = d.sourceKey ? String(d.sourceKey).slice(0, 300) : null;
    if (sourceKey && seen.has(sourceKey)) { skipped.push({ title: d.title, reason: "Duplicate sourceKey in batch" }); continue; }
    if (sourceKey) seen.add(sourceKey);
    prep.push({
      sourceKey,
      subjectId: d.subjectId || resolveSubject(d.subject ?? d.subjectCode),
      form: d.form ? Number(d.form) : null,
      chapter: d.chapter ? Number(d.chapter) : null,
      topicTitle: d.topicTitle,
      data: {
        title: String(d.title).slice(0, 200),
        kind: String(d.kind || "textbook").slice(0, 20),
        source: d.source ? String(d.source).slice(0, 200) : null,
        sourceUrl: d.sourceUrl ? String(d.sourceUrl).slice(0, 500) : null,
        language: d.language ? String(d.language).slice(0, 5) : null,
        content,
      },
    });
  }
  if (prep.length === 0) return NextResponse.json({ created: 0, updated: 0, skipped: skipped.length, skippedDetail: skipped.slice(0, 50) });

  // Topic resolvers for the distinct subjects (sequential, one connection).
  const distinct = [...new Set(prep.map((p) => p.subjectId).filter(Boolean) as string[])];
  const resolvers = new Map<string, Awaited<ReturnType<typeof topicResolver>>>();
  for (const sid of distinct) resolvers.set(sid, await topicResolver(sid));

  // Existing docs by sourceKey.
  const keys = prep.map((p) => p.sourceKey).filter(Boolean) as string[];
  const existing = keys.length
    ? await prisma.knowledgeDoc.findMany({ where: { sourceKey: { in: keys } }, select: { id: true, sourceKey: true } })
    : [];
  const idByKey = new Map(existing.map((e) => [e.sourceKey!, e.id]));

  const toCreate: Record<string, unknown>[] = [];
  const toUpdate: { id: string; data: Record<string, unknown> }[] = [];
  let created = 0, updated = 0;

  for (const p of prep) {
    const topicId = p.subjectId ? resolvers.get(p.subjectId)!({ topicTitle: p.topicTitle, form: p.form, chapter: p.chapter }) : null;
    const full = { ...p.data, subjectId: p.subjectId ?? null, form: p.form, chapter: p.chapter, topicId };
    const existingId = p.sourceKey ? idByKey.get(p.sourceKey) : undefined;
    if (existingId) { toUpdate.push({ id: existingId, data: full }); updated++; }
    else { toCreate.push({ id: randomUUID(), sourceKey: p.sourceKey, ...full }); created++; }
  }

  if (toCreate.length) for (const c of chunk(toCreate, 200)) await prisma.knowledgeDoc.createMany({ data: c as never, skipDuplicates: true });
  for (const u of toUpdate) await prisma.knowledgeDoc.update({ where: { id: u.id }, data: u.data });

  await logActivity({ userId: admin.id ?? undefined, name: admin.name, role: admin.role, action: "knowledge.bulk_import",
    detail: `${created} created, ${updated} updated, ${skipped.length} skipped`, ip: clientIp(req) });

  return NextResponse.json({ created, updated, skipped: skipped.length, skippedDetail: skipped.slice(0, 50) });
}
