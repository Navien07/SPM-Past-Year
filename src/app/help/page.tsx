import Link from "next/link";
import { requireStudent } from "@/lib/student";
import OpenChatButton from "@/components/OpenChatButton";

export const dynamic = "force-dynamic";

const GUIDES = [
  {
    q: "How do I practise?",
    a: "Go to Practice → pick a subject → browse By Topic or By Year → tap a question. Choose your MCQ option or type your answer, then Submit to get instant marks and feedback. A ✓ Done badge shows what you've already tried.",
  },
  {
    q: "How does the AI grade my answers?",
    a: "MCQs are marked instantly. For structured/essay answers, the AI marks against the SPM marking scheme and shows your score, band, what you did well, and what to improve. Tap “Explain my mistake” for a step-by-step worked fix.",
  },
  {
    q: "How do I use Cikgu AI (the chat)?",
    a: "Tap the blue 💬 bubble (bottom-right) on any page. Ask it to explain a topic, give a hint, or check your reasoning — in Bahasa Melayu or English. On a question page it already knows which question you're viewing.",
  },
  {
    q: "Can I send a screenshot to the AI?",
    a: "Yes! In the chat, tap 📸 to capture your screen or 📎 to attach a photo of a question you're stuck on. Cikgu AI reads the image and explains it.",
  },
  {
    q: "What is Review (spaced repetition)?",
    a: "Questions you get wrong come back in the Review tab on a smart schedule (1, 3, 7, 16, 35 days) until you master them. Tap ▶ Smart practice to jump to the best next question automatically.",
  },
  {
    q: "How do I create my own practice questions?",
    a: "Go to Generate → pick a subject, topic and type → the AI writes fresh SPM-style (and KBAT) questions. They're saved to Practice (labelled “Soalan AI”) so you can attempt and get them graded anytime.",
  },
  {
    q: "How do I track my progress?",
    a: "Progress shows your average score, mastery per subject, a score trend, and how many topics you've done vs left. Home shows your streak, daily goal, and a “Continue where you left off” shortcut.",
  },
  {
    q: "How do I bookmark a tricky question?",
    a: "On a question page tap ☆ Bookmark. Find all your saved questions in the Review tab.",
  },
  {
    q: "I forgot my password — what do I do?",
    a: "Use “Forgot password?” on the sign-in page, or ask your admin/teacher to reset it for you from the admin panel.",
  },
];

export default async function HelpPage() {
  await requireStudent();
  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold">Help Centre ❓</h1>
        <p className="text-sm text-slate-500">How to use SPM AI — and an AI assistant ready for any question.</p>
      </div>

      {/* Ask the AI */}
      <section className="card overflow-hidden">
        <div className="bg-gradient-to-br from-brand-600 to-indigo-800 p-6 text-white">
          <h2 className="text-lg font-bold">Ask Cikgu AI anything 💬</h2>
          <p className="mt-1 text-sm text-brand-100">
            Stuck on a topic, a question, or how the app works? Ask in BM or English — attach a
            screenshot if it helps.
          </p>
          <div className="mt-4 flex flex-wrap gap-2">
            <OpenChatButton label="Open Cikgu AI" className="btn bg-white text-brand-700 hover:bg-brand-50" />
            <OpenChatButton prompt="How do I use this SPM AI app to study effectively?" label="How do I use this app?" className="btn border border-white/40 text-white hover:bg-white/10" />
            <OpenChatButton prompt="Explain a topic I'm weak in and give me a practice question." label="Help me revise" className="btn border border-white/40 text-white hover:bg-white/10" />
          </div>
        </div>
      </section>

      {/* Guides */}
      <section className="space-y-2">
        <h2 className="text-sm font-bold uppercase tracking-wide text-slate-500">Guides &amp; FAQ</h2>
        {GUIDES.map((g) => (
          <details key={g.q} className="card p-4">
            <summary className="cursor-pointer font-semibold text-slate-800">{g.q}</summary>
            <p className="mt-2 text-sm text-slate-600">{g.a}</p>
          </details>
        ))}
      </section>

      {/* Quick links */}
      <section className="grid grid-cols-2 gap-3 sm:grid-cols-4">
        <Link href="/practice" className="card p-4 text-center hover:border-brand-300"><div className="text-2xl">📝</div><div className="mt-1 text-sm font-semibold">Practice</div></Link>
        <Link href="/review" className="card p-4 text-center hover:border-brand-300"><div className="text-2xl">🔁</div><div className="mt-1 text-sm font-semibold">Review</div></Link>
        <Link href="/generate" className="card p-4 text-center hover:border-brand-300"><div className="text-2xl">✨</div><div className="mt-1 text-sm font-semibold">Generate</div></Link>
        <Link href="/tutor" className="card p-4 text-center hover:border-brand-300"><div className="text-2xl">🧭</div><div className="mt-1 text-sm font-semibold">Tutor</div></Link>
      </section>

      <p className="text-center text-xs text-slate-400">
        Still need help? Reach us in the pilot WhatsApp group, or see our{" "}
        <Link href="/privacy" className="text-brand-600 hover:underline">Privacy &amp; PDPA</Link>.
      </p>
    </div>
  );
}
