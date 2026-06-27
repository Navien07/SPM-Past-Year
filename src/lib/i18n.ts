// Lightweight bilingual (BM ⇄ English) layer. The language is stored in a
// cookie so both Server Components (via getLang) and Client Components (via
// the LanguageProvider) read the same value. t(lang, key) returns the string
// for the active language, falling back to English, then to the key itself.

export type Lang = "en" | "bm";
export const LANG_COOKIE = "spm_lang";
export const DEFAULT_LANG: Lang = "bm"; // Malaysia-first

type Dict = Record<string, { en: string; bm: string }>;

// Keep keys grouped by area. Only UI chrome lives here, SPM question content
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
  "nav.syllabus": { en: "Syllabus", bm: "Sukatan" },
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
  "nav.qa": { en: "QA", bm: "QA" },
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
  "exam.subtitle": { en: "Sit a real, timed paper. The clock counts down, answer everything, then submit for instant marking.", bm: "Duduki kertas sebenar bermasa. Jam mengira detik, jawab semua, kemudian hantar untuk pemarkahan segera." },
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
    en: "Your AI-powered SPM revision hub. Every past-year, trial and state paper, sorted by subject, topic and year, with instant grading, a personal tutor and unlimited KBAT practice.",
    bm: "Hab ulang kaji SPM berkuasa AI anda. Setiap kertas sebenar, percubaan dan negeri, disusun ikut subjek, topik dan tahun, dengan pemarkahan serta-merta, tutor peribadi dan latihan KBAT tanpa had.",
  },
  "home.smartPractice": { en: "Smart practice", bm: "Latihan pintar" },
  "home.browse": { en: "Browse papers", bm: "Lihat kertas" },
  "home.chatHint": { en: "Tap the chat bubble anytime to ask Cikgu AI, attach a screenshot and it explains exactly what you're stuck on.", bm: "Ketik gelembung sembang bila-bila masa untuk tanya Cikgu AI, lampirkan tangkap layar dan ia akan terangkan apa yang anda tak faham." },
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
  "review.nothingDue": { en: "Nothing due, great job! Wrong answers reappear here automatically.", bm: "Tiada apa untuk diulang, syabas! Jawapan salah akan muncul di sini secara automatik." },
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
  "help.subtitle": { en: "How to use SPM AI, and an AI assistant ready for any question.", bm: "Cara guna SPM AI, serta pembantu AI sedia membantu sebarang soalan." },
  "help.askTitle": { en: "Ask Cikgu AI anything", bm: "Tanya Cikgu AI apa sahaja" },
  "help.askDesc": { en: "Stuck on a topic, a question, or how the app works? Ask in BM or English, attach a screenshot if it helps.", bm: "Buntu pada topik, soalan, atau cara guna app? Tanya dalam BM atau English, lampirkan tangkap layar jika perlu." },
  "help.openChat": { en: "Open Cikgu AI", bm: "Buka Cikgu AI" },
  "help.howUse": { en: "How do I use this app?", bm: "Macam mana guna app ini?" },
  "help.revise": { en: "Help me revise", bm: "Bantu saya ulang kaji" },
  "help.guides": { en: "Guides & FAQ", bm: "Panduan & Soalan Lazim" },
  "help.still": { en: "Still need help? Reach us in the pilot WhatsApp group, or see our", bm: "Masih perlukan bantuan? Hubungi kami di kumpulan WhatsApp pilot, atau lihat" },

  // common (extra)
  "common.refresh": { en: "Refresh", bm: "Muat semula" },
  "common.type": { en: "Type", bm: "Jenis" },
  "common.paper": { en: "Paper", bm: "Kertas" },
  "common.answer": { en: "Answer", bm: "Jawapan" },
  "common.scheme": { en: "Scheme", bm: "Skema" },
  "common.source": { en: "Source", bm: "Sumber" },

  // tutor
  "tutor.title": { en: "AI Tutor", bm: "Tutor AI" },
  "tutor.subtitle": { en: "Your weak areas and a personalised focus plan.", bm: "Kelemahan anda dan pelan fokus peribadi." },
  "tutor.focusSubjects": { en: "Focus subjects", bm: "Subjek fokus" },
  "tutor.priority": { en: "Priority", bm: "Keutamaan" },
  "tutor.topicsToRevise": { en: "Topics to revise", bm: "Topik untuk diulang kaji" },
  "tutor.focusPlan": { en: "Your focus plan", bm: "Pelan fokus anda" },
  "tutor.perTopic": { en: "Performance by topic", bm: "Prestasi ikut topik" },
  "tutor.attempts": { en: "attempt(s)", bm: "percubaan" },
  "tutor.poweredBy": { en: "Powered by Cikgu AI", bm: "Dikuasakan Cikgu AI" },
  "tutor.offline": { en: "Offline analysis", bm: "Analisis luar talian" },

  // generate
  "generate.title": { en: "AI Question Generator", bm: "Penjana Soalan AI" },
  "generate.subtitle": { en: "Create fresh practice questions in the style of real SPM past papers, including KBAT.", bm: "Cipta soalan latihan baharu dalam gaya kertas SPM sebenar, termasuk KBAT." },
  "generate.howMany": { en: "How many", bm: "Berapa banyak" },
  "generate.kbat": { en: "KBAT (higher-order thinking)", bm: "KBAT (kemahiran berfikir aras tinggi)" },
  "generate.btn": { en: "Generate questions", bm: "Jana soalan" },
  "generate.generating": { en: "Generating…", bm: "Menjana…" },
  "generate.generated": { en: "generated", bm: "dijana" },
  "generate.saved": { en: "Saved to Practice", bm: "Disimpan ke Latihan" },
  "generate.showAns": { en: "Show answer & scheme", bm: "Tunjuk jawapan & skema" },
  "generate.hideAns": { en: "Hide answer", bm: "Sembunyi jawapan" },
  "generate.attempt": { en: "Attempt & get graded", bm: "Cuba & dapatkan markah" },

  // mock
  "mock.title": { en: "Mock Paper Builder", bm: "Pembina Kertas Mock" },
  "mock.subtitle": { en: "Auto-assemble a mock paper from the question bank, spread across topics.", bm: "Bina kertas mock secara automatik dari bank soalan, merentas topik." },
  "mock.numQ": { en: "Number of questions", bm: "Bilangan soalan" },
  "mock.kbatBias": { en: "Bias toward KBAT", bm: "Utamakan KBAT" },
  "mock.build": { en: "Build mock paper", bm: "Bina kertas mock" },
  "mock.building": { en: "Building…", bm: "Membina…" },
  "mock.questions": { en: "questions", bm: "soalan" },

  // question detail / answer form
  "qd.back": { en: "Back to practice", bm: "Kembali ke latihan" },
  "qd.notes": { en: "Notes & formulas", bm: "Nota & formula" },
  "af.placeholder": { en: "Write or say your answer here…", bm: "Tulis atau sebut jawapan anda di sini…" },
  "af.grading": { en: "Grading…", bm: "Memarkah…" },
  "af.result": { en: "Result", bm: "Keputusan" },
  "af.gradedAi": { en: "Graded by AI", bm: "Dimarkah oleh AI" },
  "af.offline": { en: "Offline estimate", bm: "Anggaran luar talian" },
  "af.rubric": { en: "Rubric breakdown", bm: "Pecahan rubrik" },
  "af.strengths": { en: "Strengths", bm: "Kekuatan" },
  "af.improve": { en: "To improve", bm: "Perlu diperbaiki" },
  "af.model": { en: "Model answer", bm: "Jawapan model" },
  "af.explainMistake": { en: "Explain my mistake", bm: "Terangkan kesilapan saya" },
  "qt.bookmark": { en: "Bookmark", bm: "Tanda buku" },
  "qt.bookmarked": { en: "Bookmarked", bm: "Ditanda" },
  "qt.read": { en: "Read aloud", bm: "Baca kuat" },
  "qt.stop": { en: "Stop", bm: "Berhenti" },
  "explain.label": { en: "Explain this", bm: "Terangkan ini" },
};

export function normLang(v?: string | null): Lang {
  return v === "en" ? "en" : v === "bm" ? "bm" : DEFAULT_LANG;
}

export function t(lang: Lang, key: string): string {
  const entry = STRINGS[key];
  if (!entry) return key;
  return entry[lang] ?? entry.en ?? key;
}
