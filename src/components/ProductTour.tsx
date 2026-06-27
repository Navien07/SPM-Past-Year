"use client";

import { useEffect, useRef, useState } from "react";

// Self-playing product tour for the landing page. When scrolled into view it
// animates the core loop bubble-by-bubble: attempt a question → get it wrong →
// ask Cikgu AI → learn → reattempt correctly → progress + XP rise → resume
// anywhere. Loops. Respects prefers-reduced-motion (jumps to the end state).

const STEPS = 11;          // 0..10
const STEP_MS = 1500;

const PHASES = [
  { from: 0, label: "1 · Attempt", desc: "Practise real SPM questions, by topic or year." },
  { from: 1, label: "2 · Stuck?", desc: "Got it wrong? Instant feedback, no waiting." },
  { from: 3, label: "3 · Ask Cikgu AI", desc: "Your AI tutor explains it, step by step." },
  { from: 6, label: "4 · Reattempt", desc: "Try again and nail it." },
  { from: 8, label: "5 · Level up", desc: "Progress, XP and streaks grow as you go." },
];

function phaseFor(step: number) {
  let p = PHASES[0];
  for (const ph of PHASES) if (step >= ph.from) p = ph;
  return p;
}

export default function ProductTour() {
  const [step, setStep] = useState(0);
  const [reduced, setReduced] = useState(false);
  const ref = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const rm = window.matchMedia?.("(prefers-reduced-motion: reduce)").matches;
    if (rm) { setReduced(true); setStep(STEPS - 1); return; }
    let timer: ReturnType<typeof setInterval> | null = null;
    const io = new IntersectionObserver(
      (entries) => {
        if (entries[0].isIntersecting && !timer) {
          timer = setInterval(() => setStep((s) => (s + 1) % STEPS), STEP_MS);
        } else if (!entries[0].isIntersecting && timer) {
          clearInterval(timer); timer = null;
        }
      },
      { threshold: 0.35 },
    );
    if (ref.current) io.observe(ref.current);
    return () => { if (timer) clearInterval(timer); io.disconnect(); };
  }, []);

  const phase = phaseFor(step);
  // Derived UI state from the step.
  const pickedWrong = step >= 1 && step <= 5;
  const pickedRight = step >= 6;
  const showHint = step >= 2 && step <= 5;
  const chatOpen = step >= 3;
  const showUserMsg = step >= 3;
  const typing = step === 4;
  const showAiMsg = step >= 5;
  const showResult = step >= 7;
  const progress = step >= 8 ? 52 : 40;
  const xp = step >= 8;
  const resume = step >= 9;

  return (
    <div ref={ref} className="grid items-center gap-8 lg:grid-cols-[1fr_minmax(0,420px)]">
      {/* Narrative */}
      <div>
        <h2 className="font-display text-3xl font-black sm:text-4xl">See exactly how it works</h2>
        <p className="mt-3 max-w-md text-slate-600">
          One loop, mastered: attempt, learn from Cikgu AI, reattempt, and watch your readiness climb, on any device.
        </p>
        <ul className="mt-6 space-y-2.5">
          {PHASES.map((p) => {
            const active = !reduced && phase.label === p.label;
            return (
              <li key={p.label} className={`flex items-start gap-3 rounded-2xl border p-3 transition-all duration-300 ${active ? "border-[#2D5BFF]/30 bg-[#2D5BFF]/5" : "border-transparent"}`}>
                <span className={`mt-0.5 h-2.5 w-2.5 shrink-0 rounded-full transition-colors duration-300 ${active ? "bg-[#2D5BFF]" : "bg-slate-300"}`} />
                <div>
                  <p className={`text-sm font-bold ${active ? "text-[#2D5BFF]" : "text-slate-700"}`}>{p.label}</p>
                  <p className="text-sm text-slate-500">{p.desc}</p>
                </div>
              </li>
            );
          })}
        </ul>
      </div>

      {/* Phone mock */}
      <div className="mx-auto w-full max-w-[380px]">
        <div className="overflow-hidden rounded-[2rem] border-[6px] border-[#0B1020] bg-slate-50 shadow-2xl">
          {/* app chrome */}
          <div className="flex items-center justify-between bg-white px-4 py-2.5 text-[11px] font-semibold text-slate-400">
            <span>SPM AI</span>
            <span className="flex items-center gap-1">
              <span className={`inline-flex items-center gap-1 rounded-full px-2 py-0.5 transition-colors duration-500 ${xp ? "bg-amber-100 text-amber-700" : "bg-slate-100 text-slate-400"}`}>
                <Flame /> {xp ? "5" : "4"}
              </span>
            </span>
          </div>

          <div className="space-y-3 p-4">
            {/* Question card */}
            <div className="rounded-2xl border border-slate-200 bg-white p-3.5 shadow-sm">
              <div className="mb-1.5 flex flex-wrap gap-1.5 text-[10px]">
                <span className="rounded bg-blue-50 px-1.5 py-0.5 font-semibold text-blue-700">Physics</span>
                <span className="rounded bg-slate-100 px-1.5 py-0.5 text-slate-500">MCQ · 1 mark</span>
              </div>
              <p className="text-[13px] font-medium leading-snug text-slate-800">
                A 1000 kg car accelerates at 2 m/s². What is the net force on it?
              </p>
              <div className="mt-2.5 space-y-1.5">
                {[
                  { k: "A", t: "500 N" },
                  { k: "B", t: "1000 N" },
                  { k: "C", t: "2000 N" },
                  { k: "D", t: "4000 N" },
                ].map((o) => {
                  const isWrong = o.k === "B" && pickedWrong;
                  const isRight = o.k === "C" && pickedRight;
                  return (
                    <div
                      key={o.k}
                      className={`flex items-center gap-2 rounded-lg border px-2.5 py-1.5 text-[12px] transition-all duration-300 ${
                        isWrong ? "border-red-300 bg-red-50 text-red-700" :
                        isRight ? "border-emerald-400 bg-emerald-50 text-emerald-700" :
                        "border-slate-200 bg-white text-slate-600"
                      } ${isWrong ? "animate-[shake_0.4s]" : ""}`}
                    >
                      <span className={`grid h-5 w-5 shrink-0 place-items-center rounded-full border text-[10px] font-bold ${isWrong ? "border-red-400" : isRight ? "border-emerald-500" : "border-slate-300"}`}>{o.k}</span>
                      {o.t}
                      {isWrong && <span className="ml-auto">✕</span>}
                      {isRight && <span className="ml-auto"><Check /></span>}
                    </div>
                  );
                })}
              </div>
              {showHint && !showResult && (
                <p className="mt-2 text-[11px] font-medium text-red-500">Not quite, the answer isn&apos;t 1000 N.</p>
              )}
              {showResult && (
                <div className="mt-2 flex items-center gap-1.5 rounded-lg bg-emerald-50 px-2.5 py-1.5 text-[12px] font-semibold text-emerald-700">
                  <Check /> Correct! 1/1 {xp && <span className="ml-auto text-amber-600">+3 XP</span>}
                </div>
              )}
            </div>

            {/* Chat */}
            <div className={`transition-all duration-500 ${chatOpen ? "max-h-72 opacity-100" : "max-h-0 overflow-hidden opacity-0"}`}>
              <div className="rounded-2xl border border-slate-200 bg-white p-3 shadow-sm">
                <div className="mb-2 flex items-center gap-1.5 text-[11px] font-bold text-[#2D5BFF]"><Teacher /> Cikgu AI</div>
                <div className="space-y-2">
                  {showUserMsg && (
                    <div className="flex justify-end">
                      <p className="max-w-[80%] rounded-2xl rounded-br-sm bg-[#2D5BFF] px-2.5 py-1.5 text-[11px] text-white">Why isn&apos;t it 1000 N?</p>
                    </div>
                  )}
                  {typing && (
                    <div className="flex gap-1 px-1"><Dot /><Dot d="150ms" /><Dot d="300ms" /></div>
                  )}
                  {showAiMsg && (
                    <div className="flex justify-start">
                      <p className="max-w-[88%] rounded-2xl rounded-bl-sm border border-slate-200 bg-slate-50 px-2.5 py-1.5 text-[11px] leading-relaxed text-slate-700">
                        Use <strong>F = m × a</strong>. Force = 1000 × 2 = <strong>2000 N</strong>. It&apos;s mass <em>times</em> acceleration, not mass alone.
                      </p>
                    </div>
                  )}
                </div>
              </div>
            </div>

            {/* Progress */}
            <div className="rounded-2xl border border-slate-200 bg-white p-3 shadow-sm">
              <div className="mb-1 flex items-center justify-between text-[11px]">
                <span className="font-semibold text-slate-600">Physics readiness</span>
                <span className="text-slate-400">{progress}%</span>
              </div>
              <div className="h-2 overflow-hidden rounded-full bg-slate-100">
                <div className="h-full rounded-full bg-gradient-to-r from-[#2D5BFF] to-[#27d3ac] transition-all duration-700" style={{ width: `${progress}%` }} />
              </div>
              {resume && (
                <p className="mt-2 flex items-center gap-1.5 text-[10px] text-slate-400">
                  <Devices /> Saved, continue on phone, tablet or laptop.
                </p>
              )}
            </div>
          </div>
        </div>
      </div>

      <style>{`@keyframes shake{0%,100%{transform:translateX(0)}25%{transform:translateX(-3px)}75%{transform:translateX(3px)}}`}</style>
    </div>
  );
}

const svg = { fill: "none", stroke: "currentColor", strokeWidth: 2, strokeLinecap: "round" as const, strokeLinejoin: "round" as const };
function Check() { return <svg viewBox="0 0 24 24" className="h-3.5 w-3.5" {...svg}><path d="M20 6 9 17l-5-5" /></svg>; }
function Flame() { return <svg viewBox="0 0 24 24" className="h-3 w-3" {...svg}><path d="M12 3c1.5 3 4 4.5 4 8a4 4 0 0 1-8 0c0-1.2.5-2.2 1.2-3C9 9.5 10.5 7 12 3Z" /></svg>; }
function Teacher() { return <svg viewBox="0 0 24 24" className="h-3.5 w-3.5" {...svg}><circle cx="12" cy="7" r="3" /><path d="M5 21v-1a7 7 0 0 1 14 0v1" /></svg>; }
function Devices() { return <svg viewBox="0 0 24 24" className="h-3 w-3" {...svg}><rect x="3" y="5" width="13" height="9" rx="1" /><rect x="17" y="8" width="4" height="11" rx="1" /></svg>; }
function Dot({ d = "0ms" }: { d?: string }) {
  return <span className="h-1.5 w-1.5 rounded-full bg-slate-300" style={{ animation: "pulse 1s infinite", animationDelay: d }} />;
}
