import { NextRequest, NextResponse } from "next/server";
import { prisma } from "@/lib/db";
import { authorizeImport } from "@/lib/importAuth";

export const maxDuration = 60;

// List questions for mapping each to its source PDF page (used by the image
// backfill). Cursor-paginated by id. Returns enough to locate the question in
// its paper without dumping full content.
//   GET /api/admin/questions?subject=PHY&afterId=...&take=500&withoutImages=1&paper=<paperId>
export async function GET(req: NextRequest) {
  const actor = await authorizeImport(req);
  if (!actor) return NextResponse.json({ error: "Forbidden" }, { status: 403 });

  const url = new URL(req.url);
  const take = Math.min(1000, Math.max(1, Number(url.searchParams.get("take")) || 500));
  const afterId = url.searchParams.get("afterId") || undefined;
  const subject = url.searchParams.get("subject") || undefined; // subject code
  const paper = url.searchParams.get("paper") || undefined; // paperId
  const withoutImages = url.searchParams.get("withoutImages") === "1";

  const where: Record<string, unknown> = {};
  if (subject) where.subject = { code: subject };
  if (paper) where.paperId = paper;
  if (withoutImages) where.images = "[]";

  const rows = await prisma.question.findMany({
    where,
    orderBy: { id: "asc" },
    ...(afterId ? { cursor: { id: afterId }, skip: 1 } : {}),
    take,
    select: {
      id: true,
      number: true,
      stem: true,
      paperId: true,
      images: true,
      subject: { select: { code: true } },
      paper: { select: { sourceKey: true, title: true } },
    },
  });

  const items = rows.map((q) => ({
    id: q.id,
    number: q.number,
    stem: q.stem.slice(0, 240),
    paperId: q.paperId,
    paperSourceKey: q.paper?.sourceKey ?? null,
    paperTitle: q.paper?.title ?? null,
    subject: q.subject.code,
    hasImages: q.images !== "[]" && q.images !== "",
  }));

  return NextResponse.json({ items, nextCursor: rows.length === take ? rows[rows.length - 1].id : null });
}
