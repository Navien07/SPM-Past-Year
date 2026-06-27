import Link from "next/link";
import { notFound } from "next/navigation";
import { prisma } from "@/lib/db";
import { QUESTION_TYPE_LABEL, examLabel, topicLabel } from "@/lib/constants";
import AttemptForm from "@/components/AttemptForm";
import WorkingPad from "@/components/WorkingPad";
import ExplainButton from "@/components/ExplainButton";
import QuestionTools from "@/components/QuestionTools";
import { requireStudent } from "@/lib/student";
import { getLang } from "@/lib/lang-server";
import { t } from "@/lib/i18n";
import Icon from "@/components/Icon";
import type { McqOption } from "@/lib/types";

export const dynamic = "force-dynamic";

type SP = Promise<{ subject?: string; topic?: string; year?: string; view?: string; kertas?: string }>;

export default async function QuestionPage({ params, searchParams }: { params: Promise<{ id: string }>; searchParams: SP }) {
  const student = await requireStudent();
  const lang = await getLang();
  const { id } = await params;
  const sp = await searchParams;
  const q = await prisma.question.findUnique({
    where: { id },
    include: { subject: true, topic: true, paper: true },
  });
  if (!q || q.status !== "approved") notFound();

  // Navigation context: when the student arrived from a topic/year list, work
  // out the previous/next question in that same ordered set so they can move
  // through without going back.
  const hasCtx = !!(sp.subject && (sp.topic || sp.year));
  let prevId: string | null = null;
  let nextId: string | null = null;
  let pos = 0;
  let count = 0;
  const ctxParams = new URLSearchParams();
  if (hasCtx) {
    if (sp.subject) ctxParams.set("subject", sp.subject);
    if (sp.topic) ctxParams.set("topic", sp.topic);
    if (sp.year) ctxParams.set("year", sp.year);
    if (sp.view) ctxParams.set("view", sp.view);
    if (sp.kertas) ctxParams.set("kertas", sp.kertas);
    const scope: Record<string, unknown> = { subjectId: sp.subject, status: "approved" };
    if (sp.topic) scope.topicId = sp.topic;
    if (sp.year) scope.year = Number(sp.year);
    if (sp.kertas) scope.paperNumber = Number(sp.kertas);
    const ids = await prisma.question.findMany({
      where: scope,
      orderBy: [{ paperNumber: "asc" }, { number: "asc" }],
      select: { id: true },
      take: 3000,
    });
    const idx = ids.findIndex((x) => x.id === id);
    count = ids.length;
    pos = idx + 1;
    prevId = idx > 0 ? ids[idx - 1].id : null;
    nextId = idx >= 0 && idx < ids.length - 1 ? ids[idx + 1].id : null;
  }
  const qHref = (qid: string) => {
    const p = new URLSearchParams(ctxParams);
    return `/practice/${qid}${p.toString() ? `?${p.toString()}` : ""}`;
  };
  const listHref = hasCtx ? `/practice/list?${ctxParams.toString()}` : "/practice";

  const options = JSON.parse(q.options || "[]") as McqOption[];
  let bookmark = null;
  let notes: { id: string; title: string; content: string }[] = [];
  try {
    [bookmark, notes] = await Promise.all([
      prisma.bookmark.findUnique({ where: { studentId_questionId: { studentId: student.id, questionId: q.id } } }),
      prisma.knowledgeDoc.findMany({ where: { subjectId: q.subjectId }, take: 3, orderBy: { createdAt: "desc" }, select: { id: true, title: true, content: true } }),
    ]);
  } catch {
    /* bookmark/notes are optional, never block the question */
  }

  return (
    <div className="space-y-5">
      <div className="flex items-center justify-between gap-3">
        <Link href={listHref} className="inline-flex items-center gap-1.5 text-sm text-brand-600 hover:underline">
          <Icon name="arrow" className="h-4 w-4 rotate-180" /> {hasCtx ? t(lang, "qlist.back") : t(lang, "qd.back")}
        </Link>
        {hasCtx && count > 0 && (
          <span className="text-xs font-medium text-slate-400">{pos} / {count}</span>
        )}
      </div>

      <div className="card p-5">
        <div className="mb-3 flex flex-wrap items-center gap-2">
          <span className="badge bg-brand-50 text-brand-700">{q.subject.name}</span>
          <span className="badge bg-slate-100 text-slate-600">{QUESTION_TYPE_LABEL[q.questionType] ?? q.questionType}</span>
          <span className="badge bg-slate-100 text-slate-600">Kertas {q.paperNumber}</span>
          <span className="badge bg-slate-100 text-slate-600">{q.marks} {t(lang, "common.marks")}</span>
          {q.isKbat && <span className="tag-kbat">KBAT</span>}
        </div>
        {/* Label: Bab 3 · Tingkatan 4 · SPM 2025 */}
        <p className="mb-2 text-sm font-semibold text-slate-600">
          {[
            q.topic ? `Bab ${q.topic.chapter}` : null,
            q.topic ? `Tingkatan ${q.topic.form}` : null,
            q.source === "ai_generated"
              ? "Soalan AI dijana"
              : examLabel({ paperType: q.paper?.paperType, state: q.paper?.state, year: q.year }),
          ].filter(Boolean).join(" · ")}
          {q.topic ? `, ${q.topic.title}` : ""}
          {q.subtopic ? ` (${q.subtopic})` : ""}
        </p>
 <h1 className="whitespace-pre-wrap text-lg font-semibold leading-relaxed">
          {q.number ? `${q.number}. ` : ""}
          {q.stem}
        </h1>
        {(() => {
          let imgs: string[] = [];
          try { imgs = JSON.parse(q.images || "[]"); } catch { imgs = []; }
          return imgs.length > 0 ? (
            <div className="mt-3 space-y-3">
              {imgs.map((src, i) => (
                // eslint-disable-next-line @next/next/no-img-element
                <img key={i} src={src} alt={`Figure ${i + 1} for this question`} className="max-h-[480px] w-auto rounded-xl border border-slate-200" />
              ))}
            </div>
          ) : null;
        })()}
        {q.paper && (
          <p className="mt-2 text-xs text-slate-400">{t(lang, "common.source")}: {q.paper.title}</p>
        )}
        <div className="mt-4 flex flex-wrap gap-2">
          <ExplainButton />
          <QuestionTools questionId={q.id} text={q.stem} initialBookmarked={!!bookmark} />
        </div>
      </div>

      {/* Notes & formulas for this subject (from the knowledge base) */}
      {notes.length > 0 && (
        <details className="card p-4">
          <summary className="inline-flex cursor-pointer items-center gap-1.5 text-sm font-semibold text-slate-700">
            <Icon name="book" className="h-4 w-4" /> {t(lang, "qd.notes")}, {q.subject.name}
          </summary>
          <div className="mt-3 space-y-3">
            {notes.map((n) => (
              <div key={n.id}>
                <div className="text-sm font-semibold">{n.title}</div>
                <p className="mt-0.5 line-clamp-4 text-sm text-slate-600">{n.content}</p>
              </div>
            ))}
          </div>
        </details>
      )}

      {/* Handwriting / sketch working space (structured & essay questions) */}
      {q.questionType !== "mcq" && <WorkingPad />}

      <AttemptForm
        questionId={q.id}
        questionType={q.questionType}
        options={options}
        marks={q.marks}
        stem={q.stem}
      />

      {/* Previous / next within the topic or year */}
      {hasCtx && (
        <div className="flex items-center justify-between gap-3 pt-1">
          {prevId ? (
            <Link href={qHref(prevId)} className="btn-ghost inline-flex items-center gap-1.5">
              <Icon name="arrow" className="h-4 w-4 rotate-180" /> {t(lang, "qd.prev")}
            </Link>
          ) : (
            <span />
          )}
          {nextId ? (
            <Link href={qHref(nextId)} className="btn-primary inline-flex items-center gap-1.5">
              {t(lang, "qd.next")} <Icon name="arrow" className="h-4 w-4" />
            </Link>
          ) : (
            <Link href={listHref} className="btn-ghost inline-flex items-center gap-1.5">
              {t(lang, "qlist.back")} <Icon name="check" className="h-4 w-4" />
            </Link>
          )}
        </div>
      )}
    </div>
  );
}
