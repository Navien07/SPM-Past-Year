// Synthetic end-to-end test of the import pipeline against the local DB.
// Exercises: idempotent upsert by sourceKey, pre-parsed question creation,
// KSSM topic auto-linking, validation (approved vs pending), and re-import.
import { PrismaClient } from "@prisma/client";
import { normPaperType, normType, subjectResolver, topicResolver, questionIssues, importStatus } from "../src/lib/import";

const prisma = new PrismaClient();

async function importPapers(papers: any[]) {
  const resolveSubject = await subjectResolver();
  let created = 0, updated = 0, approved = 0, pending = 0, qCreated = 0;
  for (const p of papers) {
    const subjectId = resolveSubject(p.subject);
    if (!subjectId) { console.log("  SKIP unknown subject", p.subject); continue; }
    const sourceKey = String(p.sourceKey);
    const data = {
      title: p.title, subjectId, paperType: normPaperType(p.paperType), year: Number(p.year),
      state: p.state ?? null, paperNumber: Number(p.paperNumber) || 1, status: "categorized",
      categorizedAt: new Date(), sourceKey,
    };
    const existing = await prisma.paper.findUnique({ where: { sourceKey } });
    let paperId: string;
    if (existing) { await prisma.paper.update({ where: { id: existing.id }, data }); paperId = existing.id; updated++; await prisma.question.deleteMany({ where: { paperId } }); }
    else { const paper = await prisma.paper.create({ data }); paperId = paper.id; created++; }
    const resolveTopic = await topicResolver(subjectId);
    for (const raw of p.questions ?? []) {
      const qType = normType(raw.type);
      const options = raw.options ?? [];
      const topicId = resolveTopic({ topicTitle: raw.topicTitle, form: raw.form, chapter: raw.chapter });
      const issues = questionIssues({ questionType: qType, stem: raw.stem ?? "", options, answer: raw.answer ?? null, markingScheme: raw.markingScheme ?? null, marks: Number(raw.marks) || 0, topicId });
      const status = importStatus(issues);
      await prisma.question.create({ data: {
        subjectId, topicId, paperId, paperNumber: Number(p.paperNumber) || 1, questionType: qType,
        number: raw.number ?? null, stem: raw.stem ?? "", options: JSON.stringify(options),
        answer: raw.answer ?? null, markingScheme: raw.markingScheme ?? null, marks: Number(raw.marks) || 1,
        isKbat: !!raw.isKbat, year: Number(p.year), source: "past_paper", status,
        confidence: status === "approved" ? 0.95 : 0.6, autoApproved: status === "approved",
        reviewNote: issues.length ? issues.join("; ") : null,
      }});
      qCreated++; status === "approved" ? approved++ : pending++;
    }
  }
  return { created, updated, approved, pending, qCreated };
}

const batch = [
  {
    sourceKey: "smoke-addmate-2024-k1", title: "SMOKE Add Maths K1 2024", subject: "ADDMATE",
    paperType: "sebenar", year: 2024, paperNumber: 1,
    questions: [
      { number: "1", type: "structured", stem: "Diberi f(x)=3x+1, cari f⁻¹(x).", answer: "f⁻¹(x)=(x−1)/3", marks: 2, form: 4, chapter: 1, topicTitle: "Fungsi" }, // clean → approved, links T4 Bab1
      { number: "2", type: "mcq", stem: "Terbitan bagi y=x² ialah?", options: [{key:"A",text:"x"},{key:"B",text:"2x"}], answer: "B", marks: 1, form: 5, chapter: 2 }, // links via form+chapter (Pembezaan)
      { number: "3", type: "mcq", stem: "Bad question no answer", options: [{key:"A",text:"a"}], marks: 1 }, // invalid → pending
    ],
  },
  {
    sourceKey: "smoke-bad-subject", title: "X", subject: "ZZZ", paperType: "trial", year: 2024, paperNumber: 1, questions: [],
  },
];

(async () => {
  console.log("Run 1 (create):");
  console.log(" ", await importPapers(batch));
  console.log("Run 2 (re-import same sourceKeys — should UPDATE, not duplicate):");
  console.log(" ", await importPapers(batch));

  const papers = await prisma.paper.count({ where: { sourceKey: { startsWith: "smoke-" } } });
  const qs = await prisma.question.findMany({ where: { paper: { sourceKey: { startsWith: "smoke-" } } }, select: { stem: true, status: true, topicId: true } });
  console.log(`\nPapers with smoke- key: ${papers} (expect 1 — bad subject skipped, no dupes)`);
  console.log(`Questions: ${qs.length} (expect 3 — replaced, not duplicated)`);
  console.log("  approved:", qs.filter(q => q.status === "approved").length, "| pending:", qs.filter(q => q.status === "pending").length);
  console.log("  linked to topic:", qs.filter(q => q.topicId).length, "/ 3");

  // cleanup
  await prisma.question.deleteMany({ where: { paper: { sourceKey: { startsWith: "smoke-" } } } });
  await prisma.paper.deleteMany({ where: { sourceKey: { startsWith: "smoke-" } } });
  console.log("\nCleaned up. ✅");
  await prisma.$disconnect();
})().catch((e) => { console.error(e); process.exit(1); });
