"use client";

import { use, useState } from "react";
import Link from "next/link";
import type { McqOption } from "@/lib/types";
import { useEffect } from "react";
import Icon from "@/components/Icon";

interface PaperQ {
  id: string; number: string | null; stem: string; questionType: string;
  options: McqOption[]; marks: number; isKbat: boolean; topic: string | null;
}
interface Result { id: string; score: number; maxScore: number }
type Phase = "loading" | "running" | "grading" | "done" | "error";

export default function PaperAttemptPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = use(params);
  const [phase, setPhase] = useState<Phase>("loading");
  const [title, setTitle] = useState("");
  const [questions, setQuestions] = useState<PaperQ[]>([]);
  const [answers, setAnswers] = useState<Record<string, string>>({});
  const [results, setResults] = useState<Result[]>([]);
  const [error, setError] = useState("");

  useEffect(() => {
    fetch(`/api/paper/${id}`)
      .then((r) => r.json())
      .then((d) => {
        if (d.error) { setError(d.error); setPhase("error"); return; }
        setTitle(d.paper.title);
        setQuestions(d.questions);
        setPhase("running");
      })
      .catch(() => { setError("Couldn't load this paper."); setPhase("error"); });
  }, [id]);

  async function submit() {
    setPhase("grading");
    const out: Result[] = [];
    for (const q of questions) {
      try {
        const res = await fetch("/api/attempts", {
          method: "POST", headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ questionId: q.id, answer: answers[q.id] || "(tiada jawapan)", timeSpentSec: 0 }),
        });
        const data = await res.json();
        out.push({ id: q.id, score: res.ok ? data.grade.score : 0, maxScore: res.ok ? data.grade.maxScore : q.marks });
      } catch {
        out.push({ id: q.id, score: 0, maxScore: q.marks });
      }
    }
    setResults(out);
    setPhase("done");
  }

  if (phase === "loading") return <div className="card p-10 text-center text-slate-500">Loading paper…</div>;
  if (phase === "error") return (
    <div className="card mx-auto max-w-md p-8 text-center">
      <div className="mx-auto grid h-14 w-14 place-items-center rounded-2xl bg-amber-50 text-amber-600"><Icon name="alert" className="h-7 w-7" /></div>
      <p className="mt-2 font-semibold">{error}</p>
      <Link href="/papers" className="btn-primary mt-4 inline-flex">Back to papers</Link>
    </div>
  );
  if (phase === "grading") return (
    <div className="card mx-auto max-w-md p-10 text-center">
      <div className="mx-auto mb-4 h-1.5 w-40 overflow-hidden rounded-full bg-slate-100">
        <div className="h-full w-1/3 rounded-full bg-brand-500" style={{ animation: "loader 1s ease-in-out infinite" }} />
      </div>
      <p className="font-semibold">Marking your paper…</p>
    </div>
  );

  if (phase === "done") {
    const score = results.reduce((a, r) => a + r.score, 0);
    const max = results.reduce((a, r) => a + r.maxScore, 0);
    const pct = max ? Math.round((score / max) * 100) : 0;
    return (
      <div className="space-y-5">
        <div className="card overflow-hidden">
          <div className={`p-6 text-center ${pct >= 50 ? "bg-emerald-50" : "bg-amber-50"}`}>
            <div className="text-xs font-bold uppercase tracking-wide text-slate-500">{title}</div>
            <div className="mt-1 text-4xl font-black">{score}/{max}</div>
            <div className="text-lg font-semibold text-slate-600">{pct}%</div>
          </div>
        </div>
        {questions.map((q, i) => {
          const r = results.find((x) => x.id === q.id);
          const ok = r ? r.score >= r.maxScore / 2 : false;
          return (
            <Link key={q.id} href={`/practice/${q.id}`} className="card flex items-center justify-between gap-3 p-4 hover:border-brand-300">
              <div className="min-w-0">
                <span className={`mr-2 inline-grid h-6 w-6 shrink-0 place-items-center rounded-full text-xs font-bold text-white ${ok ? "bg-emerald-500" : "bg-amber-500"}`}>{i + 1}</span>
                <span className="text-sm text-slate-700">{q.stem.slice(0, 90)}…</span>
              </div>
              <span className="shrink-0 text-sm font-bold">{r ? `${r.score}/${r.maxScore}` : "-"}</span>
            </Link>
          );
        })}
        <div className="flex gap-2">
          <Link href="/papers" className="btn-primary">More papers</Link>
          <Link href="/analytics" className="btn-ghost">View progress</Link>
        </div>
      </div>
    );
  }

  // running
  const answered = questions.filter((q) => (answers[q.id] ?? "").trim()).length;
  return (
    <div className="space-y-5">
      <div className="sticky top-16 z-20 flex items-center justify-between rounded-2xl border border-slate-200 bg-white/95 p-3 shadow-sm backdrop-blur">
        <div className="min-w-0">
          <p className="truncate text-sm font-semibold">{title}</p>
          <p className="text-xs text-slate-500">{answered}/{questions.length} answered</p>
        </div>
        <button onClick={submit} className="btn-primary cursor-pointer px-4 py-2 text-sm">Submit paper</button>
      </div>

      {questions.map((q, i) => (
        <div key={q.id} className="card p-5">
          <div className="mb-2 flex flex-wrap items-center gap-2 text-xs">
            <span className="grid h-6 w-6 place-items-center rounded-full bg-brand-600 font-bold text-white">{i + 1}</span>
            <span className="badge bg-slate-100 text-slate-600">{q.marks} markah</span>
            {q.isKbat && <span className="tag-kbat">KBAT</span>}
            {q.topic && <span className="text-slate-400">{q.topic}</span>}
          </div>
          <p className="whitespace-pre-wrap font-medium">{q.number ? `${q.number}. ` : ""}{q.stem}</p>
          {q.questionType === "mcq" ? (
            <div className="mt-3 space-y-2">
              {q.options.map((o) => (
                <button key={o.key} onClick={() => setAnswers((a) => ({ ...a, [q.id]: o.key }))}
                  className={`flex w-full cursor-pointer items-center gap-3 rounded-xl border p-3 text-left text-sm transition-colors duration-150 ${answers[q.id] === o.key ? "border-brand-400 bg-brand-50" : "border-slate-200 hover:bg-slate-50"}`}>
                  <span className="grid h-7 w-7 shrink-0 place-items-center rounded-full border border-slate-300 font-semibold">{o.key}</span>
                  {o.text}
                </button>
              ))}
            </div>
          ) : (
            <textarea value={answers[q.id] ?? ""} onChange={(e) => setAnswers((a) => ({ ...a, [q.id]: e.target.value }))}
              rows={q.questionType === "essay" ? 8 : 4} placeholder="Tulis jawapan anda…" className="input mt-3 resize-y" />
          )}
        </div>
      ))}
      <button onClick={submit} className="btn-primary w-full cursor-pointer">Submit paper</button>
    </div>
  );
}
