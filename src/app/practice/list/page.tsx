import Link from "next/link";
import { prisma } from "@/lib/db";
import { QUESTION_TYPE_LABEL, examLabel, topicLabel } from "@/lib/constants";
import { requireStudent } from "@/lib/student";
import { getLang } from "@/lib/lang-server";
import { t } from "@/lib/i18n";
import Icon from "@/components/Icon";

export const dynamic = "force-dynamic";
export const maxDuration = 60;

type SP = Promise<{ subject?: string; topic?: string; year?: string; view?: string; kertas?: string; pu?: string; pd?: string }>;

const PAGE_SIZE = 48;

type Q = {
  id: string;
  stem: string;
  questionType: string;
  paperNumber: number;
  marks: number;
  isKbat: boolean;
  source: string;
  year: number | null;
  topic: { title: string; chapter: number; form: number } | null;
  paper: { paperType: string | null; state: string | null } | null;
};

function QuestionCard({ q, done, lang, ctx }: { q: Q; done: boolean; lang: "en" | "bm"; ctx: string }) {
  const isAi = q.source === "ai_generated";
  const tLabel = topicLabel({ chapter: q.topic?.chapter, form: q.topic?.form });
  const exam = isAi ? "Soalan AI dijana" : examLabel({ paperType: q.paper?.paperType, state: q.paper?.state, year: q.year });
  return (
    <Link href={`/practice/${q.id}${ctx ? `?${ctx}` : ""}`} className={`card block p-4 hover:border-brand-300 hover:shadow-sm ${done ? "opacity-80" : ""}`}>
      <div className="mb-1 flex flex-wrap items-center gap-2">
        {done ? (
          <span className="badge inline-flex items-center gap-1 bg-emerald-100 text-emerald-700"><Icon name="check" className="h-3.5 w-3.5" /> {t(lang, "common.done")}</span>
        ) : (
          <span className="badge bg-slate-100 text-slate-500">{t(lang, "common.notDone")}</span>
        )}
        <span className="badge bg-slate-100 text-slate-600">{QUESTION_TYPE_LABEL[q.questionType] ?? q.questionType}</span>
        <span className="badge bg-slate-100 text-slate-600">Kertas {q.paperNumber}</span>
        <span className="badge bg-slate-100 text-slate-600">{q.marks} {t(lang, "common.marks")}</span>
        {isAi && <span className="badge inline-flex items-center gap-1 bg-accent-100 text-accent-700"><Icon name="sparkles" className="h-3.5 w-3.5" /> AI</span>}
        {q.isKbat && <span className="tag-kbat">KBAT</span>}
      </div>
      <p className="line-clamp-2 text-sm text-slate-700">{q.stem}</p>
      <p className="mt-1 text-xs font-medium text-slate-500">{[q.topic?.title, tLabel, exam].filter(Boolean).join("  ·  ")}</p>
    </Link>
  );
}

export default async function QuestionListPage({ searchParams }: { searchParams: SP }) {
  const student = await requireStudent();
  const sp = await searchParams;
  const lang = await getLang();

  const subjectId = sp.subject;
  if (!subjectId || (!sp.topic && !sp.year)) {
    return (
      <div className="card p-8 text-center">
        <p className="text-slate-500">{t(lang, "practice.selectTopic")}</p>
        <Link href="/practice" className="btn-primary mt-4 inline-flex items-center gap-1.5"><Icon name="arrow" className="h-4 w-4 rotate-180" /> {t(lang, "qlist.backTopics")}</Link>
      </div>
    );
  }

  // Base scope (topic or year) and the active Kertas (paper) filter on top.
  const baseScope: Record<string, unknown> = { subjectId, status: "approved" };
  if (sp.topic) baseScope.topicId = sp.topic;
  if (sp.year) baseScope.year = Number(sp.year);
  const kertas = sp.kertas === "1" || sp.kertas === "2" ? Number(sp.kertas) : null;
  const scope: Record<string, unknown> = kertas ? { ...baseScope, paperNumber: kertas } : baseScope;

  const subject = await prisma.subject.findUnique({ where: { id: subjectId }, select: { name: true } });
  const topic = sp.topic ? await prisma.topic.findUnique({ where: { id: sp.topic }, select: { title: true, form: true, chapter: true } }) : null;

  // How many questions sit under each Kertas (for the filter chips + counts).
  const kertasGroups = await prisma.question.groupBy({ by: ["paperNumber"], where: baseScope, _count: true, orderBy: { paperNumber: "asc" } });

  // Which questions in this scope the student has already attempted (saved state).
  const attempted = await prisma.attempt.findMany({
    where: { studentId: student.id, question: scope },
    select: { questionId: true },
    distinct: ["questionId"],
  });
  const attemptedIds = attempted.map((a) => a.questionId);

  const total = await prisma.question.count({ where: scope });
  const doneCount = attemptedIds.length;
  const undoneCount = total - doneCount;
  const pct = total ? Math.round((doneCount / total) * 100) : 0;

  const pu = Math.max(1, Number(sp.pu) || 1);
  const pd = Math.max(1, Number(sp.pd) || 1);
  const order = [{ paperNumber: "asc" as const }, { number: "asc" as const }];

  // Undone on top, done at the bottom — two queries so ordering holds across pages.
  const undoneWhere = attemptedIds.length ? { ...scope, id: { notIn: attemptedIds } } : scope;
  const [undone, done] = await Promise.all([
    prisma.question.findMany({ where: undoneWhere, orderBy: order, take: pu * PAGE_SIZE, include: { topic: true, paper: { select: { paperType: true, state: true } } } }),
    attemptedIds.length
      ? prisma.question.findMany({ where: { ...scope, id: { in: attemptedIds } }, orderBy: order, take: pd * PAGE_SIZE, include: { topic: true, paper: { select: { paperType: true, state: true } } } })
      : Promise.resolve([] as Q[]),
  ]);

  const heading = sp.topic
    ? topic?.title ?? t(lang, "practice.questions")
    : `${subject?.name ?? ""} ${sp.year}`;
  const sub = sp.topic && topic ? `Tingkatan ${topic.form} · Bab ${topic.chapter}` : subject?.name;

  const view = sp.view === "year" ? "year" : "topic";
  const backHref = `/practice?subject=${subjectId}&view=${view}`;
  const mk = (extra: Record<string, string>) => {
    const p = new URLSearchParams({ subject: subjectId, view });
    if (sp.topic) p.set("topic", sp.topic);
    if (sp.year) p.set("year", sp.year);
    if (kertas) p.set("kertas", String(kertas));
    for (const [k, v] of Object.entries(extra)) p.set(k, v);
    return `/practice/list?${p.toString()}`;
  };
  // Context passed to each question so it can offer prev/next within this set.
  const ctxP = new URLSearchParams({ subject: subjectId, view });
  if (sp.topic) ctxP.set("topic", sp.topic);
  if (sp.year) ctxP.set("year", sp.year);
  if (kertas) ctxP.set("kertas", String(kertas));
  const ctx = ctxP.toString();
  // Kertas filter chip link (resets pagination).
  const kertasHref = (k: number | null) => {
    const p = new URLSearchParams({ subject: subjectId, view });
    if (sp.topic) p.set("topic", sp.topic);
    if (sp.year) p.set("year", sp.year);
    if (k) p.set("kertas", String(k));
    return `/practice/list?${p.toString()}`;
  };

  return (
    <div className="space-y-5">
      {/* Back + heading */}
      <div>
        <Link href={backHref} className="inline-flex items-center gap-1.5 text-sm font-semibold text-brand-600 hover:underline">
          <Icon name="arrow" className="h-4 w-4 rotate-180" /> {t(lang, "qlist.backTopics")}
        </Link>
        <h1 className="font-display mt-2 text-2xl font-bold">{heading}</h1>
        {sub && <p className="text-sm text-slate-500">{sub}</p>}
        {sp.topic && (
          <Link href={`/flashcards?subject=${subjectId}&topic=${sp.topic}`} className="mt-2 inline-flex items-center gap-1.5 text-sm font-semibold text-accent-700 hover:underline">
            <Icon name="bolt" className="h-4 w-4" /> {t(lang, "flash.title")}
          </Link>
        )}
      </div>

      {/* Progress for this topic/year */}
      <div className="card p-4">
        <div className="mb-1 flex items-center justify-between text-sm">
          <span className="font-semibold">{pct}% {t(lang, "common.done").toLowerCase()}</span>
          <span className="text-slate-500">{doneCount} / {total} · {undoneCount} {t(lang, "practice.left")}</span>
        </div>
        <div className="h-2.5 overflow-hidden rounded-full bg-slate-100">
          <div className="h-full rounded-full bg-emerald-500 transition-all" style={{ width: `${pct}%` }} />
        </div>
      </div>

      {/* Kertas filter — only when this set spans more than one paper */}
      {kertasGroups.length > 1 && (
        <div className="flex flex-wrap gap-2">
          <Link href={kertasHref(null)} className={`rounded-full px-3.5 py-1.5 text-sm font-medium transition ${!kertas ? "bg-brand-600 text-white" : "border border-slate-200 bg-white text-slate-600 hover:bg-slate-50"}`}>
            {t(lang, "qlist.all")}
          </Link>
          {kertasGroups.map((g) => (
            <Link
              key={g.paperNumber}
              href={kertasHref(g.paperNumber)}
              className={`rounded-full px-3.5 py-1.5 text-sm font-medium transition ${kertas === g.paperNumber ? "bg-brand-600 text-white" : "border border-slate-200 bg-white text-slate-600 hover:bg-slate-50"}`}
            >
              Kertas {g.paperNumber} · {g._count}
            </Link>
          ))}
        </div>
      )}

      {total === 0 && <div className="card p-6 text-center text-sm text-slate-400">{t(lang, "practice.selectTopic")}</div>}

      {/* To do — undone on top */}
      {undoneCount > 0 && (
        <section className="space-y-3">
          <h2 className="flex items-center gap-2 text-sm font-bold uppercase tracking-wide text-slate-500">
            {t(lang, "qlist.todo")} <span className="rounded-full bg-slate-100 px-2 py-0.5 text-xs font-semibold text-slate-500">{undoneCount}</span>
          </h2>
          {undone.map((q) => <QuestionCard key={q.id} q={q} done={false} lang={lang} ctx={ctx} />)}
          {undone.length < undoneCount && (
            <Link href={mk({ pu: String(pu + 1) })} scroll={false} className="card block p-3 text-center text-sm font-semibold text-brand-600 hover:border-brand-300">
              {lang === "bm" ? "Tunjuk lagi" : "Show more"} ({undone.length} / {undoneCount})
            </Link>
          )}
        </section>
      )}

      {/* Completed — done at the bottom */}
      {doneCount > 0 && (
        <section className="space-y-3">
          <h2 className="flex items-center gap-2 text-sm font-bold uppercase tracking-wide text-emerald-600">
            <Icon name="check" className="h-4 w-4" /> {t(lang, "qlist.completed")} <span className="rounded-full bg-emerald-50 px-2 py-0.5 text-xs font-semibold text-emerald-600">{doneCount}</span>
          </h2>
          {done.map((q) => <QuestionCard key={q.id} q={q} done lang={lang} ctx={ctx} />)}
          {done.length < doneCount && (
            <Link href={mk({ pd: String(pd + 1) })} scroll={false} className="card block p-3 text-center text-sm font-semibold text-brand-600 hover:border-brand-300">
              {lang === "bm" ? "Tunjuk lagi" : "Show more"} ({done.length} / {doneCount})
            </Link>
          )}
        </section>
      )}
    </div>
  );
}
