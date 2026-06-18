"use client";

import { useState } from "react";
import type { GradeResult, McqOption } from "@/lib/types";

interface Props {
  questionId: string;
  questionType: string;
  options: McqOption[];
  marks: number;
  stem?: string;
}

export default function AttemptForm({ questionId, questionType, options, marks, stem }: Props) {
  const [answer, setAnswer] = useState("");
  const [loading, setLoading] = useState(false);
  const [grade, setGrade] = useState<GradeResult | null>(null);
  const [byAi, setByAi] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [startedAt] = useState(() => Date.now());

  async function submit() {
    if (!answer.trim()) return;
    setLoading(true);
    setError(null);
    try {
      const res = await fetch("/api/attempts", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          questionId,
          answer,
          timeSpentSec: Math.round((Date.now() - startedAt) / 1000),
        }),
      });
      const data = await res.json();
      if (!res.ok) throw new Error(data.error || "Grading failed");
      setGrade(data.grade);
      setByAi(data.byAi);
    } catch (e) {
      setError(e instanceof Error ? e.message : "Something went wrong");
    } finally {
      setLoading(false);
    }
  }

  const pct = grade ? Math.round((grade.score / grade.maxScore) * 100) : 0;

  return (
    <div className="space-y-4">
      {/* Answer input */}
      {questionType === "mcq" ? (
        <div className="space-y-2">
          {options.map((o) => (
            <button
              key={o.key}
              disabled={!!grade}
              onClick={() => setAnswer(o.key)}
              className={`flex w-full items-center gap-3 rounded-xl border p-3 text-left text-sm transition ${
                answer === o.key ? "border-brand-400 bg-brand-50" : "border-slate-200 bg-white hover:bg-slate-50"
              } ${grade ? "opacity-90" : ""}`}
            >
              <span className="grid h-7 w-7 shrink-0 place-items-center rounded-full border border-slate-300 font-semibold">
                {o.key}
              </span>
              {o.text}
            </button>
          ))}
        </div>
      ) : (
        <textarea
          value={answer}
          disabled={!!grade}
          onChange={(e) => setAnswer(e.target.value)}
          rows={questionType === "essay" ? 10 : 5}
          placeholder="Tulis jawapan anda di sini…"
          className="input resize-y"
        />
      )}

      {!grade && (
        <button onClick={submit} disabled={loading || !answer.trim()} className="btn-primary w-full sm:w-auto">
          {loading ? "Grading…" : "Submit answer"}
        </button>
      )}
      {error && <p className="text-sm text-red-600">{error}</p>}

      {/* Feedback */}
      {grade && (
        <div className="card overflow-hidden">
          <div className={`flex items-center justify-between p-4 ${pct >= 50 ? "bg-emerald-50" : "bg-amber-50"}`}>
            <div>
              <div className="text-xs font-semibold uppercase tracking-wide text-slate-500">Result</div>
              <div className="text-2xl font-bold">
                {grade.score}/{grade.maxScore}{" "}
                <span className="text-base font-medium text-slate-500">({pct}%)</span>
              </div>
              <div className="text-sm font-medium text-slate-600">{grade.band}</div>
            </div>
            <span className={`badge ${byAi ? "bg-brand-100 text-brand-700" : "bg-slate-200 text-slate-600"}`}>
              {byAi ? "Graded by AI" : "Offline estimate"}
            </span>
          </div>

          <div className="space-y-4 p-4">
            <p className="text-sm text-slate-700">{grade.summary}</p>

            {grade.criteria?.length > 0 && (
              <div className="space-y-2">
                <h4 className="text-xs font-bold uppercase tracking-wide text-slate-500">Rubric breakdown</h4>
                {grade.criteria.map((c, i) => (
                  <div key={i} className="rounded-lg border border-slate-100 bg-slate-50 p-3">
                    <div className="flex items-center justify-between text-sm font-semibold">
                      <span>{c.name}</span>
                      <span>{c.awarded}/{c.max}</span>
                    </div>
                    {c.comment && <p className="mt-1 text-xs text-slate-500">{c.comment}</p>}
                  </div>
                ))}
              </div>
            )}

            {grade.strengths?.length > 0 && (
              <div>
                <h4 className="text-xs font-bold uppercase tracking-wide text-emerald-600">Strengths</h4>
                <ul className="mt-1 list-inside list-disc text-sm text-slate-700">
                  {grade.strengths.map((s, i) => <li key={i}>{s}</li>)}
                </ul>
              </div>
            )}

            {grade.improvements?.length > 0 && (
              <div>
                <h4 className="text-xs font-bold uppercase tracking-wide text-amber-600">To improve</h4>
                <ul className="mt-1 list-inside list-disc text-sm text-slate-700">
                  {grade.improvements.map((s, i) => <li key={i}>{s}</li>)}
                </ul>
              </div>
            )}

            {grade.modelAnswer && (
              <div>
                <h4 className="text-xs font-bold uppercase tracking-wide text-slate-500">Model answer</h4>
                <p className="mt-1 whitespace-pre-wrap text-sm text-slate-700">{grade.modelAnswer}</p>
              </div>
            )}

            <div className="flex flex-wrap gap-2">
              <button
                onClick={() =>
                  window.dispatchEvent(
                    new CustomEvent("open-cikgu-chat", {
                      detail: {
                        prompt: `I answered: "${answer.slice(0, 600)}". I scored ${grade.score}/${grade.maxScore}. Explain my mistake step by step and show me exactly how to get full marks.`,
                      },
                    }),
                  )
                }
                className="btn-primary"
              >
                🧑‍🏫 Explain my mistake
              </button>
              <button
                onClick={() => {
                  setGrade(null);
                  setAnswer("");
                }}
                className="btn-ghost"
              >
                Try again
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
