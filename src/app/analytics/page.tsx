import Link from "next/link";
import { prisma } from "@/lib/db";
import { requireStudent } from "@/lib/student";

export const dynamic = "force-dynamic";
export const maxDuration = 60;

function fmtDuration(sec: number) {
  const h = Math.floor(sec / 3600);
  const m = Math.round((sec % 3600) / 60);
  return h > 0 ? `${h}h ${m}m` : `${m}m`;
}

function AnalyticsError() {
  return (
    <div className="card mx-auto max-w-xl p-8 text-center">
      <div className="text-4xl">⚠️</div>
      <h1 className="mt-3 text-xl font-bold">Couldn&apos;t load your progress</h1>
      <p className="mt-2 text-sm text-slate-600">A database query failed. Try again in a moment.</p>
      <p className="mt-3 text-xs text-slate-500">
        Persisting? Open <a href="/api/health" className="font-semibold text-brand-600 hover:underline">/api/health</a> for a diagnosis.
      </p>
    </div>
  );
}

export default async function AnalyticsPage() {
  const student = await requireStudent();

  let attempts, sessions, enrolledSubjectIds: string[], totalApprovedInEnrolled: number, topicsTotal: number, topicsDone: number;
  try {
    attempts = await prisma.attempt.findMany({
      where: { studentId: student.id },
      orderBy: { createdAt: "asc" },
      include: { question: { include: { subject: true, topic: true } } },
    });
    sessions = await prisma.studySession.findMany({ where: { studentId: student.id } });

    // Topics done vs left across the student's enrolled subjects.
    const enrollments = await prisma.enrollment.findMany({ where: { studentId: student.id }, select: { subjectId: true } });
    enrolledSubjectIds = enrollments.map((e) => e.subjectId);
    const topicsWithApproved = await prisma.topic.findMany({
      where: { subjectId: { in: enrolledSubjectIds }, questions: { some: { status: "approved" } } },
      select: { id: true },
    });
    topicsTotal = topicsWithApproved.length;
    const doneTopicIds = new Set(attempts.map((a) => a.question.topicId).filter(Boolean) as string[]);
    topicsDone = topicsWithApproved.filter((t) => doneTopicIds.has(t.id)).length;
    totalApprovedInEnrolled = await prisma.question.count({ where: { subjectId: { in: enrolledSubjectIds }, status: "approved" } });
  } catch {
    return <AnalyticsError />;
  }

  const totalTime = sessions.reduce((a, s) => a + s.durationSec, 0) + attempts.reduce((a, x) => a + x.timeSpentSec, 0);
  const totalAttempts = attempts.length;
  const distinctDone = new Set(attempts.map((a) => a.questionId)).size;
  const avgPct =
    totalAttempts === 0
      ? 0
      : Math.round((attempts.reduce((a, x) => a + (x.maxScore ? x.score / x.maxScore : 0), 0) / totalAttempts) * 100);

  const bySubject = new Map<string, { name: string; sum: number; n: number }>();
  for (const a of attempts) {
    const name = a.question.subject.name;
    const cur = bySubject.get(name) ?? { name, sum: 0, n: 0 };
    cur.sum += a.maxScore ? (a.score / a.maxScore) * 100 : 0;
    cur.n += 1;
    bySubject.set(name, cur);
  }
  const subjectMastery = [...bySubject.values()].map((s) => ({ name: s.name, pct: Math.round(s.sum / s.n) })).sort((a, b) => b.pct - a.pct);
  const weakest = [...subjectMastery].reverse().slice(0, 2);

  const trend = attempts.map((a) => ({
    label: a.question.subject.code ?? a.question.subject.name.slice(0, 3),
    pct: a.maxScore ? Math.round((a.score / a.maxScore) * 100) : 0,
    aiGraded: a.gradedByAi,
  }));

  const stats = [
    { label: "Attempts", value: totalAttempts },
    { label: "Avg score", value: `${avgPct}%` },
    { label: "Time on task", value: fmtDuration(totalTime) },
    { label: "Subjects practised", value: subjectMastery.length },
  ];

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold">Progress 📊</h1>
        <p className="text-sm text-slate-500">{student.name}&apos;s learning analytics.</p>
      </div>

      {/* Summary of where you are */}
      <div className="card p-5">
        <h2 className="mb-2 font-bold">Summary</h2>
        <p className="text-sm text-slate-700">
          You&apos;ve attempted <strong>{distinctDone}</strong> of <strong>{totalApprovedInEnrolled}</strong> questions
          across your enrolled subjects, covering <strong>{topicsDone}</strong> of <strong>{topicsTotal}</strong> topics
          (<strong>{topicsTotal - topicsDone}</strong> topics still to start). Your average score is <strong>{avgPct}%</strong>.
          {weakest.length > 0 && (
            <> Focus next on <strong>{weakest.map((w) => w.name).join(" & ")}</strong>.</>
          )}
        </p>
        <div className="mt-3 flex flex-wrap gap-2">
          <Link href="/practice" className="btn-primary">Continue practising</Link>
          <Link href="/tutor" className="btn-ghost">🧭 Full AI analysis</Link>
          <Link href="/report" className="btn-ghost">📄 PDF report</Link>
        </div>
      </div>

      <div className="grid grid-cols-2 gap-3 sm:grid-cols-4">
        {stats.map((s) => (
          <div key={s.label} className="card p-4 text-center">
            <div className="text-2xl font-bold text-brand-700">{s.value}</div>
            <div className="mt-1 text-xs text-slate-500">{s.label}</div>
          </div>
        ))}
      </div>

      {totalAttempts === 0 ? (
        <div className="card p-8 text-center">
          <p className="text-slate-500">No attempts yet.</p>
          <Link href="/practice" className="btn-primary mt-3">Start practising</Link>
        </div>
      ) : (
        <>
          <section>
            <h2 className="mb-2 text-sm font-bold uppercase tracking-wide text-slate-500">Mastery by subject</h2>
            <div className="card space-y-3 p-4">
              {subjectMastery.map((s) => (
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

          <section>
            <h2 className="mb-2 text-sm font-bold uppercase tracking-wide text-slate-500">Score trend (per attempt)</h2>
            <div className="card flex items-end gap-2 overflow-x-auto p-4" style={{ height: 160 }}>
              {trend.map((t, i) => (
                <div key={i} className="flex flex-col items-center gap-1">
                  <div className={`w-6 rounded-t ${t.pct >= 50 ? "bg-brand-500" : "bg-amber-400"}`} style={{ height: `${Math.max(6, t.pct)}%` }} title={`${t.pct}%${t.aiGraded ? " (AI)" : ""}`} />
                  <span className="text-[10px] text-slate-400">{t.label}</span>
                </div>
              ))}
            </div>
          </section>
        </>
      )}
    </div>
  );
}
