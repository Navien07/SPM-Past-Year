import { prisma } from "@/lib/db";
import { requireStudent } from "@/lib/student";
import { bandForPercent } from "@/lib/constants";
import PrintButton from "@/components/PrintButton";

export const dynamic = "force-dynamic";
export const maxDuration = 60;

function fmtDuration(sec: number) {
  const h = Math.floor(sec / 3600);
  const m = Math.round((sec % 3600) / 60);
  return h > 0 ? `${h}h ${m}m` : `${m}m`;
}

// Printable progress report → "Save as PDF" via the browser. Print CSS hides
// the app chrome so it exports as a clean one/two-page document.
export default async function ReportPage() {
  const student = await requireStudent();

  const attempts = await prisma.attempt.findMany({
    where: { studentId: student.id },
    orderBy: { createdAt: "asc" },
    include: { question: { include: { subject: true, topic: true } } },
  });
  const sessions = await prisma.studySession.findMany({ where: { studentId: student.id } });

  const totalAttempts = attempts.length;
  const distinct = new Set(attempts.map((a) => a.questionId)).size;
  const avgPct = totalAttempts
    ? Math.round((attempts.reduce((a, x) => a + (x.maxScore ? x.score / x.maxScore : 0), 0) / totalAttempts) * 100)
    : 0;
  const totalTime = sessions.reduce((a, s) => a + s.durationSec, 0) + attempts.reduce((a, x) => a + x.timeSpentSec, 0);

  const bySubject = new Map<string, { sum: number; n: number; topics: Map<string, { sum: number; n: number }> }>();
  for (const a of attempts) {
    const name = a.question.subject.name;
    const cur = bySubject.get(name) ?? { sum: 0, n: 0, topics: new Map() };
    const p = a.maxScore ? (a.score / a.maxScore) * 100 : 0;
    cur.sum += p;
    cur.n += 1;
    const tName = a.question.topic?.title ?? "General";
    const tc = cur.topics.get(tName) ?? { sum: 0, n: 0 };
    tc.sum += p;
    tc.n += 1;
    cur.topics.set(tName, tc);
    bySubject.set(name, cur);
  }
  const subjects = [...bySubject.entries()]
    .map(([name, v]) => ({
      name,
      pct: Math.round(v.sum / v.n),
      n: v.n,
      topics: [...v.topics.entries()].map(([t, tv]) => ({ t, pct: Math.round(tv.sum / tv.n), n: tv.n })).sort((a, b) => a.pct - b.pct),
    }))
    .sort((a, b) => b.pct - a.pct);

  const weakest = [...subjects].reverse().slice(0, 3);
  const today = new Date().toLocaleDateString("en-MY", { day: "numeric", month: "long", year: "numeric" });

  return (
    <div className="mx-auto max-w-3xl space-y-6">
      <div className="no-print flex items-center justify-between">
        <h1 className="text-2xl font-bold">Progress Report</h1>
        <PrintButton />
      </div>

      {/* Report document */}
      <div className="card space-y-6 p-6 sm:p-8">
        {/* letterhead */}
        <div className="flex items-center justify-between border-b border-slate-200 pb-4 print-block">
          <div className="flex items-center gap-3">
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img src="/icon.svg" alt="SPM AI" className="h-10 w-10 rounded-lg" />
            <div>
              <div className="font-display text-lg font-black">SPM<span className="text-accent-500">AI</span></div>
              <div className="text-xs text-slate-500">Progress Report · Laporan Kemajuan</div>
            </div>
          </div>
          <div className="text-right text-xs text-slate-500">{today}</div>
        </div>

        {/* student */}
        <div className="print-block">
          <h2 className="text-xl font-bold">{student.name}</h2>
          <p className="text-sm text-slate-500">
            {student.school ? `${student.school} · ` : ""}Tingkatan {student.form}
            {student.state ? ` · ${student.state}` : ""}
          </p>
        </div>

        {/* headline stats */}
        <div className="grid grid-cols-2 gap-3 sm:grid-cols-4 print-block">
          {[
            { label: "Questions done", value: distinct },
            { label: "Total attempts", value: totalAttempts },
            { label: "Average score", value: `${avgPct}%` },
            { label: "Time on task", value: fmtDuration(totalTime) },
          ].map((s) => (
            <div key={s.label} className="rounded-xl border border-slate-200 p-3 text-center">
              <div className="text-2xl font-bold text-brand-700">{s.value}</div>
              <div className="mt-0.5 text-xs text-slate-500">{s.label}</div>
            </div>
          ))}
        </div>

        <div className="rounded-xl bg-slate-50 p-4 text-sm print-block">
          <span className="font-semibold">Overall band: </span>
          {totalAttempts ? bandForPercent(avgPct) : "No attempts yet"}.
          {weakest.length > 0 && (
            <> Focus next on <strong>{weakest.map((w) => w.name).join(", ")}</strong>.</>
          )}
        </div>

        {/* per-subject */}
        <div className="space-y-4">
          <h3 className="text-sm font-bold uppercase tracking-wide text-slate-500">Performance by subject</h3>
          {subjects.length === 0 && <p className="text-sm text-slate-400">No attempts recorded yet.</p>}
          {subjects.map((s) => (
            <div key={s.name} className="print-block">
              <div className="flex items-center justify-between text-sm font-semibold">
                <span>{s.name}</span>
                <span>{s.pct}% · {s.n} attempts</span>
              </div>
              <div className="mt-1 h-2 overflow-hidden rounded-full bg-slate-100">
                <div className={`h-full ${s.pct >= 70 ? "bg-emerald-500" : s.pct >= 40 ? "bg-amber-500" : "bg-red-500"}`} style={{ width: `${s.pct}%` }} />
              </div>
              {s.topics.length > 0 && (
                <div className="mt-1.5 text-xs text-slate-500">
                  Weakest topic: <strong>{s.topics[0].t}</strong> ({s.topics[0].pct}%)
                </div>
              )}
            </div>
          ))}
        </div>

        <p className="border-t border-slate-200 pt-4 text-center text-xs text-slate-400 print-block">
          Generated by SPM AI · Helping students across Malaysia 🇲🇾
        </p>
      </div>
    </div>
  );
}
