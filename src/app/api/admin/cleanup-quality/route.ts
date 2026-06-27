import { NextRequest, NextResponse } from "next/server";
import { prisma } from "@/lib/db";
import { authorizeImport } from "@/lib/importAuth";
import { logActivity, clientIp } from "@/lib/activity";

export const maxDuration = 60;

// Heuristics for OCR-noise / boilerplate that should never reach students.
// Matched against the stem (case-insensitive). Kept conservative so real
// questions are not hidden.
const BOILERPLATE = [
  "tulis nama",
  "markah penuh diperoleh",
  "untuk kegunaan pemeriksa",
  "for examiner",
  "do not write",
  "jangan tulis",
  "this question paper consists",
  "kertas soalan ini mengandungi",
  "sila semak",
  "halaman ini sengaja dibiarkan kosong",
  "this page is intentionally left blank",
];

// Build the WHERE clause shared by preview (GET) and apply (POST).
function junkWhere() {
  return {
    status: "approved",
    source: "past_paper",
    OR: BOILERPLATE.map((p) => ({ stem: { contains: p, mode: "insensitive" as const } })),
  };
}

// GET → preview how many would be hidden (also reports the short-stem count,
// which needs a raw length() query Prisma can't express in findMany).
export async function GET(req: NextRequest) {
  const actor = await authorizeImport(req);
  if (!actor) return NextResponse.json({ error: "Forbidden" }, { status: 403 });
  const boilerplate = await prisma.question.count({ where: junkWhere() });
  const shortRows = await prisma.$queryRawUnsafe<{ c: bigint }[]>(
    `SELECT count(*)::bigint c FROM "Question" WHERE status = 'approved' AND source = 'past_paper' AND char_length(btrim(stem)) < 20`,
  );
  const short = Number(shortRows[0]?.c ?? 0);
  return NextResponse.json({ boilerplate, short, estimate: boilerplate + short });
}

// POST → reject (hide) the junk. Idempotent: rejected rows are skipped on re-run.
export async function POST(req: NextRequest) {
  const actor = await authorizeImport(req);
  if (!actor) return NextResponse.json({ error: "Forbidden" }, { status: 403 });

  const note = "auto: low-quality / OCR noise";
  const byPhrase = await prisma.question.updateMany({
    where: junkWhere(),
    data: { status: "rejected", reviewNote: note },
  });
  // Short stems via raw SQL (length filter isn't expressible in updateMany).
  const short: number = await prisma.$executeRawUnsafe(
    `UPDATE "Question" SET status = 'rejected', "reviewNote" = $1
     WHERE status = 'approved' AND source = 'past_paper' AND char_length(btrim(stem)) < 20`,
    note,
  );

  const hidden = byPhrase.count + Number(short || 0);
  await logActivity({
    userId: actor.id,
    name: actor.name,
    role: actor.role,
    action: "admin.cleanup_quality",
    detail: `Hid ${hidden} low-quality questions`,
    ip: clientIp(req),
  });
  return NextResponse.json({ hidden, byPhrase: byPhrase.count, short: Number(short || 0) });
}
