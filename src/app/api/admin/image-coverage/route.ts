import { NextRequest, NextResponse } from "next/server";
import { prisma } from "@/lib/db";
import { authorizeImport } from "@/lib/importAuth";

export const maxDuration = 60;

type Row = { code: string; name: string; total: bigint; with_images: bigint };

// Per-subject diagram/image backfill progress: how many approved questions now
// carry an image vs none. Lets admins track the backfill as it runs.
export async function GET(req: NextRequest) {
  const actor = await authorizeImport(req);
  if (!actor) return NextResponse.json({ error: "Forbidden" }, { status: 403 });

  const rows = await prisma.$queryRawUnsafe<Row[]>(
    `SELECT s.code, s.name,
            count(*)::bigint total,
            count(*) FILTER (WHERE q.images <> '[]' AND q.images <> '')::bigint with_images
     FROM "Question" q JOIN "Subject" s ON s.id = q."subjectId"
     WHERE q.status = 'approved'
     GROUP BY s.code, s.name
     ORDER BY s.name`,
  );

  const subjects = rows.map((r) => {
    const total = Number(r.total);
    const withImages = Number(r.with_images);
    return { code: r.code, name: r.name, total, withImages, withoutImages: total - withImages,
      pct: total > 0 ? Math.round((withImages / total) * 100) : 0 };
  });
  const total = subjects.reduce((a, s) => a + s.total, 0);
  const withImages = subjects.reduce((a, s) => a + s.withImages, 0);

  return NextResponse.json({ subjects, total, withImages, pct: total > 0 ? Math.round((withImages / total) * 100) : 0 });
}
