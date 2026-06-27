import { prisma } from "@/lib/db";
import ModerateQueue from "@/components/ModerateQueue";
import Icon from "@/components/Icon";

export const dynamic = "force-dynamic";

export default async function ModeratePage() {
  const [pending, subjects, approvedCount, rejectedCount] = await Promise.all([
    prisma.question.findMany({
      where: { status: "pending" },
      orderBy: [{ confidence: "asc" }, { createdAt: "asc" }], // most doubtful first
      include: { paper: true },
    }),
    prisma.subject.findMany({
      orderBy: { name: "asc" },
      include: { topics: { orderBy: [{ form: "asc" }, { chapter: "asc" }] } },
    }),
    prisma.question.count({ where: { status: "approved" } }),
    prisma.question.count({ where: { status: "rejected" } }),
  ]);

  const items = pending.map((q) => ({
    id: q.id,
    stem: q.stem,
    questionType: q.questionType,
    paperNumber: q.paperNumber,
    marks: q.marks,
    isKbat: q.isKbat,
    subjectId: q.subjectId,
    topicId: q.topicId,
    paperTitle: q.paper?.title ?? null,
    confidence: q.confidence,
  }));

  const subjectsLite = subjects.map((s) => ({
    id: s.id,
    name: s.name,
    topics: s.topics.map((t) => ({ id: t.id, form: t.form, chapter: t.chapter, title: t.title })),
  }));

  return (
    <div className="space-y-5">
      <div>
        <h1 className="inline-flex items-center gap-2 text-2xl font-bold">Review queue <Icon name="check" className="h-6 w-6 text-emerald-600" /></h1>
        <p className="text-sm text-slate-500">
          High-confidence questions are auto-approved; these fell below the threshold. Verify the
          subject, form & topic, then approve or reject before they go live to students.
        </p>
      </div>

      <div className="grid grid-cols-3 gap-3">
        <div className="card p-4 text-center">
          <div className="text-2xl font-bold text-amber-600">{items.length}</div>
          <div className="text-xs text-slate-500">Pending</div>
        </div>
        <div className="card p-4 text-center">
          <div className="text-2xl font-bold text-emerald-600">{approvedCount}</div>
          <div className="text-xs text-slate-500">Approved</div>
        </div>
        <div className="card p-4 text-center">
          <div className="text-2xl font-bold text-red-500">{rejectedCount}</div>
          <div className="text-xs text-slate-500">Rejected</div>
        </div>
      </div>

      <ModerateQueue items={items} subjects={subjectsLite} />
    </div>
  );
}
