import { NextRequest, NextResponse } from "next/server";
import { prisma } from "@/lib/db";
import { authorizeImport } from "@/lib/importAuth";

export const maxDuration = 30;

// Preflight for the bulk importer: verify auth BEFORE sending thousands of
// papers. GET with `Authorization: Bearer <IMPORT_TOKEN>`.
//   200 → token works (or you're a logged-in admin), with live counts
//   401 → tells you whether IMPORT_TOKEN is missing server-side or just wrong
export async function GET(req: NextRequest) {
  const tokenConfigured = !!(process.env.IMPORT_TOKEN && process.env.IMPORT_TOKEN.length >= 16);
  const actor = await authorizeImport(req);

  if (!actor) {
    return NextResponse.json(
      {
        ok: false,
        tokenConfigured,
        hint: tokenConfigured
          ? "IMPORT_TOKEN is set on the server, but your Bearer token doesn't match. Send header exactly: `Authorization: Bearer <token>` and confirm the value matches Vercel."
          : "IMPORT_TOKEN is NOT set on this deployment. Add it in Vercel → Settings → Environment Variables (Production), then REDEPLOY (env changes need a fresh deploy).",
      },
      { status: 401 },
    );
  }

  let papers = 0, questions = 0, knowledge = 0;
  try {
    [papers, questions, knowledge] = await Promise.all([
      prisma.paper.count(), prisma.question.count(), prisma.knowledgeDoc.count(),
    ]);
  } catch {
    /* DB may be unavailable; auth result is the point of this endpoint */
  }
  return NextResponse.json({ ok: true, authedAs: actor.role, tokenConfigured, counts: { papers, questions, knowledge } });
}
