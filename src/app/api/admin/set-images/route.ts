import { NextRequest, NextResponse } from "next/server";
import { prisma } from "@/lib/db";
import { authorizeImport } from "@/lib/importAuth";
import { logActivity, clientIp } from "@/lib/activity";

export const maxDuration = 60;

// Surgically attach diagram/figure image URLs to EXISTING questions by id.
// No replace, no re-import — topic tags and everything else stay intact.
// Body: { items: [{ id, images: string[] }] }  (max 2000/request)
export async function POST(req: NextRequest) {
  const actor = await authorizeImport(req);
  if (!actor) return NextResponse.json({ error: "Forbidden" }, { status: 403 });

  const body = await req.json().catch(() => ({}));
  const items = Array.isArray(body.items) ? body.items : [];
  if (items.length === 0) return NextResponse.json({ error: "Provide a non-empty `items` array." }, { status: 400 });
  if (items.length > 2000) return NextResponse.json({ error: "Max 2000 items per request." }, { status: 400 });

  let updated = 0, skipped = 0, cleared = 0;
  for (const it of items) {
    const id = String(it?.id ?? "");
    if (!id) { skipped++; continue; }
    // { id, clear: true } removes images (to undo a bad batch).
    if (it?.clear === true) {
      const r = await prisma.question.updateMany({ where: { id }, data: { images: "[]" } });
      cleared += r.count;
      continue;
    }
    const images = Array.isArray(it?.images) ? it.images.filter((u: unknown) => typeof u === "string" && u) : [];
    if (images.length === 0) { skipped++; continue; }
    const r = await prisma.question.updateMany({ where: { id }, data: { images: JSON.stringify(images) } });
    updated += r.count;
  }

  await logActivity({ userId: actor.id ?? undefined, name: actor.name, role: actor.role, action: "set_images",
    detail: `${updated} questions got images`, ip: clientIp(req) });

  return NextResponse.json({ updated, cleared, skipped });
}
