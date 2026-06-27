import Link from "next/link";
import { prisma } from "@/lib/db";
import { requireStudent } from "@/lib/student";
import { getLang } from "@/lib/lang-server";
import { t } from "@/lib/i18n";
import Icon from "@/components/Icon";

export const dynamic = "force-dynamic";

type SP = Promise<{ subject?: string; view?: string; topic?: string; year?: string; q?: string; page?: string }>;

export default async function PracticePage({ searchParams }: { searchParams: SP }) {
  const student = await requireStudent();
  const sp = await searchParams;
  const lang = await getLang();

  // Question-bank search (across all approved questions).
  const search = (sp.q || "").trim();
  const searchResults = search
    ? await prisma.question.findMany({
        where: { status: "approved", stem: { contains: search, mode: "insensitive" } },
        take: 50,
        orderBy: { year: "desc" },
        include: { subject: true, topic: true, paper: { select: { paperType: true, state: true } } },
      })
    : [];
  // Students only ever browse moderator-approved questions.
  const subjects = await prisma.subject.findMany({
    orderBy: { name: "asc" },
    include: { _count: { select: { questions: { where: { status: "approved" } } } } },
  });

  const subjectId = sp.subject || subjects[0]?.id;
  const view = sp.view === "year" ? "year" : "topic";
  const subject = subjects.find((s) => s.id === subjectId);

  const topics = subjectId
    ? await prisma.topic.findMany({
        where: { subjectId },
        orderBy: [{ form: "asc" }, { chapter: "asc" }],
        include: { _count: { select: { questions: { where: { status: "approved" } } } } },
      })
    : [];

  const years = subjectId
    ? await prisma.question.groupBy({
        by: ["year"],
        where: { subjectId, year: { not: null }, status: "approved" },
        _count: true,
        orderBy: { year: "desc" },
      })
    : [];

  // Progress tracker: which approved questions in this subject the student has
  // already attempted (done vs not done), tallied overall + per topic/year.
  const myAttempts = subjectId
    ? await prisma.attempt.findMany({
        where: { studentId: student.id, question: { subjectId, status: "approved" } },
        select: { questionId: true, question: { select: { topicId: true, year: true } } },
      })
    : [];
  const attemptedSet = new Set(myAttempts.map((a) => a.questionId));
  const attemptedByTopic = new Map<string, Set<string>>();
  const attemptedByYear = new Map<number, Set<string>>();
  for (const a of myAttempts) {
    if (a.question.topicId) {
      const s = attemptedByTopic.get(a.question.topicId) ?? new Set();
      s.add(a.questionId);
      attemptedByTopic.set(a.question.topicId, s);
    }
    if (a.question.year != null) {
      const s = attemptedByYear.get(a.question.year) ?? new Set();
      s.add(a.questionId);
      attemptedByYear.set(a.question.year, s);
    }
  }
  const totalApproved = subject?._count.questions ?? 0;
  const doneCount = attemptedSet.size;
  const progressPct = totalApproved ? Math.round((doneCount / totalApproved) * 100) : 0;

  const base = (extra: Record<string, string>) => {
    const p = new URLSearchParams({ subject: subjectId ?? "", view, ...extra });
    return `/practice?${p.toString()}`;
  };

  return (
    <div className="space-y-6">
      <div>
        <div className="flex items-center justify-between gap-3">
          <h1 className="text-2xl font-bold">{t(lang, "practice.title")}</h1>
          <Link href="/syllabus" className="inline-flex items-center gap-1.5 text-sm font-semibold text-brand-600 hover:underline"><Icon name="book" className="h-4 w-4" /> {lang === "bm" ? "Sukatan" : "Syllabus"}</Link>
        </div>
        <p className="text-sm text-slate-500">{t(lang, "practice.subtitle")}</p>
      </div>

      {/* Question-bank search */}
      <form action="/practice" method="get" className="flex gap-2">
        <input name="q" defaultValue={search} placeholder={lang === "bm" ? "Cari soalan… (cth: pembezaan, fotosintesis)" : "Search questions… (e.g. differentiation, photosynthesis)"} className="input" />
        <button className="btn-primary cursor-pointer">{lang === "bm" ? "Cari" : "Search"}</button>
      </form>

      {search && (
        <section className="space-y-2">
          <h2 className="text-sm font-bold uppercase tracking-wide text-slate-500">
            {searchResults.length} {lang === "bm" ? "hasil untuk" : "results for"} “{search}”
          </h2>
          {searchResults.length === 0 ? (
            <div className="card p-6 text-center text-sm text-slate-400">{t(lang, "practice.selectTopic")}</div>
          ) : (
            searchResults.map((q) => (
              <Link key={q.id} href={`/practice/${q.id}`} className="card block p-4 hover:border-brand-300">
                <div className="mb-1 flex flex-wrap items-center gap-2 text-xs">
                  <span className="badge bg-brand-50 text-brand-700">{q.subject.name}</span>
                  {q.topic && <span className="text-slate-400">{q.topic.title}</span>}
                  <span className="badge bg-slate-100 text-slate-600">{q.marks} {t(lang, "common.marks")}</span>
                </div>
                <p className="line-clamp-2 text-sm text-slate-700">{q.stem}</p>
              </Link>
            ))
          )}
        </section>
      )}

      {/* Subject chips */}
      <div className="flex flex-wrap gap-2">
        {subjects.map((s) => (
          <Link
            key={s.id}
            href={`/practice?subject=${s.id}&view=${view}`}
            className={`badge border px-3 py-1.5 ${
              s.id === subjectId ? "border-brand-300 bg-brand-50 text-brand-700" : "border-slate-200 bg-white text-slate-600"
            }`}
          >
            {s.name} · {s._count.questions}
          </Link>
        ))}
      </div>

      {/* Progress tracker for this subject */}
      {totalApproved > 0 && (
        <div className="card p-4">
          <div className="mb-1 flex items-center justify-between text-sm">
            <span className="font-semibold">{subject?.name} {t(lang, "practice.progress")}</span>
            <span className="text-slate-500">{doneCount} / {totalApproved} {t(lang, "common.done").toLowerCase()} · {totalApproved - doneCount} {t(lang, "practice.left")}</span>
          </div>
          <div className="h-2.5 overflow-hidden rounded-full bg-slate-100">
            <div className="h-full bg-emerald-500" style={{ width: `${progressPct}%` }} />
          </div>
        </div>
      )}

      {/* View toggle */}
      <div className="inline-flex rounded-xl border border-slate-200 bg-white p-1">
        <Link
          href={base({})}
          className={`rounded-lg px-4 py-1.5 text-sm font-semibold ${view === "topic" ? "bg-brand-600 text-white" : "text-slate-600"}`}
        >
          {t(lang, "practice.byTopic")}
        </Link>
        <Link
          href={`/practice?subject=${subjectId}&view=year`}
          className={`rounded-lg px-4 py-1.5 text-sm font-semibold ${view === "year" ? "bg-brand-600 text-white" : "text-slate-600"}`}
        >
          {t(lang, "practice.byYear")}
        </Link>
      </div>

      {/* Topic / year list — each opens its own question page */}
      <div className="space-y-2">
        <h2 className="text-sm font-bold uppercase tracking-wide text-slate-500">
          {subject?.name} · {view === "topic" ? t(lang, "practice.topics") : t(lang, "practice.years")}
        </h2>
        {view === "topic"
          ? topics.map((tp) => {
              const total = tp._count.questions;
              const dn = attemptedByTopic.get(tp.id)?.size ?? 0;
              const p = total ? Math.round((dn / total) * 100) : 0;
              return (
                <Link
                  key={tp.id}
                  href={`/practice/list?subject=${subjectId}&topic=${tp.id}&view=topic`}
                  className="card block p-3 text-sm hover:border-brand-300 hover:shadow-sm"
                >
                  <div className="flex items-center justify-between gap-3">
                    <span className="min-w-0">
                      <span className="text-xs text-slate-400">Tingkatan {tp.form} · Bab {tp.chapter}</span>
                      <br />
                      <span className="font-medium">{tp.title}</span>
                    </span>
                    <span className="flex shrink-0 items-center gap-2">
                      <span className="badge bg-slate-100 text-slate-600">{dn}/{total}</span>
                      <Icon name="arrow" className="h-4 w-4 text-slate-300" />
                    </span>
                  </div>
                  <div className="mt-2 flex items-center gap-2">
                    <div className="h-1.5 flex-1 overflow-hidden rounded-full bg-slate-100">
                      <div className="h-full rounded-full bg-emerald-500" style={{ width: `${p}%` }} />
                    </div>
                    <span className="w-9 text-right text-xs font-semibold text-slate-400">{p}%</span>
                  </div>
                </Link>
              );
            })
          : years.map((y) => {
              const total = y._count;
              const dn = (y.year != null ? attemptedByYear.get(y.year)?.size : 0) ?? 0;
              const p = total ? Math.round((dn / total) * 100) : 0;
              return (
                <Link
                  key={String(y.year)}
                  href={`/practice/list?subject=${subjectId}&year=${y.year}&view=year`}
                  className="card block p-3 text-sm hover:border-brand-300 hover:shadow-sm"
                >
                  <div className="flex items-center justify-between gap-3">
                    <span className="font-semibold">{y.year}</span>
                    <span className="flex shrink-0 items-center gap-2">
                      <span className="badge bg-slate-100 text-slate-600">{dn}/{total}</span>
                      <Icon name="arrow" className="h-4 w-4 text-slate-300" />
                    </span>
                  </div>
                  <div className="mt-2 flex items-center gap-2">
                    <div className="h-1.5 flex-1 overflow-hidden rounded-full bg-slate-100">
                      <div className="h-full rounded-full bg-emerald-500" style={{ width: `${p}%` }} />
                    </div>
                    <span className="w-9 text-right text-xs font-semibold text-slate-400">{p}%</span>
                  </div>
                </Link>
              );
            })}
        {view === "topic" && topics.length === 0 && (
          <p className="text-sm text-slate-400">{t(lang, "practice.noTopics")}</p>
        )}
      </div>
    </div>
  );
}
