"use client";

import { useCallback, useEffect, useRef, useState } from "react";
import Link from "next/link";
import type { McqOption } from "@/lib/types";
import { useLang } from "@/lib/useLang";
import { t } from "@/lib/i18n";

interface Subject { id: string; name: string; _count: { questions: number } }
interface ExamQ {
  id: string;
  number: string | null;
  stem: string;
  questionType: string;
  options: McqOption[];
  marks: number;
  isKbat: boolean;
  topic: string | null;
}
interface Result { id: string; score: number; maxScore: number; band: string | null }

type Phase = "config" | "running" | "grading" | "done";

export default function ExamPage() {
  const lang = useLang();
  const [subjects, setSubjects] = useState<Subject[]>([]);
  const [cfg, setCfg] = useState({ subjectId: "", paperNumber: 1, count: 10, minutes: 30 });
  const [phase, setPhase] = useState<Phase>("config");
  const [questions, setQuestions] = useState<ExamQ[]>([]);
  const [answers, setAnswers] = useState<Record<string, string>>({});
  const [results, setResults] = useState<Result[]>([]);
  const [remaining, setRemaining] = useState(0);
  const [error, setError] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);
  const startedAt = useRef(0);

  useEffect(() => {
    fetch("/api/taxonomy").then((r) => r.json()).then((d: Subject[]) => {
      setSubjects(d);
      if (d[0]) setCfg((c) => ({ ...c, subjectId: d[0].id }));
    });
  }, []);

  const submitExam = useCallback(async () => {
    setPhase("grading");
    const out: Result[] = [];
    for (const q of questions) {
      const ans = answers[q.id] ?? "";
      try {
        const res = await fetch("/api/attempts", {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ questionId: q.id, answer: ans || "(tiada jawapan)", timeSpentSec: 0 }),
        });
        const data = await res.json();
        if (res.ok) out.push({ id: q.id, score: data.grade.score, maxScore: data.grade.maxScore, band: data.grade.band });
        else out.push({ id: q.id, score: 0, maxScore: q.marks, band: null });
      } catch {
        out.push({ id: q.id, score: 0, maxScore: q.marks, band: null });
      }
    }
    setResults(out);
    setPhase("done");
  }, [questions, answers]);

  // Countdown tick.
  useEffect(() => {
    if (phase !== "running") return;
    if (remaining <= 0) {
      submitExam();
      return;
    }
    const t = setTimeout(() => setRemaining((r) => r - 1), 1000);
    return () => clearTimeout(t);
  }, [phase, remaining, submitExam]);

  async function start() {
    setBusy(true);
    setError(null);
    try {
      const res = await fetch("/api/exam", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(cfg),
      });
      const data = await res.json();
      if (!res.ok) { setError(data.error || "Couldn't build the exam."); return; }
      setQuestions(data.questions);
      setAnswers({});
      setResults([]);
      setRemaining(cfg.minutes * 60);
      startedAt.current = Date.now();
      setPhase("running");
    } finally {
      setBusy(false);
    }
  }

  const mm = String(Math.floor(remaining / 60)).padStart(2, "0");
  const ss = String(remaining % 60).padStart(2, "0");
  const lowTime = remaining > 0 && remaining <= 60;
  const answeredCount = questions.filter((q) => (answers[q.id] ?? "").trim()).length;

  // ── CONFIG ───────────────────────────────────────────────────────────────
  if (phase === "config") {
    return (
      <div className="space-y-6">
        <div>
          <h1 className="font-display text-2xl font-black">{t(lang, "exam.title")} ⏱️</h1>
          <p className="text-sm text-slate-500">{t(lang, "exam.subtitle")}</p>
        </div>
        <div className="card grid gap-4 p-5 sm:grid-cols-2">
          <div>
            <label className="label">{t(lang, "common.subject")}</label>
            <select className="input" value={cfg.subjectId} onChange={(e) => setCfg({ ...cfg, subjectId: e.target.value })}>
              {subjects.map((s) => <option key={s.id} value={s.id}>{s.name} ({s._count.questions})</option>)}
            </select>
          </div>
          <div>
            <label className="label">Paper</label>
            <select className="input" value={cfg.paperNumber} onChange={(e) => setCfg({ ...cfg, paperNumber: Number(e.target.value) })}>
              <option value={1}>Kertas 1 (Objektif)</option>
              <option value={2}>Kertas 2 (Subjektif)</option>
            </select>
          </div>
          <div>
            <label className="label">Number of questions</label>
            <input type="number" min={1} max={40} className="input" value={cfg.count} onChange={(e) => setCfg({ ...cfg, count: Number(e.target.value) })} />
          </div>
          <div>
            <label className="label">{t(lang, "exam.duration")}</label>
            <input type="number" min={1} max={240} className="input" value={cfg.minutes} onChange={(e) => setCfg({ ...cfg, minutes: Number(e.target.value) })} />
          </div>
          {error && <p className="text-sm text-red-600 sm:col-span-2">{error}</p>}
          <div className="sm:col-span-2">
            <button onClick={start} disabled={busy || !cfg.subjectId} className="btn-primary w-full cursor-pointer sm:w-auto">
              {busy ? "Building…" : t(lang, "exam.start")}
            </button>
          </div>
        </div>
        <p className="text-xs text-slate-400">Tip: once you start, the timer keeps running even if you scroll. Submit early anytime.</p>
      </div>
    );
  }

  // ── GRADING ──────────────────────────────────────────────────────────────
  if (phase === "grading") {
    return (
      <div className="card mx-auto max-w-md p-10 text-center">
        <div className="mx-auto mb-4 h-1.5 w-40 overflow-hidden rounded-full bg-slate-100">
          <div className="h-full w-1/3 rounded-full bg-brand-500" style={{ animation: "loader 1s ease-in-out infinite" }} />
        </div>
        <p className="font-semibold">Marking your paper…</p>
        <p className="mt-1 text-sm text-slate-500">Grading {questions.length} answers against the SPM rubric.</p>
      </div>
    );
  }

  // ── DONE ─────────────────────────────────────────────────────────────────
  if (phase === "done") {
    const score = results.reduce((a, r) => a + r.score, 0);
    const max = results.reduce((a, r) => a + r.maxScore, 0);
    const pct = max ? Math.round((score / max) * 100) : 0;
    return (
      <div className="space-y-6">
        <div className="card overflow-hidden">
          <div className={`p-6 text-center ${pct >= 50 ? "bg-emerald-50" : "bg-amber-50"}`}>
            <div className="text-xs font-bold uppercase tracking-wide text-slate-500">{t(lang, "exam.results")}</div>
            <div className="font-display mt-1 text-4xl font-black">{score}/{max}</div>
            <div className="text-lg font-semibold text-slate-600">{pct}%</div>
          </div>
        </div>
        <div className="space-y-2">
          {questions.map((q, i) => {
            const r = results.find((x) => x.id === q.id);
            const ok = r ? r.score >= r.maxScore / 2 : false;
            return (
              <Link key={q.id} href={`/practice/${q.id}`} className="card flex items-center justify-between gap-3 p-4 hover:border-brand-300">
                <div className="min-w-0">
                  <div className="flex items-center gap-2">
                    <span className={`grid h-6 w-6 shrink-0 place-items-center rounded-full text-xs font-bold text-white ${ok ? "bg-emerald-500" : "bg-amber-500"}`}>{i + 1}</span>
                    {q.isKbat && <span className="tag-kbat">KBAT</span>}
                    {q.topic && <span className="truncate text-xs text-slate-400">{q.topic}</span>}
                  </div>
                  <p className="mt-1 line-clamp-1 text-sm text-slate-700">{q.stem}</p>
                </div>
                <span className="shrink-0 text-sm font-bold">{r ? `${r.score}/${r.maxScore}` : "—"}</span>
              </Link>
            );
          })}
        </div>
        <div className="flex flex-wrap gap-2">
          <button onClick={() => setPhase("config")} className="btn-primary cursor-pointer">{t(lang, "exam.start")}</button>
          <Link href="/analytics" className="btn-ghost">{t(lang, "nav.progress")}</Link>
        </div>
      </div>
    );
  }

  // ── RUNNING ──────────────────────────────────────────────────────────────
  return (
    <div className="space-y-5">
      {/* sticky timer */}
      <div className="sticky top-16 z-20 flex items-center justify-between rounded-2xl border border-slate-200 bg-white/95 p-3 shadow-sm backdrop-blur">
        <div className="text-sm">
          <span className="font-semibold">{answeredCount}/{questions.length}</span>
          <span className="text-slate-500"> answered</span>
        </div>
        <div className={`font-display rounded-xl px-4 py-1.5 text-lg font-black tabular-nums ${lowTime ? "animate-pulse bg-red-100 text-red-700" : "bg-slate-100 text-slate-800"}`}>
          {mm}:{ss}
        </div>
        <button onClick={submitExam} className="btn-primary cursor-pointer px-4 py-2 text-sm">{t(lang, "exam.submit")}</button>
      </div>

      {questions.map((q, i) => (
        <div key={q.id} className="card p-5">
          <div className="mb-2 flex flex-wrap items-center gap-2 text-xs">
            <span className="grid h-6 w-6 place-items-center rounded-full bg-brand-600 font-bold text-white">{i + 1}</span>
            <span className="badge bg-slate-100 text-slate-600">{q.marks} markah</span>
            {q.isKbat && <span className="tag-kbat">KBAT</span>}
          </div>
          <p className="whitespace-pre-wrap font-medium">{q.number ? `${q.number}. ` : ""}{q.stem}</p>
          {q.questionType === "mcq" ? (
            <div className="mt-3 space-y-2">
              {q.options.map((o) => (
                <button
                  key={o.key}
                  onClick={() => setAnswers((a) => ({ ...a, [q.id]: o.key }))}
                  className={`flex w-full cursor-pointer items-center gap-3 rounded-xl border p-3 text-left text-sm transition-colors duration-150 ${answers[q.id] === o.key ? "border-brand-400 bg-brand-50" : "border-slate-200 hover:bg-slate-50"}`}
                >
                  <span className="grid h-7 w-7 shrink-0 place-items-center rounded-full border border-slate-300 font-semibold">{o.key}</span>
                  {o.text}
                </button>
              ))}
            </div>
          ) : (
            <textarea
              value={answers[q.id] ?? ""}
              onChange={(e) => setAnswers((a) => ({ ...a, [q.id]: e.target.value }))}
              rows={q.questionType === "essay" ? 8 : 4}
              placeholder="Tulis jawapan anda…"
              className="input mt-3 resize-y"
            />
          )}
        </div>
      ))}

      <button onClick={submitExam} className="btn-primary w-full cursor-pointer">Submit exam</button>
    </div>
  );
}
