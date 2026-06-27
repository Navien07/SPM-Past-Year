import Link from "next/link";
import { prisma } from "@/lib/db";
import { QUESTION_TYPE_LABEL, examLabel, topicLabel } from "@/lib/constants";
import { requireStudent } from "@/lib/student";
import { getLang } from "@/lib/lang-server";
import { t } from "@/lib/i18n";

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

  // The selected drill-down (topic or year) → paginated question list.
  // (A popular year can hold 1,000+ questions, never load them all at once.)
  const PAGE_SIZE = 48;
  const page = Math.max(1, Number(sp.page) || 1);
  const where: Record<string, unknown> = { subjectId, status: "approved" };
  if (sp.topic) where.topicId = sp.topic;
  if (sp.year) where.year = Number(sp.year);
  const drilling = !!(sp.topic || sp.year);
  const [questions, questionTotal] = drilling
    ? await Promise.all([
        prisma.question.findMany({
          where,
          orderBy: [{ paperNumber: "asc" }, { number: "asc" }],
          include: { topic: true, paper: { select: { paperType: true, state: true } } },
          take: page * PAGE_SIZE,
        }),
        prisma.question.count({ where }),
      ])
    : [[], 0];

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
          <Link href="/syllabus" className="text-sm font-semibold text-brand-600 hover:underline">📚 {lang === "bm" ? "Sukatan" : "Syllabus"}</Link>
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

      <div className="grid gap-6 lg:grid-cols-[320px_1fr]">
        {/* Left: topic/year list */}
        <div className="space-y-2">
          <h2 className="text-sm font-bold uppercase tracking-wide text-slate-500">
            {subject?.name} · {view === "topic" ? t(lang, "practice.topics") : t(lang, "practice.years")}
          </h2>
          {view === "topic"
            ? topics.map((t) => (
                <Link
                  key={t.id}
                  href={base({ topic: t.id })}
                  className={`card flex items-center justify-between p-3 text-sm hover:border-brand-300 ${
                    sp.topic === t.id ? "border-brand-400 ring-1 ring-brand-200" : ""
                  }`}
                >
                  <span>
                    <span className="text-xs text-slate-400">Tingkatan {t.form} · Bab {t.chapter}</span>
                    <br />
                    {t.title}
                  </span>
                  <span className="badge bg-slate-100 text-slate-600">
                    {attemptedByTopic.get(t.id)?.size ?? 0}/{t._count.questions}
                  </span>
                </Link>
              ))
            : years.map((y) => (
                <Link
                  key={String(y.year)}
                  href={base({ year: String(y.year) })}
                  className={`card flex items-center justify-between p-3 text-sm hover:border-brand-300 ${
                    sp.year === String(y.year) ? "border-brand-400 ring-1 ring-brand-200" : ""
                  }`}
                >
                  <span className="font-semibold">{y.year}</span>
                  <span className="badge bg-slate-100 text-slate-600">
                    {(y.year != null ? attemptedByYear.get(y.year)?.size : 0) ?? 0}/{y._count}
                  </span>
                </Link>
              ))}
          {view === "topic" && topics.length === 0 && (
            <p className="text-sm text-slate-400">{t(lang, "practice.noTopics")}</p>
          )}
        </div>

        {/* Right: questions */}
        <div className="space-y-3">
          <h2 className="text-sm font-bold uppercase tracking-wide text-slate-500">{t(lang, "practice.questions")}</h2>
          {questions.length === 0 ? (
            <div className="card p-6 text-center text-sm text-slate-400">
              {view === "topic" ? t(lang, "practice.selectTopic") : t(lang, "practice.selectYear")}
            </div>
          ) : (
            questions.map((q) => {
              const done = attemptedSet.has(q.id);
              const isAi = q.source === "ai_generated";
              const tLabel = topicLabel({ chapter: q.topic?.chapter, form: q.topic?.form });
              const exam = isAi ? "Soalan AI dijana" : examLabel({ paperType: q.paper?.paperType, state: q.paper?.state, year: q.year });
              return (
                <Link key={q.id} href={`/practice/${q.id}`} className="card block p-4 hover:border-brand-300 hover:shadow-sm">
                  <div className="mb-1 flex flex-wrap items-center gap-2">
                    {done ? (
                      <span className="badge bg-emerald-100 text-emerald-700">✓ {t(lang, "common.done")}</span>
                    ) : (
                      <span className="badge bg-slate-100 text-slate-500">{t(lang, "common.notDone")}</span>
                    )}
                    <span className="badge bg-slate-100 text-slate-600">{QUESTION_TYPE_LABEL[q.questionType] ?? q.questionType}</span>
                    <span className="badge bg-slate-100 text-slate-600">Kertas {q.paperNumber}</span>
                    <span className="badge bg-slate-100 text-slate-600">{q.marks} {t(lang, "common.marks")}</span>
                    {isAi && <span className="badge bg-accent-100 text-accent-700">✨ AI</span>}
                    {q.isKbat && <span className="tag-kbat">KBAT</span>}
                  </div>
                  <p className="line-clamp-2 text-sm text-slate-700">{q.stem}</p>
                  {/* Label: Bab 3 · Tingkatan 4 · SPM 2025 */}
                  <p className="mt-1 text-xs font-medium text-slate-500">
                    {[q.topic?.title, tLabel, exam].filter(Boolean).join("  ·  ")}
                  </p>
                </Link>
              );
            })
          )}
          {drilling && questionTotal > questions.length && (
            <Link
              href={base({ ...(sp.topic ? { topic: sp.topic } : {}), ...(sp.year ? { year: sp.year } : {}), page: String(page + 1) })}
              scroll={false}
              className="card block p-3 text-center text-sm font-semibold text-brand-600 hover:border-brand-300"
            >
              {lang === "bm" ? "Tunjuk lagi" : "Show more"} ({questions.length} / {questionTotal})
            </Link>
          )}
        </div>
      </div>
    </div>
  );
}
