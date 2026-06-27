import { NextRequest, NextResponse } from "next/server";
import { prisma } from "@/lib/db";
import { authorizeImport } from "@/lib/importAuth";
import { logActivity, clientIp } from "@/lib/activity";

export const maxDuration = 60;

// Quarantine questions that were extracted from contaminated source papers
// (answered scripts / mis-filed marking schemes / unclear). Given a list of
// paper sourceKeys, sets their questions' status (default "pending" = hidden
// from students, reviewable in QA; or "rejected"). Token-allowed so the
// content pipeline can run it. Idempotent.
export async function POST(req: NextRequest) {
  const actor = await authorizeImport(req);
  if (!actor) return NextResponse.json({ error: "Forbidden" }, { status: 403 });

  const body = await req.json().catch(() => ({}));
  const sourceKeys: string[] = Array.isArray(body.sourceKeys) ? body.sourceKeys.filter((s: unknown) => typeof s === "string") : [];
  const status = body.status === "rejected" ? "rejected" : "pending";
  const reason = typeof body.reason === "string" ? body.reason.slice(0, 120) : "auto: contaminated source (answered/scheme/unclear)";
  if (sourceKeys.length === 0) return NextResponse.json({ error: "Provide a non-empty `sourceKeys` array." }, { status: 400 });
  if (sourceKeys.length > 5000) return NextResponse.json({ error: "Max 5000 sourceKeys per request." }, { status: 400 });

  const papers = await prisma.paper.findMany({ where: { sourceKey: { in: sourceKeys } }, select: { id: true } });
  const paperIds = papers.map((p) => p.id);
  if (paperIds.length === 0) return NextResponse.json({ matchedPapers: 0, affected: 0 });

  const res = await prisma.question.updateMany({
    where: { paperId: { in: paperIds } },
    data: { status, reviewNote: reason },
  });

  await logActivity({
    userId: actor.id ?? undefined, name: actor.name, role: actor.role,
    action: "admin.hold_papers",
    detail: `${status} ${res.count} questions from ${paperIds.length} contaminated papers`,
    ip: clientIp(req),
  });
  return NextResponse.json({ matchedPapers: paperIds.length, affected: res.count, status });
}
