import Link from "next/link";
import { notFound } from "next/navigation";
import { prisma } from "@/lib/db";
import { QUESTION_TYPE_LABEL, examLabel, topicLabel } from "@/lib/constants";
import AttemptForm from "@/components/AttemptForm";
import ExplainButton from "@/components/ExplainButton";
import QuestionTools from "@/components/QuestionTools";
import { requireStudent } from "@/lib/student";
import type { McqOption } from "@/lib/types";

export const dynamic = "force-dynamic";

export default async function QuestionPage({ params }: { params: Promise<{ id: string }> }) {
  const student = await requireStudent();
  const { id } = await params;
  const q = await prisma.question.findUnique({
    where: { id },
    include: { subject: true, topic: true, paper: true },
  });
  if (!q || q.status !== "approved") notFound();

  const options = JSON.parse(q.options || "[]") as McqOption[];
  const [bookmark, notes] = await Promise.all([
    prisma.bookmark.findUnique({ where: { studentId_questionId: { studentId: student.id, questionId: q.id } } }),
    prisma.knowledgeDoc.findMany({ where: { subjectId: q.subjectId }, take: 3, orderBy: { createdAt: "desc" } }),
  ]);

  return (
    <div className="space-y-5">
      <Link href="/practice" className="text-sm text-brand-600 hover:underline">
        ← Back to practice
      </Link>

      <div className="card p-5">
        <div className="mb-3 flex flex-wrap items-center gap-2">
          <span className="badge bg-brand-50 text-brand-700">{q.subject.name}</span>
          <span className="badge bg-slate-100 text-slate-600">{QUESTION_TYPE_LABEL[q.questionType] ?? q.questionType}</span>
          <span className="badge bg-slate-100 text-slate-600">Kertas {q.paperNumber}</span>
          <span className="badge bg-slate-100 text-slate-600">{q.marks} markah</span>
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
          {q.topic ? ` — ${q.topic.title}` : ""}
          {q.subtopic ? ` (${q.subtopic})` : ""}
        </p>
        <h1 className="whitespace-pre-wrap text-lg font-semibold leading-relaxed">
          {q.number ? `${q.number}. ` : ""}
          {q.stem}
        </h1>
        {q.paper && (
          <p className="mt-2 text-xs text-slate-400">Source: {q.paper.title}</p>
        )}
        <div className="mt-4 flex flex-wrap gap-2">
          <ExplainButton />
          <QuestionTools questionId={q.id} text={q.stem} initialBookmarked={!!bookmark} />
        </div>
      </div>

      {/* Notes & formulas for this subject (from the knowledge base) */}
      {notes.length > 0 && (
        <details className="card p-4">
          <summary className="cursor-pointer text-sm font-semibold text-slate-700">
            📘 Notes &amp; formulas — {q.subject.name}
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

      <AttemptForm
        questionId={q.id}
        questionType={q.questionType}
        options={options}
        marks={q.marks}
        stem={q.stem}
      />
    </div>
  );
}
