import { NextResponse } from "next/server";
import { prisma } from "@/lib/db";

export const dynamic = "force-dynamic";

// Safe diagnostics endpoint — returns 200 with a JSON report so you can see why
// the app is failing without exposing secrets or reading Vercel logs.
// Visit: https://<your-app>/api/health
function redact(s: string): string {
  // Strip any user:password@ that may appear in a connection error.
  return s.replace(/\/\/[^@\s/]+@/g, "//***:***@").slice(0, 400);
}

export async function GET() {
  const report: Record<string, unknown> = {
    env: {
      DATABASE_URL: process.env.DATABASE_URL ? "set" : "MISSING",
      DIRECT_URL: process.env.DIRECT_URL ? "set" : "MISSING",
      ANTHROPIC_API_KEY: process.env.ANTHROPIC_API_KEY ? "set" : "missing (AI offline)",
      SPM_AI_MODEL: process.env.SPM_AI_MODEL || "default",
    },
  };

  // 1. Can we connect at all?
  try {
    await prisma.$queryRaw`SELECT 1`;
    report.dbConnect = "ok";
  } catch (e) {
    report.dbConnect = "FAILED";
    report.hint =
      "Check DATABASE_URL — is the password filled in? Use the transaction pooler (6543) with ?pgbouncer=true.";
    report.error = redact(e instanceof Error ? e.message : String(e));
    return NextResponse.json(report, { status: 200 });
  }

  // 2. Do the tables exist + is it seeded?
  try {
    const subjects = await prisma.subject.count();
    const questions = await prisma.question.count();
    report.tables = "ok";
    report.subjects = subjects;
    report.questions = questions;
    report.seeded = subjects > 0;
    if (subjects === 0) {
      report.hint = "Tables exist but empty — run `npm run db:deploy` against Supabase to seed.";
    }
  } catch (e) {
    report.tables = "MISSING";
    report.hint =
      "Connected, but tables don't exist. Run `npm run db:deploy` (prisma db push + seed) against Supabase.";
    report.error = redact(e instanceof Error ? e.message : String(e));
  }

  return NextResponse.json(report, { status: 200 });
}
