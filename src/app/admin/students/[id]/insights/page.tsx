import Link from "next/link";
import { notFound } from "next/navigation";
import { prisma } from "@/lib/db";
import Icon from "@/components/Icon";

export const dynamic = "force-dynamic";
export const maxDuration = 60;

const FAST_SEC = 30; // below this is "quick" — used for pace profiling

function pct(n: number) {
  return `${Math.round(n)}%`;
}
function fmtMin(sec: number) {
  const m = Math.round(sec / 60);
  if (m >= 60) return `${(m / 60).toFixed(1)}h`;
  return `${m}m`;
}

export default async function StudentInsights({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  const student = await prisma.student.findUnique({
    where: { id },
    include: {
      attempts: { orderBy: { createdAt: "asc" }, include: { question: { include: { subject: true, topic: true } } } },
      sessions: true,
      reviewItems: true,
    },
  });
  if (!student) notFound();

  const a = student.attempts;
  const n = a.length;
  const correctOf = (x: (typeof a)[number]) => (x.isCorrect != null ? x.isCorrect : x.maxScore > 0 && x.score / x.maxScore >= 0.5);
  const ratio = (x: (typeof a)[number]) => (x.maxScore > 0 ? x.score / x.maxScore : 0);

  // ── Accuracy ──
  const avgPct = n ? (a.reduce((s, x) => s + ratio(x), 0) / n) * 100 : 0;

  // ── Pace profile (speed × correctness) ──
  const timed = a.filter((x) => x.timeSpentSec > 0);
  const buckets = { fastRight: 0, fastWrong: 0, slowRight: 0, slowWrong: 0 };
  for (const x of timed) {
    const fast = x.timeSpentSec < FAST_SEC;
    const right = correctOf(x);
    if (fast && right) buckets.fastRight++;
    else if (fast && !right) buckets.fastWrong++;
    else if (!fast && right) buckets.slowRight++;
    else buckets.slowWrong++;
  }
  const avgTime = timed.length ? timed.reduce((s, x) => s + x.timeSpentSec, 0) / timed.length : 0;
  const rushRate = timed.length ? (buckets.fastWrong / timed.length) * 100 : 0;

  // ── Trend (first half vs second half average) ──
  const half = Math.floor(n / 2);
  const firstAvg = half ? (a.slice(0, half).reduce((s, x) => s + ratio(x), 0) / half) * 100 : 0;
  const secondAvg = n - half ? (a.slice(half).reduce((s, x) => s + ratio(x), 0) / (n - half)) * 100 : 0;
  const trendDelta = secondAvg - firstAvg;

  // ── Consistency (active days, streak, cadence) ──
  const dayKey = (d: Date) => d.toISOString().slice(0, 10);
  const days = [...new Set(a.map((x) => dayKey(x.createdAt)))].sort();
  const activeDays = days.length;
  let streak = 0;
  if (days.length) {
    const cur = new Date();
    if (!days.includes(dayKey(cur))) cur.setDate(cur.getDate() - 1);
    while (days.includes(dayKey(cur))) { streak++; cur.setDate(cur.getDate() - 1); }
  }
  const spanDays = days.length > 1 ? (new Date(days[days.length - 1]).getTime() - new Date(days[0]).getTime()) / 86400000 + 1 : 1;
  const cadence = spanDays > 0 ? (activeDays / spanDays) * 100 : 0; // % of days active in their window

  // ── Difficulty handling (KBAT vs non-KBAT) ──
  const kbat = a.filter((x) => x.question.isKbat);
  const nonKbat = a.filter((x) => !x.question.isKbat);
  const kbatAvg = kbat.length ? (kbat.reduce((s, x) => s + ratio(x), 0) / kbat.length) * 100 : 0;
  const nonKbatAvg = nonKbat.length ? (nonKbat.reduce((s, x) => s + ratio(x), 0) / nonKbat.length) * 100 : 0;

  // ── Resilience (retries that improved) ──
  const byQ = new Map<string, (typeof a)[number][]>();
  for (const x of a) { const arr = byQ.get(x.questionId) ?? []; arr.push(x); byQ.set(x.questionId, arr); }
  const retried = [...byQ.values()].filter((xs) => xs.length > 1);
  const improvedRetries = retried.filter((xs) => ratio(xs[xs.length - 1]) > ratio(xs[0])).length;
  const resilience = retried.length ? (improvedRetries / retried.length) * 100 : 0;

  // ── Coverage ──
  const distinctQ = byQ.size;

  // ── Time per subject (allocation actual) ──
  const subjMap = new Map<string, { name: string; sec: number; n: number; score: number; max: number }>();
  for (const x of a) {
    const k = x.question.subjectId;
    const cur = subjMap.get(k) ?? { name: x.question.subject.name, sec: 0, n: 0, score: 0, max: 0 };
    cur.sec += x.timeSpentSec; cur.n++; cur.score += x.score; cur.max += x.maxScore;
    subjMap.set(k, cur);
  }
  for (const s of student.sessions) {
    if (s.subjectId && subjMap.has(s.subjectId)) subjMap.get(s.subjectId)!.sec += s.durationSec;
  }
  const subjects = [...subjMap.values()].sort((x, y) => y.sec - x.sec);
  const totalSubjSec = subjects.reduce((s, x) => s + x.sec, 0) || 1;

  // ── Weak topics ──
  const topicMap = new Map<string, { title: string; subject: string; n: number; score: number; max: number }>();
  for (const x of a) {
    if (!x.question.topic) continue;
    const k = x.question.topicId!;
    const cur = topicMap.get(k) ?? { title: x.question.topic.title, subject: x.question.subject.name, n: 0, score: 0, max: 0 };
    cur.n++; cur.score += x.score; cur.max += x.maxScore;
    topicMap.set(k, cur);
  }
  const weakTopics = [...topicMap.values()]
    .filter((t) => t.n >= 2)
    .map((t) => ({ ...t, pct: t.max > 0 ? (t.score / t.max) * 100 : 0 }))
    .sort((x, y) => x.pct - y.pct)
    .slice(0, 6);

  // ── Time-of-day ──
  const slots = { Morning: 0, Afternoon: 0, Evening: 0, Night: 0 };
  for (const x of a) {
    const h = x.createdAt.getHours();
    if (h >= 5 && h < 12) slots.Morning++;
    else if (h < 17) slots.Afternoon++;
    else if (h < 22) slots.Evening++;
    else slots.Night++;
  }

  // ── Psychometric profile (0-100 traits) ──
  const traits = [
    { key: "Accuracy", v: Math.round(avgPct) },
    { key: "Speed", v: Math.round(Math.max(0, Math.min(100, 100 - (avgTime / 90) * 100))) },
    { key: "Consistency", v: Math.round(cadence) },
    { key: "Resilience", v: Math.round(resilience) },
    { key: "Coverage", v: Math.round(Math.min(100, (distinctQ / 200) * 100)) },
    { key: "Higher-order (KBAT)", v: Math.round(kbatAvg) },
  ];

  // ── Derived learner label ──
  let label = "Getting started";
  if (n >= 5) {
    if (rushRate > 30) label = "Rusher — guesses fast";
    else if (trendDelta > 8) label = "Consistent improver";
    else if (trendDelta < -8) label = "Slipping — needs support";
    else if (cadence < 30) label = "Crammer — irregular study";
    else if (avgPct >= 70) label = "Strong & steady";
    else label = "Steady, building up";
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between gap-3">
        <div>
          <h1 className="font-display text-2xl font-bold">{student.name}</h1>
          <p className="text-sm text-slate-500">Behavioural &amp; learning profile</p>
        </div>
        <Link href={`/admin/students/${id}`} className="inline-flex items-center gap-1.5 text-sm font-semibold text-brand-600 hover:underline"><Icon name="arrow" className="h-4 w-4 rotate-180" /> Profile</Link>
      </div>

      {n === 0 ? (
        <div className="card p-8 text-center text-slate-500">No attempts yet — nothing to analyse.</div>
      ) : (
        <>
          {/* Learner label + psychometric traits */}
          <div className="card p-5">
            <div className="mb-4 flex items-center gap-2">
              <span className="rounded-full bg-brand-50 px-3 py-1 text-sm font-bold text-brand-700">{label}</span>
              <span className="text-xs text-slate-400">{n} attempts · {distinctQ} questions · {activeDays} active days · streak {streak}</span>
            </div>
            <div className="space-y-2.5">
              {traits.map((t) => (
                <div key={t.key} className="flex items-center gap-3">
                  <span className="w-40 truncate text-sm">{t.key}</span>
                  <div className="h-2.5 flex-1 overflow-hidden rounded-full bg-slate-100">
                    <div className={`h-full ${t.v >= 70 ? "bg-emerald-500" : t.v >= 40 ? "bg-amber-500" : "bg-red-500"}`} style={{ width: `${t.v}%` }} />
                  </div>
                  <span className="w-10 text-right text-sm font-semibold">{t.v}</span>
                </div>
              ))}
            </div>
          </div>

          {/* Pace profile + trend */}
          <div className="grid gap-4 lg:grid-cols-2">
            <section className="card p-5">
              <h2 className="mb-3 text-sm font-bold uppercase tracking-wide text-slate-500">Pace profile</h2>
              <div className="grid grid-cols-2 gap-3 text-center">
                <div className="rounded-xl bg-emerald-50 p-3"><div className="text-xl font-bold text-emerald-700">{buckets.fastRight}</div><div className="text-xs text-slate-500">Fast &amp; right (confident)</div></div>
                <div className="rounded-xl bg-red-50 p-3"><div className="text-xl font-bold text-red-700">{buckets.fastWrong}</div><div className="text-xs text-slate-500">Fast &amp; wrong (guessing)</div></div>
                <div className="rounded-xl bg-blue-50 p-3"><div className="text-xl font-bold text-blue-700">{buckets.slowRight}</div><div className="text-xs text-slate-500">Slow &amp; right (working hard)</div></div>
                <div className="rounded-xl bg-amber-50 p-3"><div className="text-xl font-bold text-amber-700">{buckets.slowWrong}</div><div className="text-xs text-slate-500">Slow &amp; wrong (struggling)</div></div>
              </div>
              <p className="mt-3 text-xs text-slate-400">Avg {Math.round(avgTime)}s / question · {pct(rushRate)} rushed-and-wrong</p>
            </section>

            <section className="card p-5">
              <h2 className="mb-3 text-sm font-bold uppercase tracking-wide text-slate-500">Trajectory</h2>
              <div className="flex items-end gap-4">
                <div className="text-center"><div className="text-2xl font-bold text-slate-400">{pct(firstAvg)}</div><div className="text-xs text-slate-500">First half</div></div>
                <Icon name="arrow" className="mb-3 h-5 w-5 text-slate-300" />
                <div className="text-center"><div className="text-2xl font-bold text-brand-700">{pct(secondAvg)}</div><div className="text-xs text-slate-500">Recent half</div></div>
                <div className={`mb-1 ml-auto text-sm font-bold ${trendDelta > 0 ? "text-emerald-600" : trendDelta < 0 ? "text-red-600" : "text-slate-400"}`}>
                  {trendDelta > 0 ? "▲" : trendDelta < 0 ? "▼" : "—"} {Math.abs(Math.round(trendDelta))} pts
                </div>
              </div>
              <div className="mt-4 grid grid-cols-2 gap-3 text-sm">
                <div className="rounded-lg bg-slate-50 p-3"><div className="font-bold">{pct(nonKbatAvg)}</div><div className="text-xs text-slate-500">Standard questions</div></div>
                <div className="rounded-lg bg-slate-50 p-3"><div className="font-bold">{pct(kbatAvg)}</div><div className="text-xs text-slate-500">KBAT (higher-order)</div></div>
              </div>
              <p className="mt-3 text-xs text-slate-400">Resilience: improved on {improvedRetries}/{retried.length} retried questions</p>
            </section>
          </div>

          {/* Time allocation per subject */}
          <section>
            <h2 className="mb-2 text-sm font-bold uppercase tracking-wide text-slate-500">Time spent by subject</h2>
            <div className="card space-y-3 p-4">
              {subjects.map((s) => (
                <div key={s.name} className="flex items-center gap-3">
                  <span className="w-36 truncate text-sm">{s.name}</span>
                  <div className="h-2.5 flex-1 overflow-hidden rounded-full bg-slate-100">
                    <div className="h-full bg-brand-500" style={{ width: `${(s.sec / totalSubjSec) * 100}%` }} />
                  </div>
                  <span className="w-14 text-right text-xs font-semibold">{fmtMin(s.sec)}</span>
                  <span className="w-10 text-right text-xs text-slate-400">{pct(s.max > 0 ? (s.score / s.max) * 100 : 0)}</span>
                </div>
              ))}
            </div>
          </section>

          <div className="grid gap-4 lg:grid-cols-2">
            {/* Weak topics */}
            <section>
              <h2 className="mb-2 text-sm font-bold uppercase tracking-wide text-slate-500">Weakest topics</h2>
              <div className="card divide-y divide-slate-100">
                {weakTopics.length === 0 ? <p className="p-4 text-sm text-slate-400">Not enough data yet.</p> : weakTopics.map((t, i) => (
                  <div key={i} className="flex items-center justify-between gap-3 px-4 py-2.5">
                    <div className="min-w-0"><p className="truncate text-sm font-medium">{t.title}</p><p className="text-xs text-slate-400">{t.subject} · {t.n} attempts</p></div>
                    <span className={`text-sm font-bold ${t.pct < 40 ? "text-red-600" : "text-amber-600"}`}>{pct(t.pct)}</span>
                  </div>
                ))}
              </div>
            </section>

            {/* Study timing */}
            <section>
              <h2 className="mb-2 text-sm font-bold uppercase tracking-wide text-slate-500">When they study</h2>
              <div className="card flex items-end justify-around gap-2 p-4" style={{ height: 160 }}>
                {Object.entries(slots).map(([k, v]) => {
                  const max = Math.max(1, ...Object.values(slots));
                  return (
                    <div key={k} className="flex flex-1 flex-col items-center gap-1">
                      <div className="w-full rounded-t bg-accent-500" style={{ height: `${Math.max(4, (v / max) * 100)}%` }} title={`${v} attempts`} />
                      <span className="text-[10px] text-slate-400">{k}</span>
                    </div>
                  );
                })}
              </div>
            </section>
          </div>
        </>
      )}
    </div>
  );
}
