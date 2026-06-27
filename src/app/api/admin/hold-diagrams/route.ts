import { NextRequest, NextResponse } from "next/server";
import { prisma } from "@/lib/db";
import { authorizeImport } from "@/lib/importAuth";
import { logActivity, clientIp } from "@/lib/activity";

export const maxDuration = 60;

// Questions whose text refers to a visual but have no image attached can't be
// answered. We move them to "pending" (held — students only see "approved"),
// so they're hidden until the diagram is backfilled, then re-approved.
const DIAGRAM_WORDS = [
  "rajah", "gambar rajah", "graf", "jadual", "carta", "peta",
  "diagram", "figure", "graph", "chart", "shown below", "shown above",
  "berdasarkan rajah", "merujuk rajah", "the table shows", "jadual di",
];

function diagramWhere() {
  return {
    status: "approved",
    source: "past_paper",
    images: "[]", // no image attached
    OR: DIAGRAM_WORDS.map((w) => ({ stem: { contains: w, mode: "insensitive" as const } })),
  };
}

export async function GET(req: NextRequest) {
  const actor = await authorizeImport(req);
  if (!actor) return NextResponse.json({ error: "Forbidden" }, { status: 403 });
  const count = await prisma.question.count({ where: diagramWhere() });
  return NextResponse.json({ count });
}

export async function POST(req: NextRequest) {
  const actor = await authorizeImport(req);
  if (!actor || actor.role === "import") return NextResponse.json({ error: "Forbidden" }, { status: 403 });
  const res = await prisma.question.updateMany({
    where: diagramWhere(),
    data: { status: "pending", reviewNote: "auto: refers to a diagram/figure but no image attached" },
  });
  await logActivity({
    userId: actor.id, name: actor.name, role: actor.role,
    action: "admin.hold_diagrams",
    detail: `Held ${res.count} diagram-dependent questions`,
    ip: clientIp(req),
  });
  return NextResponse.json({ held: res.count });
}
