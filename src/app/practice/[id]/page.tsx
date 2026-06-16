import Link from "next/link";
import { notFound } from "next/navigation";
import { prisma } from "@/lib/db";
import { QUESTION_TYPE_LABEL } from "@/lib/constants";
import AttemptForm from "@/components/AttemptForm";
import type { McqOption } from "@/lib/types";

export const dynamic = "force-dynamic";

export default async function QuestionPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  const q = await prisma.question.findUnique({
    where: { id },
    include: { subject: true, topic: true, paper: true },
  });
  if (!q) notFound();

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
          {q.year && <span className="badge bg-slate-100 text-slate-600">{q.year}</span>}
        </div>
        {q.topic && (
          <p className="mb-2 text-xs text-slate-400">
            Tingkatan {q.topic.form} · Bab {q.topic.chapter} · {q.topic.title}
            {q.subtopic ? ` · ${q.subtopic}` : ""}
          </p>
        )}
        <h1 className="whitespace-pre-wrap text-lg font-semibold leading-relaxed">
          {q.number ? `${q.number}. ` : ""}
          {q.stem}
        </h1>
        {q.paper && (
          <p className="mt-2 text-xs text-slate-400">Source: {q.paper.title}</p>
        )}
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
