import { NextRequest, NextResponse } from "next/server";
import { randomUUID } from "crypto";
import { prisma } from "@/lib/db";
import { authorizeImport } from "@/lib/importAuth";
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

function chunk<T>(arr: T[], n: number): T[][] {
  const out: T[][] = [];
  for (let i = 0; i < arr.length; i += n) out.push(arr.slice(i, i + n));
  return out;
}

// Bulk-create/update papers from the scraper. Idempotent by `sourceKey`.
// Optimised for throughput: bulk existence check, client-generated ids, and
// createMany for papers + questions (a few round-trips per batch, not per row),
// so large batches finish well within the function timeout.
export async function POST(req: NextRequest) {
  const admin = await authorizeImport(req);
  if (!admin) return NextResponse.json({ error: "Forbidden" }, { status: 403 });

  const body = await req.json();
  const papers = Array.isArray(body.papers) ? body.papers : [];
  if (papers.length === 0) return NextResponse.json({ error: "Provide a non-empty `papers` array." }, { status: 400 });
  if (papers.length > 500) return NextResponse.json({ error: "Max 500 papers per request." }, { status: 400 });

  const resolveSubject = await subjectResolver();

  // 1. Validate + dedupe inputs (skip unknown subject / missing year / in-batch dup key).
  interface Prepared {
    sourceKey: string; subjectId: string; year: number; paperNumber: number;
    provided: boolean; hasParsed: boolean; rawQuestions: ParsedQuestion[]; data: Record<string, unknown>;
  }
  const prepared: Prepared[] = [];
  const skipped: { title?: string; reason: string }[] = [];
  const seen = new Set<string>();
  let anyParsed = false;

  for (const p of papers) {
    const subjectId = p.subjectId || resolveSubject(p.subject ?? p.subjectCode);
    if (!subjectId) { skipped.push({ title: p.title, reason: `Unknown subject: ${p.subject ?? "?"}` }); continue; }
    if (!p.year) { skipped.push({ title: p.title, reason: "Missing year" }); continue; }
    const subjectCode = String(p.subject ?? p.subjectCode ?? "").toUpperCase();
    const sourceKey = String(p.sourceKey || deriveKey(p, subjectCode)).slice(0, 300);
    if (seen.has(sourceKey)) { skipped.push({ title: p.title, reason: "Duplicate sourceKey in batch" }); continue; }
    seen.add(sourceKey);

    // `provided` = a questions array was sent at all (even empty). That makes
    // it authoritative: on re-import we REPLACE the paper's questions with it,
    // so sending [] prunes a paper's questions to zero (clears earlier noise).
    const provided = Array.isArray(p.questions);
    const hasParsed = provided && p.questions.length > 0;
    if (hasParsed) anyParsed = true;
    prepared.push({
      sourceKey, subjectId, year: Number(p.year), paperNumber: Number(p.paperNumber) || 1,
      provided, hasParsed, rawQuestions: hasParsed ? (p.questions as ParsedQuestion[]) : [],
      data: {
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
      },
    });
  }

  if (prepared.length === 0) {
    return NextResponse.json({ created: 0, updated: 0, questionsCreated: 0, approved: 0, pending: 0, skipped: skipped.length, skippedDetail: skipped.slice(0, 50), ids: [] });
  }

  // 2. Topic resolvers for the distinct subjects in this batch (one query each,
  //    sequential to use a single DB connection at a time).
  const distinctSubjects = [...new Set(prepared.map((p) => p.subjectId))];
  const resolvers = new Map<string, Awaited<ReturnType<typeof topicResolver>>>();
  for (const sid of distinctSubjects) resolvers.set(sid, await topicResolver(sid));

  // 3. Bulk existence check by sourceKey.
  const existing = await prisma.paper.findMany({
    where: { sourceKey: { in: prepared.map((p) => p.sourceKey) } },
    select: { id: true, sourceKey: true },
  });
  const idByKey = new Map(existing.map((e) => [e.sourceKey!, e.id]));

  // 4. Build paper + question write sets in memory.
  const toCreatePapers: Record<string, unknown>[] = [];
  const toUpdatePapers: { id: string; data: Record<string, unknown> }[] = [];
  const reimportPaperIds: string[] = [];
  const questionRows: Record<string, unknown>[] = [];
  const ids: string[] = [];
  let created = 0, updated = 0, approved = 0, pending = 0;

  for (const pr of prepared) {
    const existingId = idByKey.get(pr.sourceKey);
    const paperId = existingId ?? randomUUID();
    ids.push(paperId);
    if (existingId) {
      updated++;
      toUpdatePapers.push({ id: existingId, data: pr.data });
      if (pr.provided) reimportPaperIds.push(existingId); // replace questions (even with none)
    } else {
      created++;
      toCreatePapers.push({ id: paperId, sourceKey: pr.sourceKey, ...pr.data });
    }

    if (pr.hasParsed) {
      const resolveTopic = resolvers.get(pr.subjectId)!;
      for (const raw of pr.rawQuestions) {
        const qType = normType(raw.type);
        const options = Array.isArray(raw.options) ? raw.options : [];
        const topicId = resolveTopic({ topicTitle: raw.topicTitle, form: raw.form, chapter: raw.chapter });
        const issues = questionIssues({
          questionType: qType, stem: String(raw.stem ?? ""), options,
          answer: raw.answer ?? null, markingScheme: raw.markingScheme ?? null,
          marks: Number(raw.marks) || 0, topicId,
        });
        const status = importStatus(issues, raw.confidence);
        questionRows.push({
          subjectId: pr.subjectId, topicId, paperId, paperNumber: pr.paperNumber,
          questionType: qType, number: raw.number ? String(raw.number) : null,
          stem: String(raw.stem ?? ""), options: JSON.stringify(options),
          answer: raw.answer ? String(raw.answer) : null,
          markingScheme: raw.markingScheme ? String(raw.markingScheme) : null,
          marks: Number(raw.marks) || 1, isKbat: !!raw.isKbat,
          subtopic: raw.subtopic ? String(raw.subtopic) : null, year: pr.year,
          source: "past_paper", status,
          confidence: raw.confidence ?? (status === "approved" ? 0.95 : 0.6),
          autoApproved: status === "approved",
          reviewNote: issues.length ? issues.join("; ") : null,
        });
        status === "approved" ? approved++ : pending++;
      }
    }
  }

  // 5. Execute writes sequentially (one connection at a time). Papers first
  //    (FK), then update existing, clear their old questions, then insert.
  if (toCreatePapers.length) {
    for (const c of chunk(toCreatePapers, 200)) await prisma.paper.createMany({ data: c as never, skipDuplicates: true });
  }
  for (const u of toUpdatePapers) await prisma.paper.update({ where: { id: u.id }, data: u.data });
  if (reimportPaperIds.length) await prisma.question.deleteMany({ where: { paperId: { in: reimportPaperIds } } });
  if (questionRows.length) {
    for (const c of chunk(questionRows, 500)) await prisma.question.createMany({ data: c as never });
  }

  await logActivity({ userId: admin.id ?? undefined, name: admin.name, role: admin.role, action: "papers.bulk_import",
    detail: `${created} created, ${updated} updated, ${questionRows.length} questions (${approved} approved/${pending} pending), ${skipped.length} skipped`, ip: clientIp(req) });

  return NextResponse.json({
    created, updated, skipped: skipped.length, questionsCreated: questionRows.length, approved, pending,
    skippedDetail: skipped.slice(0, 50), ids,
    note: anyParsed
      ? "Pre-parsed questions imported. Empty/invalid ones are 'pending' — check the QA dashboard (/admin/qa)."
      : "Papers stored. Categorize each with AI: POST /api/papers/{id}/categorize",
  });
}
