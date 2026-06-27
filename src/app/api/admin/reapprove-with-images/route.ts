import { NextRequest, NextResponse } from "next/server";
import { prisma } from "@/lib/db";
import { authorizeImport } from "@/lib/importAuth";
import { logActivity, clientIp } from "@/lib/activity";

export const maxDuration = 60;

// After the diagram backfill, questions that were HELD (status pending, held
// because they referenced a diagram with no image) and have since received an
// image can be returned to students. Bulk re-approve: pending + has image +
// was auto-held for a missing diagram → approved.
function where() {
  return {
    status: "pending",
    reviewNote: { contains: "no image attached" },
    NOT: { images: "[]" },
  };
}

export async function GET(req: NextRequest) {
  const actor = await authorizeImport(req);
  if (!actor) return NextResponse.json({ error: "Forbidden" }, { status: 403 });
  const count = await prisma.question.count({ where: where() });
  return NextResponse.json({ count });
}

export async function POST(req: NextRequest) {
  const actor = await authorizeImport(req);
  if (!actor || actor.role === "import") return NextResponse.json({ error: "Forbidden" }, { status: 403 });
  const res = await prisma.question.updateMany({
    where: where(),
    data: { status: "approved", reviewNote: "auto: diagram image attached, re-approved" },
  });
  await logActivity({
    userId: actor.id, name: actor.name, role: actor.role,
    action: "admin.reapprove_with_images",
    detail: `Re-approved ${res.count} questions that now have images`,
    ip: clientIp(req),
  });
  return NextResponse.json({ reapproved: res.count });
}
