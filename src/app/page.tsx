import Link from "next/link";
import { redirect } from "next/navigation";
import { prisma } from "@/lib/db";
import { aiEnabled } from "@/lib/ai";
import { getCurrentUser, roleHome } from "@/lib/auth";
import { PILOT_MAX_STUDENTS } from "@/lib/constants";
import { getLang } from "@/lib/lang-server";
import { t } from "@/lib/i18n";
import SmartPracticeButton from "@/components/SmartPracticeButton";
import Landing from "@/components/Landing";
import Icon from "@/components/Icon";
import GoalCelebrate from "@/components/GoalCelebrate";
import { computeGameStats } from "@/lib/gamify";

function SetupNeeded() {
  return (
    <div className="card mx-auto max-w-xl p-8 text-center">
      <div className="mx-auto grid h-14 w-14 place-items-center rounded-2xl bg-slate-100 text-slate-500"><Icon name="bolt" className="h-7 w-7" /></div>
      <h1 className="mt-3 text-xl font-bold">Database not ready yet</h1>
      <p className="mt-2 text-sm text-slate-600">
        The app is deployed but the database tables haven&apos;t been created/seeded. Run the
        one-time setup against your Supabase database:
      </p>
      <pre className="mt-3 overflow-x-auto rounded-xl bg-slate-900 p-3 text-left text-xs text-slate-100">
{`DATABASE_URL="<session-pooler-uri>" \\
DIRECT_URL="<session-pooler-uri>" \\
npm run db:deploy`}
      </pre>
      <p className="mt-3 text-xs text-slate-500">
        Then visit{" "}
        <a href="/api/health" className="font-semibold text-brand-600 hover:underline">/api/health</a>{" "}
        for a live diagnosis (connection, tables, seed, env vars).
      </p>
    </div>
  );
}

export const dynamic = "force-dynamic";

export default async function Home() {
  const user = await getCurrentUser();

  // Public landing page for logged-out visitors.
  if (!user) {
    let taken = 0;
    try {
      taken = await prisma.student.count();
    } catch {
      /* DB not ready, show landing with 0 */
    }
    return <Landing taken={taken} total={PILOT_MAX_STUDENTS} />;
  }
  // Staff go to their dashboards.
  if (user.role !== "student" || !user.student) redirect(roleHome(user.role));
  const student = user.student;

  const DAILY_GOAL = 5;
  let data: { enrolled: number; questions: number; kbat: number; attempts: number } | null = null;
  let resume: { subjectId: string; topicId: string | null; subjectName: string; topicTitle: string | null } | null = null;
  let streakData = { streak: 0, doneToday: 0 };
  let game = computeGameStats({ totalScore: 0, attempts: 0, streak: 0, subjectsPractised: 0 });
  try {
    // All independent queries in one round trip (collocated with the DB region,
    // this keeps the dashboard fast).
    const [enrolled, questions, kbat, attempts, recent, last, scoreAgg, practised] = await Promise.all([
      prisma.enrollment.count({ where: { studentId: student.id, status: "active" } }),
      prisma.question.count({ where: { status: "approved" } }),
      prisma.question.count({ where: { status: "approved", isKbat: true } }),
      prisma.attempt.count({ where: { studentId: student.id } }),
      prisma.attempt.findMany({
        where: { studentId: student.id },
        orderBy: { createdAt: "desc" },
        take: 400,
        select: { createdAt: true },
      }),
      prisma.attempt.findFirst({
        where: { studentId: student.id },
        orderBy: { createdAt: "desc" },
        include: { question: { include: { subject: true, topic: true } } },
      }),
      // Best score per question (dedupes reattempts so XP/level reflect genuine
      // progress, not repeated grinding of the same easy question).
      prisma.attempt.groupBy({ by: ["questionId"], where: { studentId: student.id }, _max: { score: true } }),
      prisma.attempt.findMany({ where: { studentId: student.id }, select: { question: { select: { subjectId: true } } }, distinct: ["questionId"], take: 3000 }),
    ]);
    data = { enrolled, questions, kbat, attempts };
    const subjectsPractised = new Set(practised.map((a) => a.question.subjectId)).size;
    const bestTotalScore = scoreAgg.reduce((a, g) => a + (g._max.score ?? 0), 0);
    const distinctDone = scoreAgg.length;

    // Streak + daily goal from attempt activity.
    const dayKey = (d: Date) => d.toISOString().slice(0, 10);
    const days = new Set(recent.map((a) => dayKey(a.createdAt)));
    let streak = 0;
    const cursor = new Date();
    // Allow today to be empty (streak continues from yesterday) until first practice today.
    if (!days.has(dayKey(cursor))) cursor.setDate(cursor.getDate() - 1);
    while (days.has(dayKey(cursor))) {
      streak++;
      cursor.setDate(cursor.getDate() - 1);
    }
    const todayKey = dayKey(new Date());
    const doneToday = recent.filter((a) => dayKey(a.createdAt) === todayKey).length;

    // "Continue where you left off", most recent attempt's subject/topic.
    streakData = { streak, doneToday };
    game = computeGameStats({ totalScore: bestTotalScore, attempts: distinctDone, streak, subjectsPractised });
    if (last) {
      resume = {
        subjectId: last.question.subjectId,
        topicId: last.question.topicId,
        subjectName: last.question.subject.name,
        topicTitle: last.question.topic?.title ?? null,
      };
    }
  } catch {
    return <SetupNeeded />;
  }
  const { enrolled, questions, kbat, attempts } = data;
  const lang = await getLang();

  const stats = [
    { label: t(lang, "home.statSubjects"), value: enrolled },
    { label: t(lang, "home.statQuestions"), value: questions },
    { label: t(lang, "home.statKbat"), value: kbat },
    { label: t(lang, "home.statAttempts"), value: attempts },
  ];

  const modules = [
    { href: "/practice", icon: "practice", title: "Practice & Instant Grading", desc: "Browse by topic or year, attempt questions, get rubric-based feedback in seconds." },
    { href: "/syllabus", icon: "syllabus", title: "KSSM Syllabus", desc: "Browse every chapter by subject and form, and jump straight into practice." },
    { href: "/papers", icon: "papers", title: "Past Papers", desc: "Attempt a full SPM or trial paper end to end and get it marked instantly." },
    { href: "/exam", icon: "exam", title: "Timed Exam Mode", desc: "Sit a timed paper against the clock, then get a marked breakdown." },
    { href: "/flashcards", icon: "bolt", title: "Flashcards", desc: "Flip through key questions and lock in the answers, with spaced review." },
    { href: "/assignments", icon: "assignments", title: "My Assignments", desc: "See and complete the work set by your teacher." },
    { href: "/generate", icon: "generate", title: "AI Question Generator", desc: "Create fresh KBAT questions in the style of real SPM papers, per topic." },
    { href: "/tutor", icon: "tutor", title: "AI Tutor", desc: "Find your weak subjects and topics and get a personalised focus plan." },
    { href: "/analytics", icon: "progress", title: "Progress Analytics", desc: "Track mastery, time spent and improvement over time." },
    { href: "/mock", icon: "mock", title: "Mock Paper Builder", desc: "Auto-assemble mock papers from the question bank with varied patterns." },
  ];

  return (
    <div className="space-y-8">
      <section className="card overflow-hidden">
        <div className="bg-gradient-to-br from-brand-600 to-brand-800 p-6 text-white sm:p-8">
          <div className="mb-2 flex items-center gap-2">
            <span className="badge inline-flex items-center gap-1.5 bg-white/20 text-white">
              <span className={`inline-block h-2 w-2 rounded-full ${aiEnabled() ? "bg-accent-400" : "bg-slate-300"}`} />
              {aiEnabled() ? "AI live" : "AI offline (set ANTHROPIC_API_KEY)"}
            </span>
          </div>
          <h1 className="text-2xl font-bold sm:text-3xl">{t(lang, "home.hello")}, {student.name}</h1>
          <p className="mt-2 max-w-xl text-brand-50">{t(lang, "home.heroDesc")}</p>
          <div className="mt-4 flex flex-wrap gap-3">
            <SmartPracticeButton className="btn bg-white text-brand-700 hover:bg-brand-50" label={t(lang, "home.smartPractice")} />
            <Link href="/practice" className="btn border border-white/40 text-white hover:bg-white/10">
              {t(lang, "home.browse")}
            </Link>
          </div>
          <p className="mt-3 text-xs text-brand-100">{t(lang, "home.chatHint")}</p>
        </div>
      </section>

      {/* Streak + daily goal */}
      <div className="card flex items-center justify-between gap-4 p-4">
        <div className="flex items-center gap-3">
          <span className={`grid h-11 w-11 place-items-center rounded-xl ${streakData.streak > 0 ? "bg-amber-100 text-amber-600" : "bg-slate-100 text-slate-400"}`}>
            <Icon name="flame" className="h-5 w-5" />
          </span>
          <div>
            <div className="font-bold">{streakData.streak}{t(lang, "home.streakSuffix")}</div>
            <div className="text-xs text-slate-500">{t(lang, "home.streakSub")}</div>
          </div>
        </div>
        <div className="text-right">
          <div className="text-xs font-semibold uppercase tracking-wide text-slate-400">{t(lang, "home.todayGoal")}</div>
          <div className="font-bold">
            {Math.min(streakData.doneToday, DAILY_GOAL)} / {DAILY_GOAL}
            {streakData.doneToday >= DAILY_GOAL && <Icon name="check" className="ml-1 inline h-4 w-4 text-emerald-600" />}
          </div>
          <div className="mt-1 h-1.5 w-28 overflow-hidden rounded-full bg-slate-100">
            <div className="h-full bg-emerald-500" style={{ width: `${Math.min(100, (streakData.doneToday / DAILY_GOAL) * 100)}%` }} />
          </div>
        </div>
      </div>

      <GoalCelebrate done={streakData.doneToday >= DAILY_GOAL} />

      {/* Level + XP + badges */}
      <div className="card p-4">
        <div className="flex items-center gap-3">
          <span className="font-display grid h-12 w-12 shrink-0 place-items-center rounded-2xl bg-gradient-to-br from-brand-600 to-accent-500 text-lg font-black text-white">
            {game.level}
          </span>
          <div className="min-w-0 flex-1">
            <div className="flex items-center justify-between text-sm">
              <span className="font-semibold">Level {game.level}</span>
              <span className="text-xs text-slate-500">{game.xp.toLocaleString("en-MY")} XP</span>
            </div>
            <div className="mt-1 h-2 overflow-hidden rounded-full bg-slate-100">
              <div className="h-full rounded-full bg-gradient-to-r from-brand-500 to-accent-400 transition-all duration-500" style={{ width: `${game.levelProgress}%` }} />
            </div>
            <div className="mt-0.5 text-[11px] text-slate-400">{game.xpIntoLevel}/{game.xpForLevel} XP to level {game.level + 1}</div>
          </div>
        </div>
        <div className="mt-3 flex flex-wrap gap-2">
          {game.badges.map((b) => (
            <span key={b.key} title={b.label}
              className={`inline-flex items-center gap-1 rounded-full px-2.5 py-1 text-xs font-medium ${b.earned ? "bg-accent-100 text-accent-700" : "bg-slate-100 text-slate-400"}`}>
              <Icon name={b.icon} className="h-3.5 w-3.5" />
              {b.label}
            </span>
          ))}
        </div>
      </div>

      {resume && (
        <Link
          href={`/practice?subject=${resume.subjectId}&view=topic${resume.topicId ? `&topic=${resume.topicId}` : ""}`}
          className="card flex items-center justify-between p-4 hover:border-brand-300 hover:shadow-sm"
        >
          <div>
            <div className="text-xs font-semibold uppercase tracking-wide text-slate-400">{t(lang, "home.resume")}</div>
            <div className="mt-0.5 font-semibold">
              {resume.subjectName}{resume.topicTitle ? ` · ${resume.topicTitle}` : ""}
            </div>
          </div>
          <span className="btn-primary shrink-0">{t(lang, "home.resumeBtn")} <Icon name="arrow" className="h-4 w-4" /></span>
        </Link>
      )}

      <section className="grid grid-cols-2 gap-3 sm:grid-cols-4">
        {stats.map((s) => (
          <div key={s.label} className="card p-4 text-center">
            <div className="text-2xl font-bold text-brand-700">{s.value}</div>
            <div className="mt-1 text-xs text-slate-500">{s.label}</div>
          </div>
        ))}
      </section>

      <section>
        <h2 className="mb-3 text-lg font-bold">{t(lang, "home.modules")}</h2>
        <div className="grid gap-3 sm:grid-cols-2 lg:grid-cols-3">
          {modules.map((m) => (
            <Link key={m.href} href={m.href} className="card group p-5 transition-all duration-200 hover:-translate-y-0.5 hover:border-brand-300 hover:shadow-md">
              <div className="grid h-11 w-11 place-items-center rounded-xl bg-brand-50 text-brand-600 transition-colors duration-200 group-hover:bg-brand-600 group-hover:text-white">
                <Icon name={m.icon} className="h-5 w-5" />
              </div>
              <h3 className="mt-3 font-semibold group-hover:text-brand-700">{m.title}</h3>
              <p className="mt-1 text-sm text-slate-500">{m.desc}</p>
            </Link>
          ))}
        </div>
      </section>
    </div>
  );
}
