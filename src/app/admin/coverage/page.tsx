import Link from "next/link";
import { prisma } from "@/lib/db";
import Icon from "@/components/Icon";

export const dynamic = "force-dynamic";
export const maxDuration = 60;

// Syllabus coverage: how many approved questions each subject/form/topic has,
// and which KSSM topics are still empty, so we can see the whole syllabus is
// covered after a content load.
export default async function CoveragePage() {
  const subjects = await prisma.subject.findMany({ orderBy: { name: "asc" }, select: { id: true, name: true, code: true } });

  const topics = await prisma.topic.findMany({
    orderBy: [{ subjectId: "asc" }, { form: "asc" }, { chapter: "asc" }],
    include: { _count: { select: { questions: { where: { status: "approved" } } } } },
  });

  const [untaggedQ, approvedTotal, pendingTotal] = await Promise.all([
    prisma.question.count({ where: { topicId: null } }),
    prisma.question.count({ where: { status: "approved" } }),
    prisma.question.count({ where: { status: "pending" } }),
  ]);

  const bySubject = new Map<string, typeof topics>();
  for (const t of topics) {
    const arr = bySubject.get(t.subjectId) ?? [];
    arr.push(t);
    bySubject.set(t.subjectId, arr);
  }

  return (
    <div className="space-y-6">
      <div className="flex items-end justify-between gap-3">
        <div>
          <h1 className="flex items-center gap-2 text-2xl font-bold"><Icon name="map" className="h-6 w-6" /> Syllabus coverage</h1>
          <p className="text-sm text-slate-500">Approved questions per KSSM topic. Empty topics are flagged red.</p>
        </div>
        <Link href="/admin/imports" className="btn-ghost shrink-0 gap-2"><Icon name="download" className="h-4 w-4" /> Imports & tagging</Link>
      </div>

      <section className="grid grid-cols-2 gap-3 sm:grid-cols-4">
        <div className="card p-4 text-center"><div className="text-2xl font-bold text-emerald-700">{approvedTotal.toLocaleString("en-MY")}</div><div className="mt-1 text-xs text-slate-500">Approved</div></div>
        <Link href="/admin/qa" className="card p-4 text-center"><div className="text-2xl font-bold text-amber-700">{pendingTotal.toLocaleString("en-MY")}</div><div className="mt-1 text-xs text-slate-500">Pending QA</div></Link>
        <Link href="/admin/imports" className="card p-4 text-center"><div className={`text-2xl font-bold ${untaggedQ > 0 ? "text-red-600" : "text-emerald-700"}`}>{untaggedQ.toLocaleString("en-MY")}</div><div className="mt-1 text-xs text-slate-500">Untagged (need topic)</div></Link>
        <div className="card p-4 text-center"><div className="text-2xl font-bold text-brand-700">{topics.filter((t) => t._count.questions === 0).length}</div><div className="mt-1 text-xs text-slate-500">Empty topics</div></div>
      </section>

      {subjects.map((s) => {
        const list = bySubject.get(s.id) ?? [];
        const total = list.reduce((a, t) => a + t._count.questions, 0);
        const empty = list.filter((t) => t._count.questions === 0).length;
        return (
          <section key={s.id}>
            <h2 className="mb-2 flex items-center justify-between text-sm font-bold uppercase tracking-wide text-slate-500">
              <span>{s.name}</span>
              <span className="font-normal normal-case text-slate-400">{total} questions · {empty} empty topic{empty === 1 ? "" : "s"}</span>
            </h2>
            <div className="card divide-y divide-slate-100">
              {list.map((t) => (
                <div key={t.id} className="flex items-center justify-between gap-3 px-4 py-2 text-sm">
                  <span className="min-w-0">
                    <span className="text-xs text-slate-400">T{t.form} · Bab {t.chapter}</span>{" "}
                    <span className="truncate">{t.title}</span>
                  </span>
                  <span className={`badge shrink-0 ${t._count.questions === 0 ? "bg-red-100 text-red-700" : t._count.questions < 5 ? "bg-amber-100 text-amber-800" : "bg-emerald-100 text-emerald-700"}`}>
                    {t._count.questions}
                  </span>
                </div>
              ))}
              {list.length === 0 && <p className="p-4 text-sm text-slate-400">No topics.</p>}
            </div>
          </section>
        );
      })}
    </div>
  );
}
