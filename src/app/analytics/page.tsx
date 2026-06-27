import Link from "next/link";
import { prisma } from "@/lib/db";
import { requireStudent } from "@/lib/student";
import { getLang } from "@/lib/lang-server";
import { t } from "@/lib/i18n";
import Icon from "@/components/Icon";
import ReadinessRing from "@/components/ReadinessRing";
import { subjectReadiness, overallReadiness, BAND_COLOR } from "@/lib/readiness";

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
      <div className="mx-auto grid h-14 w-14 place-items-center rounded-2xl bg-amber-50 text-amber-600"><Icon name="alert" className="h-7 w-7" /></div>
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
  let topicsBySubject = new Map<string, { total: number }>();
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
      select: { id: true, subjectId: true },
    });
    topicsTotal = topicsWithApproved.length;
    const doneTopicIds = new Set(attempts.map((a) => a.question.topicId).filter(Boolean) as string[]);
    topicsDone = topicsWithApproved.filter((t) => doneTopicIds.has(t.id)).length;
    for (const tp of topicsWithApproved) {
      const cur = topicsBySubject.get(tp.subjectId) ?? { total: 0 };
      cur.total += 1;
      topicsBySubject.set(tp.subjectId, cur);
    }
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

  // Per-subject exam readiness (mastery + topic coverage + practice volume).
  const bySubjectId = new Map<string, { name: string; sum: number; n: number; topics: Set<string> }>();
  for (const a of attempts) {
    const id = a.question.subjectId;
    const cur = bySubjectId.get(id) ?? { name: a.question.subject.name, sum: 0, n: 0, topics: new Set<string>() };
    cur.sum += a.maxScore ? (a.score / a.maxScore) * 100 : 0;
    cur.n += 1;
    if (a.question.topicId) cur.topics.add(a.question.topicId);
    bySubjectId.set(id, cur);
  }
  const readinessList = [...bySubjectId.entries()]
    .map(([id, s]) =>
      subjectReadiness({
        name: s.name,
        mastery: s.sum / s.n,
        topicsDone: s.topics.size,
        topicsTotal: topicsBySubject.get(id)?.total ?? s.topics.size,
        attempts: s.n,
      }),
    )
    .sort((a, b) => b.readiness - a.readiness);
  const overall = overallReadiness(readinessList, enrolledSubjectIds.length);
  const overallColor = BAND_COLOR[overall.band];

  const trend = attempts.map((a) => ({
    label: a.question.subject.code ?? a.question.subject.name.slice(0, 3),
    pct: a.maxScore ? Math.round((a.score / a.maxScore) * 100) : 0,
    aiGraded: a.gradedByAi,
  }));

  const lang = await getLang();
  const stats = [
    { label: t(lang, "stat.attempts"), value: totalAttempts },
    { label: t(lang, "stat.avg"), value: `${avgPct}%` },
    { label: t(lang, "stat.time"), value: fmtDuration(totalTime) },
    { label: t(lang, "stat.practised"), value: subjectMastery.length },
  ];

  return (
    <div className="space-y-6">
      <div>
 <h1 className="text-2xl font-bold">{t(lang, "analytics.title")}</h1>
        <p className="text-sm text-slate-500">{student.name}&apos;s learning analytics.</p>
      </div>

      {/* Exam readiness forecast */}
      <div className="card overflow-hidden p-0">
        <div className="flex flex-col items-center gap-6 bg-gradient-to-br from-brand-600 to-accent-600 p-6 text-white sm:flex-row sm:items-center sm:gap-8">
          <div className="rounded-full bg-white p-2 shadow-lg">
            <ReadinessRing value={overall.score} grade={overall.started === 0 ? "?" : overall.grade} color={overallColor.ring} />
          </div>
          <div className="min-w-0 flex-1 text-center sm:text-left">
            <p className="text-xs font-semibold uppercase tracking-wider text-white/70">{t(lang, "readiness.title")}</p>
            <h2 className="font-display mt-1 text-2xl font-bold sm:text-3xl">
              {overall.started === 0 ? t(lang, "readiness.locked") : `${t(lang, "readiness.forecast")} ${overall.grade}`}
            </h2>
            <p className="mt-2 max-w-md text-sm text-white/85">{overall.message}</p>
            <div className="mt-3 flex flex-wrap justify-center gap-2 sm:justify-start">
              <span className="rounded-full bg-white/15 px-3 py-1 text-xs font-medium">{overall.started}/{overall.total} {t(lang, "readiness.subjects")}</span>
              <span className="rounded-full bg-white/15 px-3 py-1 text-xs font-medium">{topicsDone}/{topicsTotal} {t(lang, "readiness.topics")}</span>
              <Link href="/practice" className="rounded-full bg-white px-3 py-1 text-xs font-bold text-brand-700 transition hover:bg-white/90">{t(lang, "readiness.improve")}</Link>
            </div>
          </div>
        </div>
        {readinessList.length > 0 && (
          <div className="divide-y divide-slate-100">
            {readinessList.map((s) => {
              const cc = BAND_COLOR[s.band];
              return (
                <div key={s.name} className="flex items-center gap-3 px-5 py-3">
                  <span className={`grid h-9 w-11 shrink-0 place-items-center rounded-lg ${cc.bg} ${cc.text} font-display text-sm font-bold`}>{s.grade}</span>
                  <div className="min-w-0 flex-1">
                    <div className="flex items-center justify-between gap-2">
                      <span className="truncate text-sm font-medium">{s.name}</span>
                      <span className="text-xs font-semibold text-slate-500">{s.readiness}%</span>
                    </div>
                    <div className="mt-1.5 h-1.5 overflow-hidden rounded-full bg-slate-100">
                      <div className="h-full rounded-full" style={{ width: `${s.readiness}%`, backgroundColor: cc.ring }} />
                    </div>
                    <p className="mt-1 text-[11px] text-slate-400">{s.mastery}% {t(lang, "readiness.accuracy")} · {s.coverage}% {t(lang, "readiness.covered")}</p>
                  </div>
                </div>
              );
            })}
          </div>
        )}
      </div>

      {/* Summary of where you are */}
      <div className="card p-5">
 <h2 className="mb-2 font-bold">{t(lang, "analytics.summary")}</h2>
        <p className="text-sm text-slate-700">
          You&apos;ve attempted <strong>{distinctDone}</strong> of <strong>{totalApprovedInEnrolled}</strong> questions
          across your enrolled subjects, covering <strong>{topicsDone}</strong> of <strong>{topicsTotal}</strong> topics
          (<strong>{topicsTotal - topicsDone}</strong> topics still to start). Your average score is <strong>{avgPct}%</strong>.
          {weakest.length > 0 && (
            <> Focus next on <strong>{weakest.map((w) => w.name).join(" & ")}</strong>.</>
          )}
        </p>
        <div className="mt-3 flex flex-wrap gap-2">
          <Link href="/practice" className="btn-primary">{t(lang, "common.continue")}</Link>
          <Link href="/tutor" className="btn-ghost inline-flex items-center gap-1.5"><Icon name="compass" className="h-4 w-4" /> {t(lang, "analytics.aiAnalysis")}</Link>
          <Link href="/report" className="btn-ghost inline-flex items-center gap-1.5"><Icon name="doc" className="h-4 w-4" /> {t(lang, "analytics.pdf")}</Link>
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
          <p className="text-slate-500">{t(lang, "analytics.noData")}</p>
          <Link href="/practice" className="btn-primary mt-3">{t(lang, "analytics.start")}</Link>
        </div>
      ) : (
        <>
          <section>
 <h2 className="mb-2 text-sm font-bold uppercase tracking-wide text-slate-500">{t(lang, "analytics.mastery")}</h2>
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
 <h2 className="mb-2 text-sm font-bold uppercase tracking-wide text-slate-500">{t(lang, "analytics.trend")}</h2>
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
