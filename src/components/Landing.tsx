import Link from "next/link";
import CountUp from "./CountUp";
import WaitlistForm from "./WaitlistForm";

/* Inline icon set (Lucide-style, 24×24, currentColor) — per design system:
   SVG icons, never emojis, consistent viewBox + sizing. */
function Icon({ name, className = "h-6 w-6" }: { name: string; className?: string }) {
  const p = {
    fill: "none",
    stroke: "currentColor",
    strokeWidth: 2,
    strokeLinecap: "round" as const,
    strokeLinejoin: "round" as const,
  };
  const paths: Record<string, React.ReactNode> = {
    bolt: <path d="M13 2 3 14h7l-1 8 10-12h-7l1-8z" {...p} />,
    compass: (
      <>
        <circle cx="12" cy="12" r="10" {...p} />
        <polygon points="16.24 7.76 14.12 14.12 7.76 16.24 9.88 9.88 16.24 7.76" {...p} />
      </>
    ),
    chat: <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z" {...p} />,
    repeat: (
      <>
        <path d="m17 2 4 4-4 4" {...p} />
        <path d="M3 11V9a4 4 0 0 1 4-4h14" {...p} />
        <path d="m7 22-4-4 4-4" {...p} />
        <path d="M21 13v2a4 4 0 0 1-4 4H3" {...p} />
      </>
    ),
    sparkles: (
      <>
        <path d="M12 3v4M12 17v4M3 12h4M17 12h4" {...p} />
        <path d="M12 8a4 4 0 0 0 4 4 4 4 0 0 0-4 4 4 4 0 0 0-4-4 4 4 0 0 0 4-4z" {...p} />
      </>
    ),
    chart: (
      <>
        <path d="M3 3v18h18" {...p} />
        <rect x="7" y="12" width="3" height="5" {...p} />
        <rect x="12" y="8" width="3" height="9" {...p} />
        <rect x="17" y="5" width="3" height="12" {...p} />
      </>
    ),
    clock: (
      <>
        <circle cx="12" cy="12" r="9" {...p} />
        <path d="M12 7v5l3 2" {...p} />
      </>
    ),
    shield: <path d="M12 2 4 5v6c0 5 3.5 8.5 8 11 4.5-2.5 8-6 8-11V5l-8-3z" {...p} />,
    check: <path d="M20 6 9 17l-5-5" {...p} />,
    arrow: <path d="M5 12h14M13 6l6 6-6 6" {...p} />,
    flag: (
      <>
        <path d="M4 22V4M4 4h13l-2 4 2 4H4" {...p} />
      </>
    ),
  };
  return (
    <svg viewBox="0 0 24 24" className={className} aria-hidden="true">
      {paths[name]}
    </svg>
  );
}

export default function Landing({ taken, total }: { taken: number; total: number }) {
  const left = Math.max(0, total - taken);
  const pct = Math.min(100, Math.round((taken / total) * 100));
  const full = left <= 0;

  const features = [
    { icon: "bolt", title: "Instant AI grading", desc: "Essay, structured & MCQ marked against the real SPM marking scheme in seconds — with what you got right and exactly how to score more." },
    { icon: "compass", title: "Personal AI tutor", desc: "Cikgu AI finds your weak topics and builds a day-by-day focus plan made for you, not the class." },
    { icon: "chat", title: "Snap & ask", desc: "Stuck on a question? Snap a screenshot — Cikgu AI reads it and explains step by step, in BM or English." },
    { icon: "repeat", title: "Smart review", desc: "Wrong answers come back on a spaced schedule until they're locked in for good." },
    { icon: "sparkles", title: "Unlimited KBAT", desc: "Fresh, exam-style higher-order questions for any topic — practise as much as you want." },
    { icon: "clock", title: "Timed exam mode", desc: "Sit a full paper against the clock, then get an instant marked breakdown — real exam pressure, zero risk." },
  ];

  const grades = [
    { g: "G", w: 14, c: "bg-[#FF5D73]" },
    { g: "D", w: 32, c: "bg-[#FF8A5B]" },
    { g: "C", w: 52, c: "bg-[#FFC24B]" },
    { g: "B", w: 72, c: "bg-[#7CC36B]" },
    { g: "A", w: 90, c: "bg-[#34D399]" },
    { g: "A+", w: 100, c: "bg-[#16B981]" },
  ];

  const steps = [
    { t: "Daftar percuma", d: "Pick your subjects and set a password — 30 saat, that's it." },
    { t: "Latih kertas sebenar", d: "SPM, Percubaan, MRSM, SBP & State papers — by topic or by year." },
    { t: "Naik gred, cepat", d: "Instant feedback, an AI tutor and smart review carry you to an A+." },
  ];

  const faqs = [
    { q: "Betul ke ini percuma?", a: `Ya — 100% free for the first ${total} students in the pilot. No card, no catch. We're building this for Malaysian students.` },
    { q: "Which subjects are covered?", a: "All 12 SPM subjects — Bahasa Melayu, English, Matematik, Add Maths, Fizik, Kimia, Biologi, Sejarah, Pendidikan Islam, Pendidikan Moral, Ekonomi & Prinsip Perakaunan." },
    { q: "BM ke English?", a: "Both. Switch the whole interface between Bahasa Melayu and English anytime, and Cikgu AI replies in whichever you use." },
    { q: "Is my data safe?", a: "Yes. We follow Malaysia's PDPA 2010. Your data is only used to run your account — read the full Privacy Policy & PDPA notice anytime." },
  ];

  const primaryHref = full ? "#waitlist" : "/signup";
  const primaryLabel = full ? "Join the waitlist" : "Claim your free spot";

  return (
    <div className="space-y-20 sm:space-y-28">
      {/* ───────── HERO ───────── */}
      <section className="relative overflow-hidden rounded-[2rem] bg-[#0B1020] px-5 py-16 text-white shadow-2xl sm:px-10 sm:py-24">
        {/* aurora wash + answer-sheet dot grid */}
        <div className="bg-aurora pointer-events-none absolute inset-0 opacity-40" />
        <div className="dot-grid pointer-events-none absolute inset-0 opacity-60" />
        {/* OMR answer bubbles — the subject's own artifact */}
        <svg className="animate-floaty pointer-events-none absolute -right-6 top-10 hidden h-44 w-44 text-white/10 sm:block" viewBox="0 0 120 120" aria-hidden="true">
          {[0, 1, 2, 3].map((r) =>
            [0, 1, 2, 3].map((c) => (
              <circle key={`${r}-${c}`} cx={15 + c * 30} cy={15 + r * 30} r="11" fill={r === 1 && c === 2 ? "#FFD23F" : "none"} stroke="currentColor" strokeWidth="2" />
            )),
          )}
        </svg>
        <div className="pointer-events-none absolute -left-16 bottom-0 h-64 w-64 rounded-full bg-[#2D5BFF]/30 blur-3xl" />

        <div className="relative mx-auto max-w-3xl text-center">
          <span className="inline-flex items-center gap-2 rounded-full bg-white/10 px-3 py-1.5 text-xs font-semibold ring-1 ring-white/20 backdrop-blur">
            <span className="inline-block h-2 w-2 animate-pulse rounded-full bg-[#FFD23F]" />
            Pertama di Malaysia · AI-powered SPM
          </span>

          <h1 className="font-display animate-fade-up mt-6 text-4xl font-black leading-[1.05] sm:text-6xl">
            Skor <span className="hl">A+</span> SPM anda —
            <br className="hidden sm:block" /> dengan <span className="text-shine">cikgu AI</span> dalam poket.
          </h1>

          <p className="animate-fade-up mx-auto mt-6 max-w-xl text-lg leading-relaxed text-slate-300 [animation-delay:.1s]">
            Every past-year, trial, MRSM & state paper — auto-graded, explained, and turned into a plan
            built just for you. Free for the first <strong className="text-white">{total} Malaysian students</strong>.
          </p>

          <div className="animate-fade-up mt-9 flex flex-col items-center justify-center gap-3 [animation-delay:.2s] sm:flex-row">
            <Link href={primaryHref} className="group inline-flex w-full cursor-pointer items-center justify-center gap-2 rounded-2xl bg-[#FFD23F] px-7 py-4 text-base font-bold text-[#0B1020] shadow-lg shadow-[#FFD23F]/20 transition-all duration-200 hover:bg-[#ffdb5e] focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-[#FFD23F] sm:w-auto">
              {primaryLabel}
              <Icon name="arrow" className="h-5 w-5 transition-transform duration-200 group-hover:translate-x-1" />
            </Link>
            <Link href="/login" className="inline-flex w-full cursor-pointer items-center justify-center rounded-2xl border border-white/25 px-7 py-4 text-base font-semibold text-white transition-colors duration-200 hover:bg-white/10 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-white sm:w-auto">
              Sign in
            </Link>
          </div>

          {/* live spots meter */}
          <div className="animate-fade-up mx-auto mt-10 max-w-sm rounded-2xl bg-white/10 p-4 text-left ring-1 ring-white/20 backdrop-blur [animation-delay:.3s]">
            <div className="flex items-center justify-between text-sm">
              <span className="font-semibold">{full ? "Pilot penuh — sertai senarai" : `Free for the first ${total}`}</span>
              <span className="font-bold text-[#FFD23F]">{full ? "0 left" : `${left} spots left`}</span>
            </div>
            <div className="mt-2 h-2.5 overflow-hidden rounded-full bg-white/15">
              <div className="h-full rounded-full bg-gradient-to-r from-[#FFD23F] to-[#FF5D73] transition-all duration-700" style={{ width: `${pct}%` }} />
            </div>
            <div className="mt-2 text-xs text-slate-300">
              <CountUp to={taken} className="font-bold text-white" /> students already joined the pilot.
            </div>
          </div>
        </div>
      </section>

      {/* ───────── SUBJECT MARQUEE ───────── */}
      <section aria-label="Subjects and paper types covered">
        <p className="text-center text-xs font-bold uppercase tracking-[0.2em] text-slate-400">Semua kertas · Semua subjek</p>
        <div className="relative mt-5 overflow-hidden [mask-image:linear-gradient(to_right,transparent,black_8%,black_92%,transparent)]">
          <div className="marquee-track gap-3">
            {[...Array(2)].map((_, dup) => (
              <div key={dup} className="flex shrink-0 gap-3 pr-3" aria-hidden={dup === 1}>
                {["SPM", "Percubaan", "MRSM", "SBP", "State Papers", "Bahasa Melayu", "English", "Matematik", "Add Maths", "Fizik", "Kimia", "Biologi", "Sejarah", "Pend. Islam", "Pend. Moral", "Ekonomi", "Perakaunan", "KBAT", "Kertas 1 / 2 / 3"].map((t) => (
                  <span key={t} className="whitespace-nowrap rounded-full border border-slate-200 bg-white px-4 py-2 text-sm font-medium text-slate-600 shadow-sm">{t}</span>
                ))}
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* ───────── STATS BAND ───────── */}
      <section className="grid grid-cols-2 gap-4 sm:grid-cols-4">
        {[
          { v: 12, s: "", label: "Subjects" },
          { v: 5900, s: "+", label: "Papers indexed" },
          { v: 30, s: "s", label: "To a marked answer" },
          { v: 100, s: "%", label: "Free in the pilot" },
        ].map((st) => (
          <div key={st.label} className="card p-5 text-center transition-shadow duration-200 hover:shadow-md">
            <div className="font-display text-3xl font-black text-[#2D5BFF] sm:text-4xl">
              <CountUp to={st.v} suffix={st.s} />
            </div>
            <div className="mt-1 text-xs font-medium text-slate-500">{st.label}</div>
          </div>
        ))}
      </section>

      {/* ───────── FEATURES ───────── */}
      <section>
        <div className="mx-auto max-w-2xl text-center">
          <h2 className="font-display text-3xl font-black sm:text-4xl">Everything you need to <span className="hl">nail SPM</span></h2>
          <p className="mt-3 text-slate-600">One app for practice, marking, tutoring and review — built around how you actually study.</p>
        </div>
        <div className="mt-10 grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {features.map((f) => (
            <div key={f.title} className="group card p-6 transition-all duration-200 hover:-translate-y-1 hover:border-[#2D5BFF]/40 hover:shadow-lg">
              <div className="grid h-12 w-12 place-items-center rounded-2xl bg-[#2D5BFF]/10 text-[#2D5BFF] transition-colors duration-200 group-hover:bg-[#2D5BFF] group-hover:text-white">
                <Icon name={f.icon} />
              </div>
              <h3 className="font-display mt-4 text-lg font-bold">{f.title}</h3>
              <p className="mt-1.5 text-sm leading-relaxed text-slate-600">{f.desc}</p>
            </div>
          ))}
        </div>
      </section>

      {/* ───────── GRADE CLIMB (proof / signature) ───────── */}
      <section className="overflow-hidden rounded-[2rem] border border-slate-200 bg-white p-8 sm:p-12">
        <div className="grid items-center gap-10 lg:grid-cols-2">
          <div>
            <span className="badge bg-[#34D399]/15 text-[#0f766e]">The whole point</span>
            <h2 className="font-display mt-3 text-3xl font-black sm:text-4xl">From <span className="hl-coral">G</span> to <span className="hl">A+</span> — one topic at a time.</h2>
            <p className="mt-4 leading-relaxed text-slate-600">
              Most students don&apos;t fail because they&apos;re not smart — they fail because no one shows them
              exactly what to fix. SPM AI marks every answer, names your weak spots, and keeps drilling
              them until the grade moves.
            </p>
            <Link href={primaryHref} className="btn-primary mt-6 inline-flex cursor-pointer">
              {primaryLabel}
              <Icon name="arrow" className="h-5 w-5" />
            </Link>
          </div>
          <div className="space-y-3" aria-hidden="true">
            {grades.map((row) => (
              <div key={row.g} className="flex items-center gap-3">
                <span className="font-display w-8 text-right text-sm font-bold text-slate-500">{row.g}</span>
                <div className="h-7 flex-1 overflow-hidden rounded-lg bg-slate-100">
                  <div className={`h-full rounded-lg ${row.c} transition-all duration-700`} style={{ width: `${row.w}%` }} />
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* ───────── HOW IT WORKS ───────── */}
      <section>
        <div className="mx-auto max-w-2xl text-center">
          <h2 className="font-display text-3xl font-black sm:text-4xl">Up and running in minutes</h2>
        </div>
        <ol className="mt-10 grid gap-4 sm:grid-cols-3">
          {steps.map((s, i) => (
            <li key={s.t} className="card relative p-6">
              <span className="font-display grid h-11 w-11 place-items-center rounded-2xl bg-[#0B1020] text-lg font-black text-white">{i + 1}</span>
              <h3 className="font-display mt-4 text-lg font-bold">{s.t}</h3>
              <p className="mt-1.5 text-sm leading-relaxed text-slate-600">{s.d}</p>
            </li>
          ))}
        </ol>
      </section>

      {/* ───────── WAITLIST / FREE PILOT ───────── */}
      <section id="waitlist" className="scroll-mt-20 overflow-hidden rounded-[2rem] bg-[#0B1020] p-6 text-white sm:p-12">
        <div className="grid items-center gap-10 lg:grid-cols-2">
          <div>
            <span className="inline-flex items-center gap-2 rounded-full bg-[#34D399]/20 px-3 py-1 text-xs font-bold text-[#6ee7b7]">
              <Icon name="flag" className="h-4 w-4" /> {full ? "Pilot is full" : "Free pilot — limited spots"}
            </span>
            <h2 className="font-display mt-4 text-3xl font-black leading-tight sm:text-4xl">
              {full ? <>Spots are gone — <span className="hl">jump the queue.</span></> : <>Join the first <span className="hl">{total} students</span> in Malaysia.</>}
            </h2>
            <p className="mt-4 leading-relaxed text-slate-300">
              {full
                ? "The pilot filled up fast. Drop your details and we'll WhatsApp you the moment the next batch opens."
                : "Get an unfair advantage this SPM season. Free during the pilot — we just ask for your honest feedback."}
            </p>
            <ul className="mt-6 space-y-2.5 text-sm text-slate-200">
              {["All 12 subjects, every paper type", "AI marking + a personal tutor", "Works on your phone — install it like an app"].map((b) => (
                <li key={b} className="flex items-center gap-2.5">
                  <span className="grid h-5 w-5 shrink-0 place-items-center rounded-full bg-[#34D399] text-[#0B1020]"><Icon name="check" className="h-3.5 w-3.5" /></span>
                  {b}
                </li>
              ))}
            </ul>
            {!full && (
              <Link href="/signup" className="mt-7 inline-flex cursor-pointer items-center justify-center gap-2 rounded-2xl bg-[#FFD23F] px-6 py-3.5 font-bold text-[#0B1020] transition-colors duration-200 hover:bg-[#ffdb5e] focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-[#FFD23F]">
                Sign up free <Icon name="arrow" className="h-5 w-5" />
              </Link>
            )}
          </div>
          <div className="rounded-2xl bg-white p-5 text-slate-900 shadow-xl sm:p-6">
            <h3 className="font-display text-lg font-bold">{full ? "Get on the waitlist" : "Want a reminder?"}</h3>
            <p className="mb-4 mt-1 text-sm text-slate-500">{full ? "We'll let you know the second a spot frees up." : "Not ready to sign up? Leave your details and we'll keep you posted."}</p>
            <WaitlistForm full={full} />
          </div>
        </div>
      </section>

      {/* ───────── FAQ ───────── */}
      <section>
        <div className="mx-auto max-w-2xl text-center">
          <h2 className="font-display text-3xl font-black sm:text-4xl">Soalan lazim</h2>
        </div>
        <div className="mx-auto mt-8 max-w-2xl space-y-3">
          {faqs.map((f) => (
            <details key={f.q} className="card group p-5 [&_summary::-webkit-details-marker]:hidden">
              <summary className="flex cursor-pointer items-center justify-between font-semibold">
                {f.q}
                <Icon name="arrow" className="h-5 w-5 shrink-0 rotate-90 text-slate-400 transition-transform duration-200 group-open:-rotate-90" />
              </summary>
              <p className="mt-3 text-sm leading-relaxed text-slate-600">{f.a}</p>
            </details>
          ))}
        </div>
      </section>

      {/* ───────── FINAL CTA ───────── */}
      <section className="overflow-hidden rounded-[2rem] bg-gradient-to-br from-[#2D5BFF] to-[#1e3a8a] p-10 text-center text-white sm:p-16">
        <h2 className="font-display text-3xl font-black sm:text-5xl">Your SPM starts today.</h2>
        <p className="mx-auto mt-4 max-w-lg text-blue-100">Free for the first {total} students. Tak rugi mencuba — and your future self will thank you.</p>
        <Link href={primaryHref} className="mt-8 inline-flex cursor-pointer items-center justify-center gap-2 rounded-2xl bg-white px-8 py-4 text-base font-bold text-[#2D5BFF] transition-colors duration-200 hover:bg-blue-50 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-white">
          {primaryLabel} <Icon name="arrow" className="h-5 w-5" />
        </Link>
        <p className="mt-5 text-xs text-blue-200">
          By joining you agree to our <Link href="/privacy" className="underline hover:text-white">Privacy Policy &amp; PDPA notice</Link>.
        </p>
      </section>

      {/* ───────── FOOTER ───────── */}
      <footer className="border-t border-slate-200 pt-8 text-center text-sm text-slate-500">
        <div className="flex items-center justify-center gap-2">
          {/* eslint-disable-next-line @next/next/no-img-element */}
          <img src="/icon.svg" alt="SPM AI logo" className="h-7 w-7 rounded-lg" />
          <span className="font-display font-bold text-slate-700">SPM<span className="text-accent-500">AI</span></span>
        </div>
        <p className="mt-3">Helping students across Malaysia 🇲🇾</p>
        <p className="mt-2">
          <Link href="/privacy" className="hover:text-[#2D5BFF]">Privacy &amp; PDPA</Link> ·{" "}
          <Link href="/login" className="hover:text-[#2D5BFF]">Sign in</Link> ·{" "}
          <Link href="/signup" className="hover:text-[#2D5BFF]">Sign up</Link>
        </p>
        <p className="mt-2 text-xs text-slate-400">© {new Date().getFullYear()} SPM AI. Built for Malaysian students.</p>
      </footer>
    </div>
  );
}
