import Link from "next/link";
import { requireStudent } from "@/lib/student";
import { getLang } from "@/lib/lang-server";
import { t, type Lang } from "@/lib/i18n";
import OpenChatButton from "@/components/OpenChatButton";
import Icon from "@/components/Icon";

export const dynamic = "force-dynamic";

const GUIDES: { q: { en: string; bm: string }; a: { en: string; bm: string } }[] = [
  {
    q: { en: "How do I practise?", bm: "Bagaimana saya berlatih?" },
    a: {
      en: "Go to Practice, pick a subject, browse By Topic or By Year, then tap a question. Choose your MCQ option or type your answer, then Submit to get instant marks and feedback. A Done badge shows what you've already tried.",
      bm: "Pergi ke Latihan, pilih subjek, cari Ikut Topik atau Ikut Tahun, kemudian ketik soalan. Pilih jawapan objektif atau taip jawapan anda, kemudian Hantar untuk markah & maklum balas serta-merta. Lencana Selesai menunjukkan apa yang telah anda cuba.",
    },
  },
  {
    q: { en: "How does the AI grade my answers?", bm: "Bagaimana AI memarkah jawapan saya?" },
    a: {
      en: "MCQs are marked instantly. For structured/essay answers, the AI marks against the SPM marking scheme and shows your score, band, what you did well, and what to improve. Tap “Explain my mistake” for a step-by-step worked fix.",
      bm: "Soalan objektif dimarkah serta-merta. Untuk jawapan struktur/esei, AI memarkah mengikut skema pemarkahan SPM dan menunjukkan markah, gred, apa yang bagus, dan apa yang perlu diperbaiki. Ketik “Terangkan kesilapan saya” untuk penyelesaian langkah demi langkah.",
    },
  },
  {
    q: { en: "How do I use Cikgu AI (the chat)?", bm: "Bagaimana saya guna Cikgu AI (sembang)?" },
    a: {
      en: "Tap the chat bubble (bottom-right) on any page. Ask it to explain a topic, give a hint, or check your reasoning, in Bahasa Melayu or English. On a question page it already knows which question you're viewing.",
      bm: "Ketik gelembung sembang (bawah kanan) di mana-mana halaman. Minta ia terangkan topik, beri petunjuk, atau semak penaakulan anda, dalam Bahasa Melayu atau English. Di halaman soalan, ia sudah tahu soalan yang anda lihat.",
    },
  },
  {
    q: { en: "Can I send a screenshot to the AI?", bm: "Boleh saya hantar tangkap layar kepada AI?" },
    a: {
      en: "Yes! In the chat, tap the camera button to capture your screen or the paperclip to attach a photo of a question you're stuck on. Cikgu AI reads the image and explains it.",
      bm: "Boleh! Dalam sembang, ketik butang kamera untuk tangkap skrin atau klip kertas untuk lampirkan gambar soalan yang anda buntu. Cikgu AI akan membaca imej dan menerangkannya.",
    },
  },
  {
    q: { en: "What is Review (spaced repetition)?", bm: "Apa itu Ulang Kaji (pengulangan berjarak)?" },
    a: {
      en: "Questions you get wrong come back in the Review tab on a smart schedule (1, 3, 7, 16, 35 days) until you master them. Tap Smart practice to jump to the best next question automatically.",
      bm: "Soalan yang anda salah akan kembali di tab Ulang Kaji mengikut jadual pintar (1, 3, 7, 16, 35 hari) sehingga anda kuasainya. Ketik Latihan pintar untuk terus ke soalan terbaik seterusnya.",
    },
  },
  {
    q: { en: "How do I create my own practice questions?", bm: "Bagaimana saya cipta soalan latihan sendiri?" },
    a: {
      en: "Go to Generate, pick a subject, topic and type, and the AI writes fresh SPM-style (and KBAT) questions. They're saved to Practice (labelled “Soalan AI”) so you can attempt and get them graded anytime.",
      bm: "Pergi ke Jana, pilih subjek, topik dan jenis, dan AI menulis soalan gaya SPM (dan KBAT) yang baharu. Ia disimpan ke Latihan (berlabel “Soalan AI”) supaya anda boleh cuba dan dapatkan markah bila-bila masa.",
    },
  },
  {
    q: { en: "How do I track my progress?", bm: "Bagaimana saya jejak kemajuan saya?" },
    a: {
      en: "Progress shows your average score, mastery per subject, a score trend, and how many topics you've done vs left. Home shows your streak, daily goal, and a “Continue where you left off” shortcut.",
      bm: "Kemajuan menunjukkan markah purata, penguasaan setiap subjek, trend markah, dan berapa topik telah disiapkan vs berbaki. Utama menunjukkan streak, sasaran harian, dan pintasan “Sambung dari tempat anda berhenti”.",
    },
  },
  {
    q: { en: "How do I bookmark a tricky question?", bm: "Bagaimana saya tanda soalan yang sukar?" },
    a: {
      en: "On a question page tap Bookmark. Find all your saved questions in the Review tab.",
      bm: "Di halaman soalan, ketik Tanda buku. Cari semua soalan yang disimpan di tab Ulang Kaji.",
    },
  },
  {
    q: { en: "I forgot my password, what do I do?", bm: "Saya lupa kata laluan, apa patut saya buat?" },
    a: {
      en: "Use “Forgot password?” on the sign-in page, or ask your admin/teacher to reset it for you from the admin panel.",
      bm: "Guna “Lupa kata laluan?” di halaman log masuk, atau minta admin/cikgu anda set semula untuk anda dari panel admin.",
    },
  },
];

export default async function HelpPage() {
  await requireStudent();
  const lang: Lang = await getLang();
  return (
    <div className="space-y-6">
      <div>
 <h1 className="text-2xl font-bold">{t(lang, "help.title")}</h1>
        <p className="text-sm text-slate-500">{t(lang, "help.subtitle")}</p>
      </div>

      {/* Ask the AI */}
      <section className="card overflow-hidden">
        <div className="bg-gradient-to-br from-brand-600 to-accent-600 p-6 text-white">
 <h2 className="text-lg font-bold">{t(lang, "help.askTitle")}</h2>
          <p className="mt-1 text-sm text-white/80">{t(lang, "help.askDesc")}</p>
          <div className="mt-4 flex flex-wrap gap-2">
            <OpenChatButton label={t(lang, "help.openChat")} className="btn bg-white text-brand-700 hover:bg-brand-50" />
            <OpenChatButton prompt="How do I use this SPM AI app to study effectively?" label={t(lang, "help.howUse")} className="btn border border-white/40 text-white hover:bg-white/10" />
            <OpenChatButton prompt="Explain a topic I'm weak in and give me a practice question." label={t(lang, "help.revise")} className="btn border border-white/40 text-white hover:bg-white/10" />
          </div>
        </div>
      </section>

      {/* Guides */}
      <section className="space-y-2">
 <h2 className="text-sm font-bold uppercase tracking-wide text-slate-500">{t(lang, "help.guides")}</h2>
        {GUIDES.map((g) => (
          <details key={g.q.en} className="card p-4">
            <summary className="cursor-pointer font-semibold text-slate-800">{g.q[lang]}</summary>
            <p className="mt-2 text-sm text-slate-600">{g.a[lang]}</p>
          </details>
        ))}
      </section>

      {/* Quick links */}
      <section className="grid grid-cols-2 gap-3 sm:grid-cols-4">
        <Link href="/practice" className="card p-4 text-center hover:border-brand-300"><Icon name="practice" className="mx-auto h-7 w-7 text-brand-600" /><div className="mt-1 text-sm font-semibold">{t(lang, "nav.practice")}</div></Link>
        <Link href="/review" className="card p-4 text-center hover:border-brand-300"><Icon name="repeat" className="mx-auto h-7 w-7 text-brand-600" /><div className="mt-1 text-sm font-semibold">{t(lang, "nav.review")}</div></Link>
        <Link href="/generate" className="card p-4 text-center hover:border-brand-300"><Icon name="sparkles" className="mx-auto h-7 w-7 text-brand-600" /><div className="mt-1 text-sm font-semibold">{t(lang, "nav.generate")}</div></Link>
        <Link href="/tutor" className="card p-4 text-center hover:border-brand-300"><Icon name="compass" className="mx-auto h-7 w-7 text-brand-600" /><div className="mt-1 text-sm font-semibold">{t(lang, "nav.tutor")}</div></Link>
      </section>

      <p className="text-center text-xs text-slate-400">
        {t(lang, "help.still")}{" "}
        <Link href="/privacy" className="text-brand-600 hover:underline">Privacy &amp; PDPA</Link>.
      </p>
    </div>
  );
}
