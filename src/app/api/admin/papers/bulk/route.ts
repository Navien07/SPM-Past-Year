import { NextRequest, NextResponse } from "next/server";
import { prisma } from "@/lib/db";
import { getCurrentUser } from "@/lib/auth";
import { logActivity, clientIp } from "@/lib/activity";
import {
  normPaperType, normType, subjectResolver, topicResolver,
  questionIssues, importStatus, type ParsedQuestion,
} from "@/lib/import";

export const maxDuration = 60;

// Stable key for idempotent re-import when the scraper didn't supply one.
function deriveKey(p: Record<string, unknown>, subjectCode: string): string {
  return [subjectCode, p.paperType, p.year, p.paperNumber ?? 1, p.state ?? "", p.title ?? p.fileName ?? ""]
    .join("|").toLowerCase().replace(/\s+/g, " ").slice(0, 300);
}

function hasParsedAny(papers: unknown[]): boolean {
  return papers.some((p) => Array.isArray((p as { questions?: unknown[] }).questions) && (p as { questions: unknown[] }).questions.length > 0);
}

// Bulk-create/update papers from the scraper. Re-running with the same
// `sourceKey` updates the paper in place (no duplicates). If a paper carries a
// pre-parsed `questions[]`, the questions are created directly (no AI) with
// KSSM topic auto-linking + validation; otherwise the paper keeps rawText +
// markingScheme for later AI categorization.
export async function POST(req: NextRequest) {
  const admin = await getCurrentUser();
  if (!admin || (admin.role !== "admin" && admin.role !== "teacher")) {
    return NextResponse.json({ error: "Forbidden" }, { status: 403 });
  }

  const body = await req.json();
  const papers = Array.isArray(body.papers) ? body.papers : [];
  if (papers.length === 0) return NextResponse.json({ error: "Provide a non-empty `papers` array." }, { status: 400 });
  if (papers.length > 500) return NextResponse.json({ error: "Max 500 papers per request." }, { status: 400 });

  const resolveSubject = await subjectResolver();
  const topicResolvers = new Map<string, Awaited<ReturnType<typeof topicResolver>>>();
  async function getTopicResolver(subjectId: string) {
    let r = topicResolvers.get(subjectId);
    if (!r) { r = await topicResolver(subjectId); topicResolvers.set(subjectId, r); }
    return r;
  }

  let created = 0, updated = 0, questionsCreated = 0, approved = 0, pending = 0;
  const skipped: { title?: string; reason: string }[] = [];
  const ids: string[] = [];

  for (const p of papers) {
    const subjectId = p.subjectId || resolveSubject(p.subject ?? p.subjectCode);
    if (!subjectId) { skipped.push({ title: p.title, reason: `Unknown subject: ${p.subject ?? "?"}` }); continue; }
    if (!p.year) { skipped.push({ title: p.title, reason: "Missing year" }); continue; }

    const subjectCode = String(p.subject ?? p.subjectCode ?? "").toUpperCase();
    const sourceKey = String(p.sourceKey || deriveKey(p, subjectCode)).slice(0, 300);
    const hasParsed = Array.isArray(p.questions) && p.questions.length > 0;

    const data = {
      title: String(p.title || `${p.subject} ${p.year} ${p.state ?? ""} K${p.paperNumber ?? 1}`).trim().slice(0, 200),
      subjectId,
      paperType: normPaperType(p.paperType),
      year: Number(p.year),
      state: p.state ? String(p.state).slice(0, 60) : null,
      paperNumber: Number(p.paperNumber) || 1,
      rawText: p.rawText ? String(p.rawText) : null,
      markingScheme: p.markingScheme ? String(p.markingScheme) : null,
      fileName: p.fileName ? String(p.fileName) : null,
      sourceUrl: p.sourceUrl ? String(p.sourceUrl).slice(0, 500) : null,
      language: p.language ? String(p.language).slice(0, 5) : null,
      status: hasParsed ? "categorized" : "uploaded",
      categorizedAt: hasParsed ? new Date() : null,
    };

    const existing = await prisma.paper.findUnique({ where: { sourceKey } });
    let paperId: string;
    if (existing) {
      await prisma.paper.update({ where: { id: existing.id }, data });
      paperId = existing.id;
      updated++;
      if (hasParsed) await prisma.question.deleteMany({ where: { paperId } }); // replace on re-import
    } else {
      const paper = await prisma.paper.create({ data: { ...data, sourceKey } });
      paperId = paper.id;
      created++;
    }
    ids.push(paperId);

    if (hasParsed) {
      const resolveTopic = await getTopicResolver(subjectId);
      for (const raw of p.questions as ParsedQuestion[]) {
        const qType = normType(raw.type);
        const options = Array.isArray(raw.options) ? raw.options : [];
        const topicId = resolveTopic({ topicTitle: raw.topicTitle, form: raw.form, chapter: raw.chapter });
        const issues = questionIssues({
          questionType: qType, stem: String(raw.stem ?? ""), options,
          answer: raw.answer ?? null, markingScheme: raw.markingScheme ?? null,
          marks: Number(raw.marks) || 0, topicId,
        });
        const status = importStatus(issues, raw.confidence);
        await prisma.question.create({
          data: {
            subjectId, topicId, paperId, paperNumber: Number(p.paperNumber) || 1,
            questionType: qType, number: raw.number ? String(raw.number) : null,
            stem: String(raw.stem ?? ""), options: JSON.stringify(options),
            answer: raw.answer ? String(raw.answer) : null,
            markingScheme: raw.markingScheme ? String(raw.markingScheme) : null,
            marks: Number(raw.marks) || 1, isKbat: !!raw.isKbat,
            subtopic: raw.subtopic ? String(raw.subtopic) : null, year: Number(p.year),
            source: "past_paper", status,
            confidence: raw.confidence ?? (status === "approved" ? 0.95 : 0.6),
            autoApproved: status === "approved",
            reviewNote: issues.length ? issues.join("; ") : null,
          },
        });
        questionsCreated++;
        status === "approved" ? approved++ : pending++;
      }
    }
  }

  await logActivity({ userId: admin.id, name: admin.name, role: admin.role, action: "papers.bulk_import",
    detail: `${created} created, ${updated} updated, ${questionsCreated} questions (${approved} approved/${pending} pending), ${skipped.length} skipped`, ip: clientIp(req) });

  return NextResponse.json({
    created, updated, skipped: skipped.length, questionsCreated, approved, pending,
    skippedDetail: skipped.slice(0, 50), ids,
    note: hasParsedAny(papers)
      ? "Pre-parsed questions imported. Empty/invalid ones are 'pending' — check the QA dashboard (/admin/qa)."
      : "Papers stored. Categorize each with AI: POST /api/papers/{id}/categorize",
  });
}
