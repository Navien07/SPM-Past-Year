import { NextRequest, NextResponse } from "next/server";
import { prisma } from "@/lib/db";
import { authorizeImport } from "@/lib/importAuth";

export const maxDuration = 60;

// List untagged questions / knowledge docs for CLIENT-SIDE tagging: the caller
// classifies each (with its own funded AI key) against /api/taxonomy, then
// writes results back via POST /api/admin/set-topics. Cursor-based by id.
// GET /api/admin/untagged?target=questions|knowledge&afterId=<id>&limit=N
export async function GET(req: NextRequest) {
  const actor = await authorizeImport(req);
  if (!actor) return NextResponse.json({ error: "Forbidden" }, { status: 403 });

  const sp = req.nextUrl.searchParams;
  const target = sp.get("target") === "knowledge" ? "knowledge" : "questions";
  const limit = Math.min(Math.max(Number(sp.get("limit")) || 200, 1), 500);
  const afterId = sp.get("afterId") || undefined;
  const idFilter = afterId ? { gt: afterId } : undefined;

  if (target === "knowledge") {
    const rows = await prisma.knowledgeDoc.findMany({
      where: { topicId: null, subjectId: { not: null }, id: idFilter },
      take: limit, orderBy: { id: "asc" },
      select: { id: true, title: true, content: true, subjectId: true, subject: { select: { code: true } } },
    });
    return NextResponse.json({
      target,
      items: rows.map((r) => ({ id: r.id, subjectId: r.subjectId, subject: r.subject?.code ?? null, text: `${r.title}\n${r.content.slice(0, 1500)}` })),
      nextCursor: rows.length ? rows[rows.length - 1].id : null,
      done: rows.length < limit,
    });
  }

  const rows = await prisma.question.findMany({
    where: { topicId: null, id: idFilter },
    take: limit, orderBy: { id: "asc" },
    select: { id: true, stem: true, subjectId: true, subject: { select: { code: true } } },
  });
  return NextResponse.json({
    target,
    items: rows.map((r) => ({ id: r.id, subjectId: r.subjectId, subject: r.subject.code, text: r.stem.slice(0, 600) })),
    nextCursor: rows.length ? rows[rows.length - 1].id : null,
    done: rows.length < limit,
  });
}
