import Link from "next/link";

export default function Landing({ taken, total }: { taken: number; total: number }) {
  const left = Math.max(0, total - taken);
  const pct = Math.min(100, Math.round((taken / total) * 100));

  const features = [
    { icon: "✍️", title: "Instant AI grading", desc: "Answer essays, structured & MCQ — get marks against the real SPM marking scheme in seconds, with strengths & fixes." },
    { icon: "🧭", title: "Personal AI tutor", desc: "Finds your weak topics and builds a day-by-day focus plan, just for you." },
    { icon: "💬", title: "Cikgu AI chat", desc: "Stuck? Snap a screenshot — Cikgu AI reads it and explains, in BM or English." },
    { icon: "🔁", title: "Smart review", desc: "Wrong answers come back on a spaced schedule until you truly master them." },
    { icon: "✨", title: "Unlimited KBAT questions", desc: "AI generates fresh, exam-style questions for any topic — practise forever." },
    { icon: "📊", title: "Real progress tracking", desc: "See mastery per subject, streaks, and exactly what's done vs left." },
  ];
  const steps = [
    { n: 1, t: "Sign up free", d: "Pick your subjects, set your password — 30 seconds." },
    { n: 2, t: "Practise real papers", d: "SPM, Trial, MRSM, SPP & State papers by topic or year." },
    { n: 3, t: "Improve fast", d: "Instant feedback, a tutor, and smart review get you to an A." },
  ];

  return (
    <div className="space-y-16">
      {/* HERO */}
      <section className="relative overflow-hidden rounded-3xl bg-gradient-to-br from-brand-600 via-brand-700 to-indigo-900 px-6 py-14 text-white sm:px-10 sm:py-20">
        {/* animated blobs */}
        <div className="pointer-events-none absolute -left-16 -top-16 h-64 w-64 animate-pulse rounded-full bg-white/10 blur-3xl" />
        <div className="pointer-events-none absolute -bottom-20 -right-10 h-72 w-72 animate-pulse rounded-full bg-amber-300/20 blur-3xl [animation-delay:-1s]" />
        <div className="relative mx-auto max-w-3xl text-center">
          <span className="badge bg-white/15 text-white ring-1 ring-white/30">🇲🇾 Malaysia&apos;s first AI-powered SPM platform</span>
          <h1 className="mt-5 text-4xl font-extrabold leading-tight tracking-tight sm:text-6xl">
            Score your best SPM —
            <span className="bg-gradient-to-r from-amber-300 to-pink-300 bg-clip-text text-transparent"> with an AI cikgu</span> in your pocket.
          </h1>
          <p className="mx-auto mt-5 max-w-xl text-lg text-brand-50">
            Every past-year, trial, MRSM, SPP & state paper — auto-graded, explained, and turned into a
            personalised plan. Built for <strong>every Malaysian student</strong>.
          </p>
          <div className="mt-8 flex flex-col items-center justify-center gap-3 sm:flex-row">
            <Link href="/signup" className="btn bg-white px-6 py-3 text-base text-brand-700 hover:bg-brand-50">
              🎉 Claim your free beta spot
            </Link>
            <Link href="/login" className="btn border border-white/40 px-6 py-3 text-base text-white hover:bg-white/10">
              Sign in
            </Link>
          </div>

          {/* live spots counter */}
          <div className="mx-auto mt-8 max-w-sm rounded-2xl bg-white/10 p-4 ring-1 ring-white/20 backdrop-blur">
            <div className="flex items-center justify-between text-sm">
              <span className="font-semibold">Free for the first {total} students</span>
              <span className="text-amber-200">{left} spots left</span>
            </div>
            <div className="mt-2 h-2.5 overflow-hidden rounded-full bg-white/20">
              <div className="h-full bg-gradient-to-r from-amber-300 to-pink-300" style={{ width: `${pct}%` }} />
            </div>
            <div className="mt-1 text-left text-xs text-brand-100">{taken} students already joined the pilot 🚀</div>
          </div>
        </div>
      </section>

      {/* SUBJECTS / PAPERS */}
      <section className="text-center">
        <p className="text-xs font-bold uppercase tracking-widest text-slate-400">All papers, all subjects</p>
        <div className="mt-4 flex flex-wrap items-center justify-center gap-2">
          {["SPM", "Trial / Percubaan", "MRSM", "SPP", "State Papers", "Sejarah", "Bahasa Melayu", "English", "Mathematics", "Add Maths", "Physics", "Chemistry", "Biology", "Kertas 1 / 2 / 3", "KBAT"].map((t) => (
            <span key={t} className="badge border border-slate-200 bg-white px-3 py-1.5 text-slate-600">{t}</span>
          ))}
        </div>
      </section>

      {/* FEATURES */}
      <section>
        <h2 className="text-center text-3xl font-bold">Everything you need to nail SPM</h2>
        <div className="mt-8 grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {features.map((f) => (
            <div key={f.title} className="card p-6 transition hover:-translate-y-1 hover:border-brand-300 hover:shadow-lg">
              <div className="text-3xl">{f.icon}</div>
              <h3 className="mt-3 text-lg font-bold">{f.title}</h3>
              <p className="mt-1 text-sm text-slate-500">{f.desc}</p>
            </div>
          ))}
        </div>
      </section>

      {/* HOW IT WORKS */}
      <section>
        <h2 className="text-center text-3xl font-bold">Up and running in minutes</h2>
        <div className="mt-8 grid gap-4 sm:grid-cols-3">
          {steps.map((s) => (
            <div key={s.n} className="card p-6 text-center">
              <div className="mx-auto grid h-12 w-12 place-items-center rounded-full bg-brand-600 text-lg font-bold text-white">{s.n}</div>
              <h3 className="mt-3 font-bold">{s.t}</h3>
              <p className="mt-1 text-sm text-slate-500">{s.d}</p>
            </div>
          ))}
        </div>
      </section>

      {/* PRICING / PILOT */}
      <section className="overflow-hidden rounded-3xl bg-gradient-to-br from-emerald-500 to-teal-700 p-8 text-center text-white sm:p-12">
        <h2 className="text-3xl font-bold">100% free for the pilot</h2>
        <p className="mx-auto mt-2 max-w-xl text-emerald-50">
          We&apos;re opening SPM AI free to the first <strong>{total} Malaysian students</strong>. Join the
          beta, help shape it, and get an unfair advantage this SPM season.
        </p>
        <Link href="/signup" className="btn mt-6 bg-white px-6 py-3 text-base text-emerald-700 hover:bg-emerald-50">
          Join the free pilot — {left} spots left
        </Link>
        <p className="mt-4 text-xs text-emerald-100">
          By joining you agree to our{" "}
          <Link href="/privacy" className="underline">Privacy Policy &amp; PDPA notice</Link>.
        </p>
      </section>

      {/* FOOTER */}
      <footer className="border-t border-slate-200 pt-6 text-center text-sm text-slate-400">
        <p className="font-semibold text-slate-600">SPM<span className="text-brand-600">AI</span> — helping students across Malaysia 🇲🇾</p>
        <p className="mt-1">
          <Link href="/privacy" className="hover:text-brand-600">Privacy &amp; PDPA</Link> · <Link href="/login" className="hover:text-brand-600">Sign in</Link> · <Link href="/signup" className="hover:text-brand-600">Sign up</Link>
        </p>
        <p className="mt-2 text-xs">© {new Date().getFullYear()} SPM AI. Built for Malaysian students.</p>
      </footer>
    </div>
  );
}
