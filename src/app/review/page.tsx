import Link from "next/link";
import { prisma } from "@/lib/db";
import { requireStudent } from "@/lib/student";
import { QUESTION_TYPE_LABEL, examLabel } from "@/lib/constants";
import SmartPracticeButton from "@/components/SmartPracticeButton";

export const dynamic = "force-dynamic";

export default async function ReviewPage() {
  const student = await requireStudent();
  const now = new Date();

  let due, upcoming, bookmarks;
  try {
    [due, upcoming, bookmarks] = await Promise.all([
      prisma.reviewItem.findMany({
        where: { studentId: student.id, dueAt: { lte: now } },
        orderBy: { dueAt: "asc" },
        include: { question: { include: { subject: true, topic: true, paper: { select: { paperType: true, state: true } } } } },
      }),
      prisma.reviewItem.count({ where: { studentId: student.id, dueAt: { gt: now } } }),
      prisma.bookmark.findMany({
        where: { studentId: student.id },
        orderBy: { createdAt: "desc" },
        include: { question: { include: { subject: true, topic: true, paper: { select: { paperType: true, state: true } } } } },
      }),
    ]);
  } catch {
    return (
      <div className="card mx-auto max-w-xl p-8 text-center">
        <div className="text-4xl">🔁</div>
        <h1 className="mt-3 text-xl font-bold">Review isn&apos;t ready yet</h1>
        <p className="mt-2 text-sm text-slate-600">
          The review/bookmark tables aren&apos;t in the database yet. An admin needs to run the latest
          <code className="mx-1 rounded bg-slate-100 px-1">supabase_setup.sql</code>. Once done, answer a
          few questions and they&apos;ll appear here automatically.
        </p>
      </div>
    );
  }

  function Row({ q, meta }: { q: { id: string; stem: string; questionType: string; marks: number; isKbat: boolean; year: number | null; source: string; subject: { name: string }; topic: { title: string; form: number; chapter: number } | null; paper: { paperType: string; state: string | null } | null }; meta?: string }) {
    const exam = q.source === "ai_generated" ? "Soalan AI" : examLabel({ paperType: q.paper?.paperType, state: q.paper?.state, year: q.year });
    return (
      <Link href={`/practice/${q.id}`} className="card block p-4 hover:border-brand-300">
        <div className="mb-1 flex flex-wrap items-center gap-2 text-xs">
          <span className="badge bg-brand-50 text-brand-700">{q.subject.name}</span>
          <span className="badge bg-slate-100 text-slate-600">{QUESTION_TYPE_LABEL[q.questionType] ?? q.questionType}</span>
          {q.isKbat && <span className="tag-kbat">KBAT</span>}
          {meta && <span className="badge bg-amber-100 text-amber-800">{meta}</span>}
        </div>
        <p className="line-clamp-2 text-sm text-slate-700">{q.stem}</p>
        <p className="mt-1 text-xs font-medium text-slate-500">
          {[q.topic ? `Bab ${q.topic.chapter} · Tingkatan ${q.topic.form}` : null, exam].filter(Boolean).join("  ·  ")}
        </p>
      </Link>
    );
  }

  return (
    <div className="space-y-6">
      <div className="flex items-start justify-between gap-3">
        <div>
          <h1 className="text-2xl font-bold">Review 🔁</h1>
          <p className="text-sm text-slate-500">
            Questions you got wrong come back on a spaced schedule until you master them.
          </p>
        </div>
        <SmartPracticeButton />
      </div>

      <div className="grid grid-cols-3 gap-3">
        <div className="card p-4 text-center">
          <div className="text-2xl font-bold text-amber-600">{due.length}</div>
          <div className="text-xs text-slate-500">Due now</div>
        </div>
        <div className="card p-4 text-center">
          <div className="text-2xl font-bold text-brand-700">{upcoming}</div>
          <div className="text-xs text-slate-500">Scheduled</div>
        </div>
        <div className="card p-4 text-center">
          <div className="text-2xl font-bold text-violet-600">{bookmarks.length}</div>
          <div className="text-xs text-slate-500">Bookmarked</div>
        </div>
      </div>

      <section className="space-y-2">
        <h2 className="text-sm font-bold uppercase tracking-wide text-slate-500">Due for review</h2>
        {due.length === 0 ? (
          <div className="card p-6 text-center text-sm text-slate-400">
            Nothing due — great job! Wrong answers reappear here automatically.
          </div>
        ) : (
          due.map((r) => <Row key={r.id} q={r.question} meta={`${Math.round(r.lastScorePct)}% last`} />)
        )}
      </section>

      {bookmarks.length > 0 && (
        <section className="space-y-2">
          <h2 className="text-sm font-bold uppercase tracking-wide text-slate-500">⭐ Bookmarked</h2>
          {bookmarks.map((b) => <Row key={b.id} q={b.question} />)}
        </section>
      )}
    </div>
  );
}
