// Lightweight bilingual (BM ⇄ English) layer. The language is stored in a
// cookie so both Server Components (via getLang) and Client Components (via
// the LanguageProvider) read the same value. t(lang, key) returns the string
// for the active language, falling back to English, then to the key itself.

export type Lang = "en" | "bm";
export const LANG_COOKIE = "spm_lang";
export const DEFAULT_LANG: Lang = "bm"; // Malaysia-first

type Dict = Record<string, { en: string; bm: string }>;

// Keep keys grouped by area. Only UI chrome lives here — SPM question content
// is already bilingual in the data itself.
export const STRINGS: Dict = {
  // nav
  "nav.home": { en: "Home", bm: "Utama" },
  "nav.practice": { en: "Practice", bm: "Latihan" },
  "nav.exam": { en: "Exam", bm: "Peperiksaan" },
  "nav.review": { en: "Review", bm: "Ulang Kaji" },
  "nav.generate": { en: "Generate", bm: "Jana" },
  "nav.tutor": { en: "Tutor", bm: "Tutor" },
  "nav.progress": { en: "Progress", bm: "Kemajuan" },
  "nav.report": { en: "Report", bm: "Laporan" },
  "nav.help": { en: "Help", bm: "Bantuan" },
  "nav.signout": { en: "Sign out", bm: "Log keluar" },
  "nav.signin": { en: "Sign in", bm: "Log masuk" },
  // admin nav
  "nav.overview": { en: "Overview", bm: "Ringkasan" },
  "nav.students": { en: "Students", bm: "Pelajar" },
  "nav.class": { en: "Class", bm: "Kelas" },
  "nav.papers": { en: "Papers", bm: "Kertas" },
  "nav.brain": { en: "Brain", bm: "Otak AI" },
  "nav.activity": { en: "Activity", bm: "Aktiviti" },
  // common
  "common.subject": { en: "Subject", bm: "Subjek" },
  "common.topic": { en: "Topic", bm: "Topik" },
  "common.year": { en: "Year", bm: "Tahun" },
  "common.submit": { en: "Submit answer", bm: "Hantar jawapan" },
  "common.tryAgain": { en: "Try again", bm: "Cuba lagi" },
  "common.loading": { en: "Loading…", bm: "Memuatkan…" },
  "common.marks": { en: "marks", bm: "markah" },
  "common.done": { en: "Done", bm: "Selesai" },
  "common.notDone": { en: "Not done", bm: "Belum buat" },
  "common.continue": { en: "Continue practising", bm: "Sambung berlatih" },
  // practice
  "practice.title": { en: "Practice", bm: "Latihan" },
  "practice.subtitle": { en: "Choose a subject, then drill down by topic or by year.", bm: "Pilih subjek, kemudian terokai mengikut topik atau tahun." },
  "practice.byTopic": { en: "By Topic", bm: "Ikut Topik" },
  "practice.byYear": { en: "By Year", bm: "Ikut Tahun" },
  // exam
  "exam.title": { en: "Timed Exam Mode", bm: "Mod Peperiksaan Bermasa" },
  "exam.subtitle": { en: "Sit a real, timed paper. The clock counts down — answer everything, then submit for instant marking.", bm: "Duduki kertas sebenar bermasa. Jam mengira detik — jawab semua, kemudian hantar untuk pemarkahan segera." },
  "exam.duration": { en: "Duration (minutes)", bm: "Tempoh (minit)" },
  "exam.start": { en: "Start exam", bm: "Mula peperiksaan" },
  "exam.submit": { en: "Submit exam", bm: "Hantar peperiksaan" },
  "exam.timeLeft": { en: "Time left", bm: "Masa berbaki" },
  "exam.timeUp": { en: "Time's up! Submitting…", bm: "Masa tamat! Menghantar…" },
  "exam.results": { en: "Exam results", bm: "Keputusan peperiksaan" },
  // report
  "report.title": { en: "Progress Report", bm: "Laporan Kemajuan" },
  "report.download": { en: "Download / Print PDF", bm: "Muat turun / Cetak PDF" },
  // language
  "lang.toggle": { en: "BM", bm: "EN" }, // label shows the language you'll switch TO
};

export function normLang(v?: string | null): Lang {
  return v === "en" ? "en" : v === "bm" ? "bm" : DEFAULT_LANG;
}

export function t(lang: Lang, key: string): string {
  const entry = STRINGS[key];
  if (!entry) return key;
  return entry[lang] ?? entry.en ?? key;
}
