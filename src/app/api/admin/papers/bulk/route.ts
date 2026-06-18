import { NextRequest, NextResponse } from "next/server";
import { prisma } from "@/lib/db";
import { getCurrentUser } from "@/lib/auth";
import { logActivity, clientIp } from "@/lib/activity";

export const maxDuration = 60;

// Map scraper paper-type labels to our enum; the source (MRSM/SBP/state/YIK)
// goes into `state`.
function normType(t?: string): string {
  const s = (t || "").toLowerCase();
  if (s.includes("real") || s.includes("sebenar") || s === "past_year" || s === "spm") return "past_year";
  if (s.includes("mock")) return "mock";
  if (s.includes("state") || s.includes("negeri")) return "state";
  return "trial"; // trial / percubaan / MRSM / SBP / YIK
}

// Bulk-create papers from the scraper. Each item carries the question text
// (rawText, e.g. from K1) and the answer/marking text (markingScheme, e.g.
// K1_Jawapan). Categorization (AI) is run per-paper afterwards via
// POST /api/papers/[id]/categorize to avoid long requests.
export async function POST(req: NextRequest) {
  const admin = await getCurrentUser();
  if (!admin || admin.role !== "admin") return NextResponse.json({ error: "Forbidden" }, { status: 403 });

  const body = await req.json();
  const papers = Array.isArray(body.papers) ? body.papers : [];
  if (papers.length === 0) return NextResponse.json({ error: "Provide a non-empty `papers` array." }, { status: 400 });
  if (papers.length > 200) return NextResponse.json({ error: "Max 200 papers per request." }, { status: 400 });

  // Resolve subjects by code or name (case-insensitive).
  const subjects = await prisma.subject.findMany();
  const byCode = new Map(subjects.map((s) => [s.code.toLowerCase(), s.id]));
  const byName = new Map(subjects.map((s) => [s.name.toLowerCase(), s.id]));

  const created: { id: string; title: string; subject: string }[] = [];
  const skipped: { title?: string; reason: string }[] = [];

  for (const p of papers) {
    const key = String(p.subject || p.subjectCode || "").toLowerCase().trim();
    const subjectId = p.subjectId || byCode.get(key) || byName.get(key);
    if (!subjectId) {
      skipped.push({ title: p.title, reason: `Unknown subject: ${p.subject ?? p.subjectId ?? "?"}` });
      continue;
    }
    if (!p.year) {
      skipped.push({ title: p.title, reason: "Missing year" });
      continue;
    }
    const paper = await prisma.paper.create({
      data: {
        title: String(p.title || `${p.subject} ${p.year} ${p.state ?? ""} K${p.paperNumber ?? 1}`).slice(0, 200),
        subjectId,
        paperType: normType(p.paperType),
        year: Number(p.year),
        state: p.state ? String(p.state).slice(0, 60) : null,
        paperNumber: Number(p.paperNumber) || 1,
        rawText: p.rawText ? String(p.rawText) : null,
        markingScheme: p.markingScheme ? String(p.markingScheme) : null,
        fileName: p.fileName ? String(p.fileName) : null,
        status: "uploaded",
      },
    });
    created.push({ id: paper.id, title: paper.title, subject: key });
  }

  await logActivity({ userId: admin.id, name: admin.name, role: "admin", action: "papers.bulk_import", detail: `${created.length} created, ${skipped.length} skipped`, ip: clientIp(req) });

  return NextResponse.json({
    created: created.length,
    skipped: skipped.length,
    skippedDetail: skipped.slice(0, 50),
    ids: created.map((c) => c.id),
    note: "Now categorize each: POST /api/papers/{id}/categorize",
  });
}
