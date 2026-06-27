import Link from "next/link";
import { prisma } from "@/lib/db";
import Icon from "@/components/Icon";

export const dynamic = "force-dynamic";
export const maxDuration = 60;

function fmtDuration(sec: number) {
  const h = Math.floor(sec / 3600);
  const m = Math.round((sec % 3600) / 60);
  return h > 0 ? `${h}h ${m}m` : `${m}m`;
}

// Teacher / class view: cohort-wide performance across all pilot students
// averages, mastery by subject, a leaderboard and who needs help.
export default async function ClassPage() {
  let students: Awaited<ReturnType<typeof loadStudents>> = [];
  let subjectAgg: { name: string; pct: number; n: number }[] = [];
  let totals = { students: 0, attempts: 0, avg: 0, time: 0 };

  try {
    students = await loadStudents();

    const attempts = await prisma.attempt.findMany({
      select: { score: true, maxScore: true, timeSpentSec: true, question: { select: { subject: { select: { name: true } } } } },
    });
    totals.students = students.length;
    totals.attempts = attempts.length;
    totals.time = attempts.reduce((a, x) => a + x.timeSpentSec, 0);
    totals.avg = attempts.length
      ? Math.round((attempts.reduce((a, x) => a + (x.maxScore ? x.score / x.maxScore : 0), 0) / attempts.length) * 100)
      : 0;

    const bySubject = new Map<string, { sum: number; n: number }>();
    for (const a of attempts) {
      const name = a.question.subject.name;
      const cur = bySubject.get(name) ?? { sum: 0, n: 0 };
      cur.sum += a.maxScore ? (a.score / a.maxScore) * 100 : 0;
      cur.n += 1;
      bySubject.set(name, cur);
    }
    subjectAgg = [...bySubject.entries()]
      .map(([name, v]) => ({ name, pct: Math.round(v.sum / v.n), n: v.n }))
      .sort((a, b) => b.pct - a.pct);
  } catch {
    return (
      <div className="card mx-auto max-w-xl p-8 text-center">
        <div className="flex justify-center text-amber-600"><Icon name="alert" className="h-10 w-10" /></div>
        <h1 className="mt-3 text-xl font-bold">Couldn&apos;t load the class view</h1>
        <p className="mt-2 text-sm text-slate-600">A database query failed. Try again in a moment.</p>
      </div>
    );
  }

  const leaderboard = [...students].filter((s) => s.attempts > 0).sort((a, b) => b.avg - a.avg).slice(0, 10);
  const needHelp = [...students].filter((s) => s.attempts >= 3).sort((a, b) => a.avg - b.avg).slice(0, 8);

  const stats = [
    { label: "Students", value: totals.students },
    { label: "Total attempts", value: totals.attempts },
    { label: "Class average", value: `${totals.avg}%` },
    { label: "Time on task", value: fmtDuration(totals.time) },
  ];

  return (
    <div className="space-y-6">
      <div>
        <h1 className="flex items-center gap-2 text-2xl font-bold"><Icon name="teacher" className="h-6 w-6" /> Class view</h1>
        <p className="text-sm text-slate-500">Cohort-wide performance across all pilot students.</p>
      </div>

      <div className="grid grid-cols-2 gap-3 sm:grid-cols-4">
        {stats.map((s) => (
          <div key={s.label} className="card p-4 text-center">
            <div className="text-2xl font-bold text-brand-700">{s.value}</div>
            <div className="mt-1 text-xs text-slate-500">{s.label}</div>
          </div>
        ))}
      </div>

      <div className="grid gap-6 lg:grid-cols-2">
        {/* Mastery by subject (whole cohort) */}
        <section>
          <h2 className="mb-2 text-sm font-bold uppercase tracking-wide text-slate-500">Mastery by subject</h2>
          <div className="card space-y-3 p-4">
            {subjectAgg.length === 0 && <p className="text-sm text-slate-400">No attempts yet.</p>}
            {subjectAgg.map((s) => (
              <div key={s.name} className="flex items-center gap-3">
                <span className="w-28 truncate text-sm">{s.name}</span>
                <div className="h-2.5 flex-1 overflow-hidden rounded-full bg-slate-100">
                  <div className={`h-full ${s.pct >= 70 ? "bg-emerald-500" : s.pct >= 40 ? "bg-amber-500" : "bg-red-500"}`} style={{ width: `${s.pct}%` }} />
                </div>
                <span className="w-10 text-right text-sm font-semibold">{s.pct}%</span>
              </div>
            ))}
          </div>
        </section>

        {/* Leaderboard */}
        <section>
          <h2 className="mb-2 text-sm font-bold uppercase tracking-wide text-slate-500">Top performers</h2>
          <div className="card divide-y divide-slate-100">
            {leaderboard.length === 0 && <p className="p-4 text-sm text-slate-400">No ranked students yet.</p>}
            {leaderboard.map((s, i) => (
              <div key={s.id} className="flex items-center justify-between gap-3 p-3">
                <div className="flex items-center gap-3">
                  <span className={`grid h-7 w-7 place-items-center rounded-full text-xs font-bold ${i < 3 ? "bg-amber-400 text-amber-950" : "bg-slate-100 text-slate-500"}`}>{i + 1}</span>
                  <Link href={`/admin/students/${s.id}`} className="font-medium text-brand-700 hover:underline">{s.name}</Link>
                </div>
                <div className="text-right text-sm">
                  <span className="font-semibold">{s.avg}%</span>
                  <span className="ml-2 text-xs text-slate-400">{s.attempts} att.</span>
                </div>
              </div>
            ))}
          </div>
        </section>
      </div>

      {/* Needs attention */}
      <section>
        <h2 className="mb-2 text-sm font-bold uppercase tracking-wide text-slate-500">Needs attention</h2>
        <div className="card overflow-x-auto">
          <table className="w-full text-sm">
            <thead className="border-b border-slate-200 bg-slate-50 text-left text-xs uppercase tracking-wide text-slate-500">
              <tr>
                <th className="px-4 py-3">Student</th>
                <th className="px-4 py-3">School</th>
                <th className="px-4 py-3">Attempts</th>
                <th className="px-4 py-3">Avg score</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {needHelp.length === 0 && (
                <tr><td colSpan={4} className="px-4 py-6 text-center text-slate-400">Not enough data yet.</td></tr>
              )}
              {needHelp.map((s) => (
                <tr key={s.id} className="hover:bg-slate-50">
                  <td className="px-4 py-3">
                    <Link href={`/admin/students/${s.id}`} className="font-medium text-brand-700 hover:underline">{s.name}</Link>
                    <div className="text-xs text-slate-400">{s.email}</div>
                  </td>
                  <td className="px-4 py-3 text-slate-600">{s.school ?? "-"}</td>
                  <td className="px-4 py-3">{s.attempts}</td>
                  <td className="px-4 py-3">
                    <span className={`badge ${s.avg >= 70 ? "bg-emerald-100 text-emerald-700" : s.avg >= 40 ? "bg-amber-100 text-amber-700" : "bg-red-100 text-red-700"}`}>{s.avg}%</span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </section>
    </div>
  );
}

async function loadStudents() {
  const students = await prisma.student.findMany({
    orderBy: { createdAt: "asc" },
    include: { attempts: { select: { score: true, maxScore: true } } },
  });
  return students.map((s) => {
    const n = s.attempts.length;
    const avg = n === 0 ? 0 : Math.round((s.attempts.reduce((a, x) => a + (x.maxScore ? x.score / x.maxScore : 0), 0) / n) * 100);
    return { id: s.id, name: s.name, email: s.email, school: s.school, attempts: n, avg };
  });
}
