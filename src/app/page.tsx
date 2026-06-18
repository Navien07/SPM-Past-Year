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

function SetupNeeded() {
  return (
    <div className="card mx-auto max-w-xl p-8 text-center">
      <div className="text-4xl">🛠️</div>
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
      /* DB not ready — show landing with 0 */
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
  try {
    const [enrolled, questions, kbat, attempts] = await Promise.all([
      prisma.enrollment.count({ where: { studentId: student.id, status: "active" } }),
      prisma.question.count({ where: { status: "approved" } }),
      prisma.question.count({ where: { status: "approved", isKbat: true } }),
      prisma.attempt.count({ where: { studentId: student.id } }),
    ]);
    data = { enrolled, questions, kbat, attempts };

    // Streak + daily goal from attempt activity.
    const recent = await prisma.attempt.findMany({
      where: { studentId: student.id },
      orderBy: { createdAt: "desc" },
      take: 400,
      select: { createdAt: true },
    });
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

    // "Continue where you left off" — most recent attempt's subject/topic.
    const last = await prisma.attempt.findFirst({
      where: { studentId: student.id },
      orderBy: { createdAt: "desc" },
      include: { question: { include: { subject: true, topic: true } } },
    });
    streakData = { streak, doneToday };
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
    { href: "/practice", icon: "📝", title: "Practice & Instant Grading", desc: "Browse by topic or year, attempt questions, get rubric-based feedback in seconds." },
    { href: "/generate", icon: "✨", title: "AI Question Generator", desc: "Create fresh KBAT questions in the style of real SPM papers, per topic." },
    { href: "/tutor", icon: "🧭", title: "AI Tutor", desc: "Find your weak subjects & topics and get a personalised focus plan." },
    { href: "/analytics", icon: "📊", title: "Progress Analytics", desc: "Track mastery, time spent and improvement over time." },
    { href: "/mock", icon: "🧪", title: "Mock Paper Builder", desc: "Auto-assemble mock papers from the question bank with varied patterns." },
  ];

  return (
    <div className="space-y-8">
      <section className="card overflow-hidden">
        <div className="bg-gradient-to-br from-brand-600 to-brand-800 p-6 text-white sm:p-8">
          <div className="mb-2 flex items-center gap-2">
            <span className="badge inline-flex items-center gap-1.5 bg-white/20 text-white">
              <span className={`inline-block h-2 w-2 rounded-full ${aiEnabled() ? "bg-accent-400" : "bg-slate-300"}`} />
              {aiEnabled() ? "AI live" : "AI offline — set ANTHROPIC_API_KEY"}
            </span>
          </div>
          <h1 className="text-2xl font-bold sm:text-3xl">{t(lang, "home.hello")}, {student.name} 👋</h1>
          <p className="mt-2 max-w-xl text-brand-50">{t(lang, "home.heroDesc")}</p>
          <div className="mt-4 flex flex-wrap gap-3">
            <SmartPracticeButton className="btn bg-white text-brand-700 hover:bg-brand-50" label={`▶ ${t(lang, "home.smartPractice")}`} />
            <Link href="/practice" className="btn border border-white/40 text-white hover:bg-white/10">
              {t(lang, "home.browse")}
            </Link>
          </div>
          <p className="mt-3 text-xs text-brand-100">💬 {t(lang, "home.chatHint")}</p>
        </div>
      </section>

      {/* Streak + daily goal */}
      <div className="card flex items-center justify-between gap-4 p-4">
        <div className="flex items-center gap-3">
          <span className="text-3xl">{streakData.streak > 0 ? "🔥" : "✨"}</span>
          <div>
            <div className="font-bold">{streakData.streak}{t(lang, "home.streakSuffix")}</div>
            <div className="text-xs text-slate-500">{t(lang, "home.streakSub")}</div>
          </div>
        </div>
        <div className="text-right">
          <div className="text-xs font-semibold uppercase tracking-wide text-slate-400">{t(lang, "home.todayGoal")}</div>
          <div className="font-bold">
            {Math.min(streakData.doneToday, DAILY_GOAL)} / {DAILY_GOAL}
            {streakData.doneToday >= DAILY_GOAL && <span className="ml-1">✅</span>}
          </div>
          <div className="mt-1 h-1.5 w-28 overflow-hidden rounded-full bg-slate-100">
            <div className="h-full bg-emerald-500" style={{ width: `${Math.min(100, (streakData.doneToday / DAILY_GOAL) * 100)}%` }} />
          </div>
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
          <span className="btn-primary shrink-0">{t(lang, "home.resumeBtn")} →</span>
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
            <Link key={m.href} href={m.href} className="card group p-5 transition hover:border-brand-300 hover:shadow-md">
              <div className="text-2xl">{m.icon}</div>
              <h3 className="mt-3 font-semibold group-hover:text-brand-700">{m.title}</h3>
              <p className="mt-1 text-sm text-slate-500">{m.desc}</p>
            </Link>
          ))}
        </div>
      </section>
    </div>
  );
}
