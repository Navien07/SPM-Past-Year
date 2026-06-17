import { NextResponse } from "next/server";
import { prisma } from "@/lib/db";

export const dynamic = "force-dynamic";

// Safe diagnostics — returns 200 with a JSON report so deploy issues are
// visible without server logs and without exposing secrets.
function redact(s: string): string {
  return s.replace(/\/\/[^@\s/]+@/g, "//***:***@").slice(0, 500);
}

export async function GET() {
  const url = process.env.DATABASE_URL || "";
  // Inspect the connection-string SHAPE only (never the password).
  const shape = {
    set: !!url,
    usesPgbouncerFlag: /[?&]pgbouncer=true/.test(url),
    port: (url.match(/:(\d{4,5})\//) || [])[1] || "unknown",
    isPooler: /pooler\.supabase\.com/.test(url),
    hasConnectionLimit: /connection_limit=/.test(url),
  };

  const report: Record<string, unknown> = {
    env: {
      DATABASE_URL: url ? "set" : "MISSING",
      DIRECT_URL: process.env.DIRECT_URL ? "set" : "MISSING",
      ANTHROPIC_API_KEY: process.env.ANTHROPIC_API_KEY ? "set" : "missing (AI offline)",
      SPM_AI_MODEL: process.env.SPM_AI_MODEL || "default",
    },
    connectionShape: shape,
  };

  // Warn about the #1 Vercel+Supabase 500 cause.
  if (shape.set && shape.port === "6543" && !shape.usesPgbouncerFlag) {
    report.warning =
      "DATABASE_URL uses the transaction pooler (6543) WITHOUT ?pgbouncer=true. " +
      "Prisma's prepared statements break under PgBouncer transaction mode — pages with " +
      "concurrent queries (e.g. /admin) will 500. Append ?pgbouncer=true&connection_limit=1.";
  }

  // 1. Connectivity
  try {
    await prisma.$queryRaw`SELECT 1`;
    report.dbConnect = "ok";
  } catch (e) {
    report.dbConnect = "FAILED";
    report.error = redact(e instanceof Error ? e.message : String(e));
    return NextResponse.json(report, { status: 200 });
  }

  // 2. Concurrency test — reproduces what /admin does (multiple parallel queries).
  try {
    const [users, students, questions, payments, enrollments, knowledge] = await Promise.all([
      prisma.user.count(),
      prisma.student.count(),
      prisma.question.count(),
      prisma.payment.count(),
      prisma.enrollment.count(),
      prisma.knowledgeDoc.count(),
    ]);
    report.tables = "ok";
    report.counts = { users, students, questions, payments, enrollments, knowledge };
    report.seeded = users > 0;
  } catch (e) {
    report.tables = "FAILED";
    const msg = e instanceof Error ? e.message : String(e);
    report.error = redact(msg);
    if (/prepared statement/i.test(msg)) {
      report.hint =
        "PgBouncer prepared-statement error → add ?pgbouncer=true&connection_limit=1 to DATABASE_URL and redeploy.";
    } else if (/does not exist|relation/i.test(msg)) {
      report.hint = "A table is missing → re-run the latest supabase_setup.sql (it's self-resetting).";
    }
  }

  return NextResponse.json(report, { status: 200 });
}
