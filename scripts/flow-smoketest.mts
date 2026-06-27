// Exercises the queries behind each key flow to catch runtime errors.
import { PrismaClient } from "@prisma/client";
import { computeGameStats } from "../src/lib/gamify";
const prisma = new PrismaClient();

async function main() {
  const out: string[] = [];
  const subject = await prisma.subject.findFirst({ select: { id: true } });
  const sid = subject!.id;
  const student = await prisma.student.findFirst({ select: { id: true } });
  const stId = student!.id;

  // Practice: years groupBy + paginated question list + count
  const years = await prisma.question.groupBy({ by: ["year"], where: { subjectId: sid, year: { not: null }, status: "approved" }, _count: true, orderBy: { year: "desc" } });
  const qList = await prisma.question.findMany({ where: { subjectId: sid, status: "approved" }, orderBy: [{ paperNumber: "asc" }, { number: "asc" }], take: 48, include: { topic: true, paper: { select: { paperType: true, state: true } } } });
  const qCount = await prisma.question.count({ where: { subjectId: sid, status: "approved" } });
  out.push(`practice: ${years.length} years, page=${qList.length}/${qCount}`);

  // Search
  const search = await prisma.question.findMany({ where: { status: "approved", stem: { contains: "a", mode: "insensitive" } }, take: 50, orderBy: { year: "desc" }, include: { subject: true, topic: true, paper: { select: { paperType: true, state: true } } } });
  out.push(`search: ${search.length}`);

  // Papers list with filters + pagination
  const papers = await prisma.paper.findMany({ where: { questions: { some: { status: "approved" } } }, orderBy: [{ year: "desc" }, { createdAt: "desc" }], skip: 0, take: 30, select: { id: true, title: true, _count: { select: { questions: { where: { status: "approved" } } } } } });
  const pYears = await prisma.paper.findMany({ where: { questions: { some: { status: "approved" } } }, distinct: ["year"], orderBy: { year: "desc" }, select: { year: true } });
  out.push(`papers: ${papers.length}, distinctYears=${pYears.length}`);

  // Gamify: aggregate score + distinct practised subjects
  const scoreAgg = await prisma.attempt.aggregate({ where: { studentId: stId }, _sum: { score: true } });
  const practised = await prisma.attempt.findMany({ where: { studentId: stId }, select: { question: { select: { subjectId: true } } }, distinct: ["questionId"], take: 3000 });
  const attempts = await prisma.attempt.count({ where: { studentId: stId } });
  const g = computeGameStats({ totalScore: scoreAgg._sum.score ?? 0, attempts, streak: 3, subjectsPractised: new Set(practised.map((a) => a.question.subjectId)).size });
  out.push(`gamify: L${g.level} ${g.xp}XP ${g.levelProgress}% badges=${g.badges.filter((b) => b.earned).length}/${g.badges.length}`);

  // Syllabus: topics with counts by form
  const topics = await prisma.topic.findMany({ where: { subjectId: sid }, orderBy: [{ form: "asc" }, { chapter: "asc" }], include: { _count: { select: { questions: { where: { status: "approved" } } } } } });
  out.push(`syllabus: ${topics.length} topics`);

  // QA filters + tagger counts
  const flagged = await prisma.question.findMany({ where: { OR: [{ status: "pending" }, { reviewNote: { not: null } }, { topicId: null }] }, take: 200, select: { id: true, subjectId: true } });
  const untagged = await prisma.question.count({ where: { topicId: null } });
  out.push(`qa: flagged=${flagged.length}, untagged=${untagged}`);

  // Coverage
  const cov = await prisma.topic.findMany({ include: { _count: { select: { questions: { where: { status: "approved" } } } } } });
  out.push(`coverage: ${cov.length} topics, empty=${cov.filter((c) => c._count.questions === 0).length}`);

  console.log("FLOW SMOKE TEST — all queries ran:\n  " + out.join("\n  "));
  await prisma.$disconnect();
}
main().catch((e) => { console.error("FLOW TEST FAILED:", e); process.exit(1); });
