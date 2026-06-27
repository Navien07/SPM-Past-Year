import Link from "next/link";
import { prisma } from "@/lib/db";
import Icon from "@/components/Icon";

export const dynamic = "force-dynamic";
export const maxDuration = 60;

function pct(n: number) {
  return `${Math.round(n)}%`;
}
function hrs(sec: number) {
  const h = sec / 3600;
  return h >= 1 ? `${h.toFixed(0)}h` : `${Math.round(sec / 60)}m`;
}

// Raw rows we read for cohort + behavioural signals (single round-trips, no
// loading every attempt into memory).
type SubjRow = { name: string; n: bigint; score: number; max: number };
type StudentRow = {
  id: string; name: string; school: string | null; state: string | null;
  attempts: bigint; distinct_q: bigint; score: number; max: number; last_at: Date | null;
};

export default async function InsightsPage() {
  let err = false;
  // Cohort aggregates
  let totalStudents = 0, totalAttempts = 0, sumScore = 0, sumMax = 0, studySec = 0, attemptSec = 0;
  let active7 = 0, active30 = 0;
  let rushWrong = 0, gradedAi = 0, retried = 0, distinctAttempted = 0;
  let subjRows: SubjRow[] = [];
  let students: StudentRow[] = [];
  let daily: { d: string; n: number }[] = [];

  try {
    const now = Date.now();
    const d7 = new Date(now - 7 * 86400000);
    const d30 = new Date(now - 30 * 86400000);
    const d14 = new Date(now - 14 * 86400000);

    totalStudents = await prisma.student.count();
    totalAttempts = await prisma.attempt.count();
    const agg = await prisma.attempt.aggregate({ _sum: { score: true, maxScore: true, timeSpentSec: true } });
    sumScore = agg._sum.score ?? 0;
    sumMax = agg._sum.maxScore ?? 0;
    attemptSec = agg._sum.timeSpentSec ?? 0;
    studySec = (await prisma.studySession.aggregate({ _sum: { durationSec: true } }))._sum.durationSec ?? 0;

    active7 = (await prisma.attempt.groupBy({ by: ["studentId"], where: { createdAt: { gte: d7 } } })).length;
    active30 = (await prisma.attempt.groupBy({ by: ["studentId"], where: { createdAt: { gte: d30 } } })).length;
    gradedAi = await prisma.attempt.count({ where: { gradedByAi: true } });
    // Rushing: fast (<20s) but not full marks — a behavioural signal of guessing.
    rushWrong = await prisma.attempt.count({ where: { timeSpentSec: { lt: 20, gt: 0 }, isCorrect: false } });
    // Retry depth: distinct questions vs total attempts.
    distinctAttempted = (await prisma.attempt.groupBy({ by: ["questionId"] })).length;
    retried = totalAttempts - distinctAttempted;

    // Per-subject performance across the whole cohort.
    subjRows = await prisma.$queryRawUnsafe<SubjRow[]>(
      `SELECT s.name, count(*)::bigint n, sum(a.score) score, sum(a."maxScore") max
       FROM "Attempt" a JOIN "Question" q ON q.id = a."questionId" JOIN "Subject" s ON s.id = q."subjectId"
       GROUP BY s.name ORDER BY n DESC`,
    );

    // Daily active-attempt volume, last 14 days.
    const dailyRows = await prisma.$queryRawUnsafe<{ d: string; n: bigint }[]>(
      `SELECT to_char(date_trunc('day', "createdAt"), 'MM-DD') d, count(*)::bigint n
       FROM "Attempt" WHERE "createdAt" >= $1 GROUP BY 1 ORDER BY 1`,
      d14,
    );
    daily = dailyRows.map((r) => ({ d: r.d, n: Number(r.n) }));

    // Per-student leaderboard / at-risk table.
    students = await prisma.$queryRawUnsafe<StudentRow[]>(
      `SELECT st.id, st.name, st.school, st.state,
              count(a.id)::bigint attempts,
              count(DISTINCT a."questionId")::bigint distinct_q,
              coalesce(sum(a.score),0) score, coalesce(sum(a."maxScore"),0) max,
              max(a."createdAt") last_at
       FROM "Student" st LEFT JOIN "Attempt" a ON a."studentId" = st.id
       GROUP BY st.id, st.name, st.school, st.state
       ORDER BY attempts DESC LIMIT 200`,
    );
  } catch {
    err = true;
  }

  if (err) {
    return (
      <div className="card mx-auto max-w-xl p-8 text-center">
        <div className="mx-auto grid h-14 w-14 place-items-center rounded-2xl bg-amber-50 text-amber-600"><Icon name="alert" className="h-7 w-7" /></div>
        <h1 className="mt-3 text-xl font-bold">Couldn&apos;t load insights</h1>
        <p className="mt-2 text-sm text-slate-600">A query failed. Try again shortly.</p>
      </div>
    );
  }

  const avg = sumMax > 0 ? (sumScore / sumMax) * 100 : 0;
  const totalSec = studySec + attemptSec;
  const avgTimePerQ = totalAttempts > 0 ? attemptSec / totalAttempts : 0;
  const rushRate = totalAttempts > 0 ? (rushWrong / totalAttempts) * 100 : 0;
  const aiRate = totalAttempts > 0 ? (gradedAi / totalAttempts) * 100 : 0;
  const maxDaily = Math.max(1, ...daily.map((x) => x.n));
  const now = Date.now();

  const subj = subjRows.map((r) => ({ name: r.name, n: Number(r.n), pct: Number(r.max) > 0 ? (Number(r.score) / Number(r.max)) * 100 : 0 }));
  const roster = students.map((r) => {
    const attempts = Number(r.attempts);
    const distinct = Number(r.distinct_q);
    const avgPct = Number(r.max) > 0 ? (Number(r.score) / Number(r.max)) * 100 : 0;
    const lastDays = r.last_at ? Math.floor((now - new Date(r.last_at).getTime()) / 86400000) : null;
    const atRisk = attempts === 0 || (lastDays != null && lastDays > 7) || (attempts >= 5 && avgPct < 40);
    return { ...r, attempts, distinct, avgPct, lastDays, atRisk };
  });
  const atRisk = roster.filter((r) => r.atRisk);

  const cards = [
    { label: "Students", value: totalStudents, icon: "users" },
    { label: "Active (7d)", value: active7, icon: "activity" },
    { label: "Active (30d)", value: active30, icon: "flame" },
    { label: "Attempts", value: totalAttempts.toLocaleString("en-MY"), icon: "check" },
    { label: "Avg score", value: pct(avg), icon: "progress" },
    { label: "Study time", value: hrs(totalSec), icon: "clock" },
  ];

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between gap-3">
        <div>
          <h1 className="font-display text-2xl font-bold">Student insights</h1>
          <p className="text-sm text-slate-500">Cohort performance, engagement and behavioural signals.</p>
        </div>
        <Link href="/admin" className="inline-flex items-center gap-1.5 text-sm font-semibold text-brand-600 hover:underline"><Icon name="arrow" className="h-4 w-4 rotate-180" /> Admin</Link>
      </div>

      {/* Cohort cards */}
      <div className="grid grid-cols-2 gap-3 sm:grid-cols-3 lg:grid-cols-6">
        {cards.map((c) => (
          <div key={c.label} className="card p-4">
            <div className="mb-1 text-slate-400"><Icon name={c.icon} className="h-5 w-5" /></div>
            <div className="text-2xl font-bold text-brand-700">{c.value}</div>
            <div className="text-xs text-slate-500">{c.label}</div>
          </div>
        ))}
      </div>

      {/* Behavioural signals */}
      <section>
        <h2 className="mb-2 text-sm font-bold uppercase tracking-wide text-slate-500">Behavioural signals</h2>
        <div className="grid grid-cols-2 gap-3 lg:grid-cols-4">
          <div className="card p-4"><div className="text-xl font-bold">{Math.round(avgTimePerQ)}s</div><div className="text-xs text-slate-500">Avg time / question</div></div>
          <div className="card p-4"><div className="text-xl font-bold">{pct(rushRate)}</div><div className="text-xs text-slate-500">Rushed &amp; wrong (&lt;20s)</div></div>
          <div className="card p-4"><div className="text-xl font-bold">{retried.toLocaleString("en-MY")}</div><div className="text-xs text-slate-500">Retry attempts</div></div>
          <div className="card p-4"><div className="text-xl font-bold">{pct(aiRate)}</div><div className="text-xs text-slate-500">AI-graded</div></div>
        </div>
      </section>

      {/* Daily activity */}
      <section>
        <h2 className="mb-2 text-sm font-bold uppercase tracking-wide text-slate-500">Daily activity (14 days)</h2>
        <div className="card flex items-end gap-1.5 overflow-x-auto p-4" style={{ height: 140 }}>
          {daily.length === 0 ? <p className="text-sm text-slate-400">No activity yet.</p> : daily.map((x) => (
            <div key={x.d} className="flex flex-col items-center gap-1">
              <div className="w-6 rounded-t bg-brand-500" style={{ height: `${Math.max(4, (x.n / maxDaily) * 100)}%` }} title={`${x.n} attempts`} />
              <span className="text-[10px] text-slate-400">{x.d}</span>
            </div>
          ))}
        </div>
      </section>

      {/* Subject performance */}
      <section>
        <h2 className="mb-2 text-sm font-bold uppercase tracking-wide text-slate-500">Performance by subject (cohort)</h2>
        <div className="card space-y-3 p-4">
          {subj.length === 0 ? <p className="text-sm text-slate-400">No attempts yet.</p> : subj.map((s) => (
            <div key={s.name} className="flex items-center gap-3">
              <span className="w-36 truncate text-sm">{s.name}</span>
              <div className="h-2.5 flex-1 overflow-hidden rounded-full bg-slate-100">
                <div className={`h-full ${s.pct >= 70 ? "bg-emerald-500" : s.pct >= 40 ? "bg-amber-500" : "bg-red-500"}`} style={{ width: `${s.pct}%` }} />
              </div>
              <span className="w-10 text-right text-sm font-semibold">{pct(s.pct)}</span>
              <span className="w-16 text-right text-xs text-slate-400">{s.n.toLocaleString("en-MY")}</span>
            </div>
          ))}
        </div>
      </section>

      {/* At-risk */}
      {atRisk.length > 0 && (
        <section>
          <h2 className="mb-2 flex items-center gap-2 text-sm font-bold uppercase tracking-wide text-amber-600">
            <Icon name="alert" className="h-4 w-4" /> At-risk ({atRisk.length})
          </h2>
          <div className="card divide-y divide-slate-100">
            {atRisk.slice(0, 20).map((r) => (
              <Link key={r.id} href={`/admin/students/${r.id}`} className="flex items-center justify-between gap-3 px-4 py-2.5 hover:bg-slate-50">
                <div className="min-w-0">
                  <p className="truncate text-sm font-medium">{r.name}</p>
                  <p className="text-xs text-slate-400">{r.school ?? "-"}{r.state ? ` · ${r.state}` : ""}</p>
                </div>
                <span className="shrink-0 text-xs text-slate-500">
                  {r.attempts === 0 ? "never practised" : `${r.attempts} attempts · ${pct(r.avgPct)}${r.lastDays != null ? ` · ${r.lastDays}d ago` : ""}`}
                </span>
              </Link>
            ))}
          </div>
        </section>
      )}

      {/* Roster */}
      <section>
        <h2 className="mb-2 text-sm font-bold uppercase tracking-wide text-slate-500">All students</h2>
        <div className="card overflow-x-auto p-0">
          <table className="w-full text-sm">
            <thead className="bg-slate-50 text-left text-xs uppercase tracking-wide text-slate-500">
              <tr>
                <th className="px-4 py-2 font-semibold">Student</th>
                <th className="px-4 py-2 font-semibold">School</th>
                <th className="px-4 py-2 text-right font-semibold">Attempts</th>
                <th className="px-4 py-2 text-right font-semibold">Questions</th>
                <th className="px-4 py-2 text-right font-semibold">Avg</th>
                <th className="px-4 py-2 text-right font-semibold">Last seen</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {roster.map((r) => (
                <tr key={r.id} className="hover:bg-slate-50">
                  <td className="px-4 py-2"><Link href={`/admin/students/${r.id}`} className="font-medium text-brand-700 hover:underline">{r.name}</Link></td>
                  <td className="px-4 py-2 text-slate-500">{r.school ?? "-"}</td>
                  <td className="px-4 py-2 text-right">{r.attempts}</td>
                  <td className="px-4 py-2 text-right">{r.distinct}</td>
                  <td className="px-4 py-2 text-right font-semibold">{r.attempts > 0 ? pct(r.avgPct) : "-"}</td>
                  <td className="px-4 py-2 text-right text-slate-500">{r.lastDays == null ? "never" : r.lastDays === 0 ? "today" : `${r.lastDays}d`}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </section>
    </div>
  );
}
