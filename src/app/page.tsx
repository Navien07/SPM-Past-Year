import Link from "next/link";
import { prisma } from "@/lib/db";
import { aiEnabled } from "@/lib/ai";
import { getCurrentStudent } from "@/lib/student";

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
  // Degrade gracefully if the database isn't reachable/seeded yet (e.g. fresh
  // Vercel deploy before `npm run db:deploy`) instead of throwing a raw 500.
  let data: { subjects: number; topics: number; questions: number; papers: number; kbat: number; student: { name: string; id: string }; attempts: number } | null = null;
  try {
    const [subjects, topics, questions, papers, kbat, student] = await Promise.all([
      prisma.subject.count(),
      prisma.topic.count(),
      prisma.question.count(),
      prisma.paper.count(),
      prisma.question.count({ where: { isKbat: true } }),
      getCurrentStudent(),
    ]);
    const attempts = await prisma.attempt.count({ where: { studentId: student.id } });
    data = { subjects, topics, questions, papers, kbat, student, attempts };
  } catch {
    return <SetupNeeded />;
  }
  const { subjects, topics, questions, papers, kbat, student, attempts } = data;

  const stats = [
    { label: "Subjects", value: subjects },
    { label: "Topics", value: topics },
    { label: "Questions", value: questions },
    { label: "Papers", value: papers },
    { label: "KBAT items", value: kbat },
    { label: "Your attempts", value: attempts },
  ];

  const modules = [
    { href: "/admin", icon: "🗂️", title: "Upload & Categorize", desc: "Add past-year, trial, state & mock papers. The AI agent splits and tags every question." },
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
            <span className="badge bg-white/20 text-white">
              {aiEnabled() ? "● AI live (Claude)" : "○ AI offline — set ANTHROPIC_API_KEY"}
            </span>
          </div>
          <h1 className="text-2xl font-bold sm:text-3xl">Salam, {student.name} 👋</h1>
          <p className="mt-2 max-w-xl text-brand-50">
            Your AI-powered SPM revision hub. Every past-year, trial and state paper —
            categorized by subject, topic and year — with instant grading, a personal tutor and
            unlimited KBAT practice.
          </p>
          <div className="mt-4 flex flex-wrap gap-3">
            <Link href="/practice" className="btn bg-white text-brand-700 hover:bg-brand-50">
              Start practising
            </Link>
            <Link href="/tutor" className="btn border border-white/40 text-white hover:bg-white/10">
              Ask the tutor
            </Link>
          </div>
          <p className="mt-3 text-xs text-brand-100">
            💬 Tap the chat bubble anytime to ask <strong>Cikgu AI</strong> — attach a screenshot and it
            explains exactly what you&apos;re stuck on.
          </p>
        </div>
      </section>

      <section className="grid grid-cols-3 gap-3 sm:grid-cols-6">
        {stats.map((s) => (
          <div key={s.label} className="card p-4 text-center">
            <div className="text-2xl font-bold text-brand-700">{s.value}</div>
            <div className="mt-1 text-xs text-slate-500">{s.label}</div>
          </div>
        ))}
      </section>

      <section>
        <h2 className="mb-3 text-lg font-bold">Modules</h2>
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
