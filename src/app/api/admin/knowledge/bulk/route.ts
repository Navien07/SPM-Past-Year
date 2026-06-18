import { NextRequest, NextResponse } from "next/server";
import { prisma } from "@/lib/db";
import { getCurrentUser } from "@/lib/auth";
import { logActivity, clientIp } from "@/lib/activity";
import { subjectResolver, topicResolver } from "@/lib/import";

export const maxDuration = 60;

// Bulk-import textbook/notes chunks into the knowledge base ("main brain").
// Idempotent by `sourceKey`. Auto-links each chunk to a KSSM topic when
// form+chapter or topicTitle is provided. One chunk per chapter/section is best.
export async function POST(req: NextRequest) {
  const admin = await getCurrentUser();
  if (!admin || admin.role !== "admin") return NextResponse.json({ error: "Forbidden" }, { status: 403 });

  const body = await req.json();
  const docs = Array.isArray(body.docs) ? body.docs : [];
  if (docs.length === 0) return NextResponse.json({ error: "Provide a non-empty `docs` array." }, { status: 400 });
  if (docs.length > 1000) return NextResponse.json({ error: "Max 1000 chunks per request." }, { status: 400 });

  const resolveSubject = await subjectResolver();
  const topicResolvers = new Map<string, Awaited<ReturnType<typeof topicResolver>>>();
  async function getTopicResolver(subjectId: string) {
    let r = topicResolvers.get(subjectId);
    if (!r) { r = await topicResolver(subjectId); topicResolvers.set(subjectId, r); }
    return r;
  }

  let created = 0, updated = 0;
  const skipped: { title?: string; reason: string }[] = [];

  for (const d of docs) {
    const content = String(d.content ?? "").trim();
    if (!d.title || !content) { skipped.push({ title: d.title, reason: "Missing title or content" }); continue; }

    const subjectId = d.subjectId || resolveSubject(d.subject ?? d.subjectCode);
    const form = d.form ? Number(d.form) : null;
    const chapter = d.chapter ? Number(d.chapter) : null;
    let topicId: string | null = null;
    if (subjectId) {
      const resolveTopic = await getTopicResolver(subjectId);
      topicId = resolveTopic({ topicTitle: d.topicTitle, form, chapter });
    }

    const data = {
      title: String(d.title).slice(0, 200),
      subjectId: subjectId ?? null,
      form,
      chapter,
      topicId,
      kind: String(d.kind || "textbook").slice(0, 20),
      source: d.source ? String(d.source).slice(0, 200) : null,
      sourceUrl: d.sourceUrl ? String(d.sourceUrl).slice(0, 500) : null,
      language: d.language ? String(d.language).slice(0, 5) : null,
      content,
    };

    const sourceKey = d.sourceKey ? String(d.sourceKey).slice(0, 300) : null;
    const existing = sourceKey ? await prisma.knowledgeDoc.findUnique({ where: { sourceKey } }) : null;
    if (existing) {
      await prisma.knowledgeDoc.update({ where: { id: existing.id }, data });
      updated++;
    } else {
      await prisma.knowledgeDoc.create({ data: { ...data, sourceKey } });
      created++;
    }
  }

  await logActivity({ userId: admin.id, name: admin.name, role: "admin", action: "knowledge.bulk_import",
    detail: `${created} created, ${updated} updated, ${skipped.length} skipped`, ip: clientIp(req) });

  return NextResponse.json({ created, updated, skipped: skipped.length, skippedDetail: skipped.slice(0, 50) });
}
