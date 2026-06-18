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
  "practice.questions": { en: "Questions", bm: "Soalan" },
  "practice.progress": { en: "progress", bm: "kemajuan" },
  "practice.left": { en: "left", bm: "berbaki" },
  "practice.topics": { en: "Topics", bm: "Topik" },
  "practice.years": { en: "Years", bm: "Tahun" },
  "practice.selectTopic": { en: "Select a topic to see its questions.", bm: "Pilih topik untuk lihat soalannya." },
  "practice.selectYear": { en: "Select a year to see its questions.", bm: "Pilih tahun untuk lihat soalannya." },
  "practice.noTopics": { en: "No topics yet.", bm: "Tiada topik lagi." },
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

  // home dashboard
  "home.hello": { en: "Hi", bm: "Salam" },
  "home.heroDesc": {
    en: "Your AI-powered SPM revision hub. Every past-year, trial and state paper — sorted by subject, topic and year — with instant grading, a personal tutor and unlimited KBAT practice.",
    bm: "Hab ulang kaji SPM berkuasa AI anda. Setiap kertas sebenar, percubaan dan negeri — disusun ikut subjek, topik dan tahun — dengan pemarkahan serta-merta, tutor peribadi dan latihan KBAT tanpa had.",
  },
  "home.smartPractice": { en: "Smart practice", bm: "Latihan pintar" },
  "home.browse": { en: "Browse papers", bm: "Lihat kertas" },
  "home.chatHint": { en: "Tap the chat bubble anytime to ask Cikgu AI — attach a screenshot and it explains exactly what you're stuck on.", bm: "Ketik gelembung sembang bila-bila masa untuk tanya Cikgu AI — lampirkan tangkap layar dan ia akan terangkan apa yang anda tak faham." },
  "home.streakSuffix": { en: "-day streak", bm: " hari berturut" },
  "home.streakSub": { en: "Practise daily to keep it alive", bm: "Berlatih setiap hari untuk kekalkannya" },
  "home.todayGoal": { en: "Today's goal", bm: "Sasaran hari ini" },
  "home.resume": { en: "Continue where you left off", bm: "Sambung dari tempat anda berhenti" },
  "home.resumeBtn": { en: "Resume", bm: "Sambung" },
  "home.statSubjects": { en: "My subjects", bm: "Subjek saya" },
  "home.statQuestions": { en: "Questions", bm: "Soalan" },
  "home.statKbat": { en: "KBAT items", bm: "Item KBAT" },
  "home.statAttempts": { en: "My attempts", bm: "Percubaan saya" },
  "home.modules": { en: "Modules", bm: "Modul" },

  // review
  "review.title": { en: "Review", bm: "Ulang Kaji" },
  "review.subtitle": { en: "Spaced repetition brings back what you got wrong, until you master it.", bm: "Pengulangan berjarak membawa kembali jawapan yang salah, sehingga anda kuasainya." },
  "review.due": { en: "Due now", bm: "Perlu dibuat" },
  "review.scheduled": { en: "Scheduled", bm: "Dijadualkan" },
  "review.bookmarks": { en: "Bookmarked", bm: "Ditanda" },
  "review.dueForReview": { en: "Due for review", bm: "Untuk diulang kaji" },
  "review.bookmarksHeading": { en: "Bookmarks", bm: "Tanda buku" },
  "review.nothingDue": { en: "Nothing due — great job! Wrong answers reappear here automatically.", bm: "Tiada apa untuk diulang — syabas! Jawapan salah akan muncul di sini secara automatik." },
  "review.allCaught": { en: "All caught up! Nothing due right now.", bm: "Semua selesai! Tiada apa-apa untuk diulang sekarang." },

  // analytics
  "analytics.title": { en: "Progress", bm: "Kemajuan" },
  "analytics.summary": { en: "Summary", bm: "Ringkasan" },
  "analytics.mastery": { en: "Mastery by subject", bm: "Penguasaan ikut subjek" },
  "analytics.trend": { en: "Score trend (per attempt)", bm: "Trend markah (setiap percubaan)" },
  "analytics.aiAnalysis": { en: "Full AI analysis", bm: "Analisis penuh AI" },
  "analytics.pdf": { en: "PDF report", bm: "Laporan PDF" },
  "analytics.start": { en: "Start practising", bm: "Mula berlatih" },
  "analytics.noData": { en: "No attempts yet.", bm: "Tiada percubaan lagi." },
  "stat.attempts": { en: "Attempts", bm: "Percubaan" },
  "stat.avg": { en: "Avg score", bm: "Markah purata" },
  "stat.time": { en: "Time on task", bm: "Masa belajar" },
  "stat.practised": { en: "Subjects practised", bm: "Subjek dilatih" },

  // help
  "help.title": { en: "Help Centre", bm: "Pusat Bantuan" },
};

export function normLang(v?: string | null): Lang {
  return v === "en" ? "en" : v === "bm" ? "bm" : DEFAULT_LANG;
}

export function t(lang: Lang, key: string): string {
  const entry = STRINGS[key];
  if (!entry) return key;
  return entry[lang] ?? entry.en ?? key;
}
