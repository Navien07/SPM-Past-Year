import Link from "next/link";
import { notFound } from "next/navigation";
import { prisma } from "@/lib/db";
import { QUESTION_TYPE_LABEL, examLabel, topicLabel } from "@/lib/constants";
import AttemptForm from "@/components/AttemptForm";
import ExplainButton from "@/components/ExplainButton";
import { requireStudent } from "@/lib/student";
import type { McqOption } from "@/lib/types";

export const dynamic = "force-dynamic";

export default async function QuestionPage({ params }: { params: Promise<{ id: string }> }) {
  await requireStudent();
  const { id } = await params;
  const q = await prisma.question.findUnique({
    where: { id },
    include: { subject: true, topic: true, paper: true },
  });
  if (!q || q.status !== "approved") notFound();

  const options = JSON.parse(q.options || "[]") as McqOption[];

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
            examLabel({ paperType: q.paper?.paperType, state: q.paper?.state, year: q.year }),
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
        <div className="mt-4">
          <ExplainButton />
        </div>
      </div>

      <AttemptForm
        questionId={q.id}
        questionType={q.questionType}
        options={options}
        marks={q.marks}
      />
    </div>
  );
}
