import { PrismaClient } from "@prisma/client";
import { hashPassword } from "../src/lib/password";

const prisma = new PrismaClient();

// ── Subject + topic taxonomy (KSSM, Form 4–5) ──────────────────────────────
const SUBJECTS: {
  name: string;
  nameEn: string;
  code: string;
  color: string;
  topics: { form: number; chapter: number; title: string; subtopics: string[] }[];
}[] = [
  {
    name: "Sejarah",
    nameEn: "History",
    code: "SEJ",
    color: "#b45309",
    topics: [
      { form: 4, chapter: 1, title: "Kemunculan Tamadun Awal Manusia", subtopics: ["Mesopotamia", "Mesir Purba", "Indus", "Hwang Ho"] },
      { form: 4, chapter: 2, title: "Peningkatan Tamadun", subtopics: ["Yunani", "Rom", "India", "China"] },
      { form: 4, chapter: 3, title: "Tamadun Awal di Asia Tenggara", subtopics: ["Kerajaan agraria", "Kerajaan maritim"] },
      { form: 4, chapter: 5, title: "Kerajaan Islam di Madinah", subtopics: ["Piagam Madinah", "Perjanjian Hudaibiyah"] },
      { form: 4, chapter: 9, title: "Perkembangan di Eropah", subtopics: ["Renaissance", "Revolusi Perindustrian"] },
      { form: 5, chapter: 1, title: "Kemunculan & Perkembangan Nasionalisme di Asia Tenggara", subtopics: ["Imperialisme Barat", "Gerakan nasionalis"] },
      { form: 5, chapter: 2, title: "Nasionalisme di Malaysia Sehingga Perang Dunia Kedua", subtopics: ["Faktor kemunculan", "Akhbar & majalah"] },
      { form: 5, chapter: 5, title: "Pembinaan Negara dan Bangsa Yang Merdeka", subtopics: ["Pakatan Murni", "Kemerdekaan 1957"] },
      { form: 5, chapter: 7, title: "Sistem Pemerintahan dan Pentadbiran Negara", subtopics: ["Raja Berperlembagaan", "Demokrasi Berparlimen"] },
    ],
  },
  {
    name: "Bahasa Melayu", nameEn: "Malay Language", code: "BM", color: "#dc2626",
    topics: [
      { form: 4, chapter: 1, title: "Karangan", subtopics: ["Karangan berformat", "Karangan tidak berformat"] },
      { form: 4, chapter: 2, title: "Pemahaman & Rumusan", subtopics: ["Rumusan", "Soalan pemahaman"] },
      { form: 5, chapter: 3, title: "Tatabahasa", subtopics: ["Kata", "Frasa", "Ayat"] },
      { form: 5, chapter: 4, title: "Komponen Sastera (KOMSAS)", subtopics: ["Novel", "Sajak", "Cerpen"] },
    ],
  },
  {
    name: "English", nameEn: "English", code: "ENG", color: "#2563eb",
    topics: [
      { form: 4, chapter: 1, title: "Reading Comprehension", subtopics: ["Skimming", "Scanning", "Inference"] },
      { form: 4, chapter: 2, title: "Continuous Writing", subtopics: ["Narrative", "Descriptive", "Argumentative"] },
      { form: 5, chapter: 3, title: "Grammar in Use", subtopics: ["Tenses", "Subject-verb agreement"] },
      { form: 5, chapter: 4, title: "Literature", subtopics: ["Poem", "Short story", "Novel"] },
    ],
  },
  {
    name: "Mathematics", nameEn: "Mathematics", code: "MATE", color: "#059669",
    topics: [
      { form: 4, chapter: 1, title: "Quadratic Functions & Equations", subtopics: ["Roots", "Discriminant", "Graphs"] },
      { form: 4, chapter: 3, title: "Logarithms & Indices", subtopics: ["Laws of indices", "Laws of logarithms"] },
      { form: 5, chapter: 5, title: "Probability", subtopics: ["Combined events", "Mutually exclusive"] },
      { form: 5, chapter: 7, title: "Statistics", subtopics: ["Dispersion", "Standard deviation"] },
    ],
  },
  {
    name: "Additional Mathematics", nameEn: "Additional Mathematics", code: "ADDMATE", color: "#0d9488",
    topics: [
      { form: 4, chapter: 1, title: "Functions", subtopics: ["Composite functions", "Inverse functions"] },
      { form: 4, chapter: 5, title: "Differentiation", subtopics: ["First derivative", "Rates of change"] },
      { form: 5, chapter: 3, title: "Integration", subtopics: ["Indefinite", "Definite", "Area under curve"] },
      { form: 5, chapter: 6, title: "Permutations & Combinations", subtopics: ["nPr", "nCr"] },
    ],
  },
  {
    name: "Physics", nameEn: "Physics", code: "FIZ", color: "#7c3aed",
    topics: [
      { form: 4, chapter: 2, title: "Force and Motion", subtopics: ["Newton's laws", "Momentum"] },
      { form: 4, chapter: 4, title: "Heat", subtopics: ["Specific heat capacity", "Latent heat"] },
      { form: 5, chapter: 2, title: "Electricity", subtopics: ["Ohm's law", "Series & parallel"] },
      { form: 5, chapter: 4, title: "Electronics", subtopics: ["Semiconductors", "Logic gates"] },
    ],
  },
  {
    name: "Chemistry", nameEn: "Chemistry", code: "KIM", color: "#db2777",
    topics: [
      { form: 4, chapter: 3, title: "Chemical Formulae & Equations", subtopics: ["Mole concept", "Empirical formula"] },
      { form: 4, chapter: 6, title: "Acids, Bases and Salts", subtopics: ["pH", "Neutralisation", "Salts"] },
      { form: 5, chapter: 2, title: "Carbon Compounds", subtopics: ["Hydrocarbons", "Alcohols", "Esters"] },
    ],
  },
  {
    name: "Biology", nameEn: "Biology", code: "BIO", color: "#16a34a",
    topics: [
      { form: 4, chapter: 2, title: "Cell Structure & Organisation", subtopics: ["Cell components", "Diffusion & osmosis"] },
      { form: 4, chapter: 6, title: "Nutrition", subtopics: ["Photosynthesis", "Human digestion"] },
      { form: 5, chapter: 3, title: "Coordination and Response", subtopics: ["Nervous system", "Hormones"] },
    ],
  },
];

const SEJ_RUBRIC = JSON.stringify({
  criteria: [
    { name: "Pengenalan", maxMarks: 2, descriptor: "Latar belakang & konteks" },
    { name: "Isi / Fakta", maxMarks: 12, descriptor: "Fakta tepat dengan huraian" },
    { name: "Penerapan nilai / iktibar", maxMarks: 4, descriptor: "Nilai & iktibar relevan" },
    { name: "Kesimpulan", maxMarks: 2, descriptor: "Rumusan padat" },
  ],
});

type QSpec = {
  subject: string;
  topicTitle: string;
  paperNumber: number;
  type: "mcq" | "structured" | "essay";
  number?: string;
  stem: string;
  options?: { key: string; text: string }[];
  answer?: string;
  markingScheme?: string;
  rubric?: string;
  marks: number;
  kbat: boolean;
  subtopic?: string;
  year: number;
};

// Original, SPM-style sample questions (approved content for the student bank).
const APPROVED: QSpec[] = [
  { subject: "Sejarah", topicTitle: "Kemunculan Tamadun Awal Manusia", paperNumber: 1, type: "mcq", number: "1",
    stem: "Apakah faktor utama yang menggalakkan kemunculan tamadun awal di lembah sungai?",
    options: [{ key: "A", text: "Tanah subur untuk pertanian" }, { key: "B", text: "Kawasan tanah tinggi" }, { key: "C", text: "Perlombongan bijih timah" }, { key: "D", text: "Hutan tebal" }],
    answer: "A", marks: 1, kbat: false, subtopic: "Mesopotamia", year: 2025 },
  { subject: "Sejarah", topicTitle: "Kerajaan Islam di Madinah", paperNumber: 1, type: "mcq", number: "2",
    stem: "Mengapakah Piagam Madinah penting kepada masyarakat Madinah?",
    options: [{ key: "A", text: "Menyatukan masyarakat pelbagai kaum" }, { key: "B", text: "Menyekat perdagangan" }, { key: "C", text: "Menghapus perhambaan" }, { key: "D", text: "Mewajibkan satu agama" }],
    answer: "A", marks: 1, kbat: true, subtopic: "Piagam Madinah", year: 2025 },
  { subject: "Sejarah", topicTitle: "Tamadun Awal di Asia Tenggara", paperNumber: 2, type: "structured", number: "1(a)",
    stem: "Nyatakan dua ciri kerajaan maritim yang wujud di Asia Tenggara.",
    answer: "Ekonomi berasaskan perdagangan; terletak di pesisir/muara sungai; mempunyai pelabuhan.",
    markingScheme: "1 markah setiap ciri (maks 2).", marks: 2, kbat: false, subtopic: "Kerajaan maritim", year: 2025 },
  { subject: "Sejarah", topicTitle: "Pembinaan Negara dan Bangsa Yang Merdeka", paperNumber: 2, type: "essay", number: "5",
    stem: "Huraikan usaha-usaha ke arah mencapai kemerdekaan Persekutuan Tanah Melayu dan nyatakan iktibarnya.",
    markingScheme: "Pakatan Murni; PRU 1955; Rombongan London 1956; Suruhanjaya Reid. Nilai: perpaduan, patriotik.",
    rubric: SEJ_RUBRIC, marks: 20, kbat: true, subtopic: "Kemerdekaan 1957", year: 2025 },

  { subject: "Mathematics", topicTitle: "Quadratic Functions & Equations", paperNumber: 2, type: "structured",
    stem: "The quadratic equation x² − 6x + k = 0 has two equal roots. Find the value of k.",
    answer: "b² − 4ac = 0 ⇒ 36 − 4k = 0 ⇒ k = 9.", markingScheme: "Discriminant = 0 (1m); substitute (1m); k = 9 (1m).",
    marks: 3, kbat: false, year: 2024 },
  { subject: "Mathematics", topicTitle: "Probability", paperNumber: 1, type: "mcq",
    stem: "A fair die is rolled once. What is the probability of getting a number greater than 4?",
    options: [{ key: "A", text: "1/6" }, { key: "B", text: "1/3" }, { key: "C", text: "1/2" }, { key: "D", text: "2/3" }],
    answer: "B", marks: 1, kbat: false, year: 2024 },

  { subject: "Additional Mathematics", topicTitle: "Differentiation", paperNumber: 1, type: "structured",
    stem: "Given y = 3x² − 5x + 2, find dy/dx and the gradient of the curve at x = 2.",
    answer: "dy/dx = 6x − 5; at x = 2, gradient = 7.", markingScheme: "Differentiate (1m); substitute (1m); answer (1m).",
    marks: 3, kbat: false, year: 2024 },

  { subject: "Physics", topicTitle: "Force and Motion", paperNumber: 1, type: "mcq",
    stem: "A car of mass 1000 kg accelerates at 2 m/s². What is the net force acting on it?",
    options: [{ key: "A", text: "500 N" }, { key: "B", text: "1000 N" }, { key: "C", text: "2000 N" }, { key: "D", text: "4000 N" }],
    answer: "C", marks: 1, kbat: false, year: 2024 },
  // Science Paper 3 (practical / amali) example
  { subject: "Physics", topicTitle: "Heat", paperNumber: 3, type: "structured",
    stem: "An experiment investigates how the temperature of water changes with heating time. State the manipulated variable, the responding variable, and one variable that must be kept constant.",
    answer: "Manipulated: heating time; Responding: temperature of water; Constant: mass of water / power of heater.",
    markingScheme: "1 markah setiap pemboleh ubah (maks 3).", marks: 3, kbat: true, year: 2024 },

  { subject: "Chemistry", topicTitle: "Acids, Bases and Salts", paperNumber: 2, type: "structured",
    stem: "Explain why a solution of ammonia in water is alkaline.",
    answer: "Ammonia reacts with water producing OH⁻ ions, making the solution alkaline.",
    markingScheme: "OH⁻ ions present (1m); reaction with water (1m).", marks: 2, kbat: true, year: 2023 },
  { subject: "Chemistry", topicTitle: "Acids, Bases and Salts", paperNumber: 3, type: "structured",
    stem: "In a titration, 25.0 cm³ of sodium hydroxide is neutralised by hydrochloric acid using phenolphthalein. State the colour change observed at the end point.",
    answer: "Pink to colourless.", markingScheme: "Correct colour change (1m).", marks: 1, kbat: false, year: 2023 },

  { subject: "Biology", topicTitle: "Nutrition", paperNumber: 2, type: "essay",
    stem: "Describe the process of photosynthesis and explain its importance to living organisms.",
    markingScheme: "Light & dark reactions; raw materials (CO₂, H₂O, light, chlorophyll); products (glucose, O₂); importance.",
    marks: 10, kbat: true, year: 2024 },
  { subject: "Biology", topicTitle: "Cell Structure & Organisation", paperNumber: 1, type: "mcq",
    stem: "Which structure controls the movement of substances into and out of a cell?",
    options: [{ key: "A", text: "Cell wall" }, { key: "B", text: "Plasma membrane" }, { key: "C", text: "Nucleus" }, { key: "D", text: "Vacuole" }],
    answer: "B", marks: 1, kbat: false, year: 2024 },

  { subject: "English", topicTitle: "Continuous Writing", paperNumber: 1, type: "essay",
    stem: "Write a story that ends with: '…and that was the day I learned the true meaning of courage.'",
    markingScheme: "Assess language, content relevance and organisation.", marks: 30, kbat: false, year: 2024 },
  { subject: "Bahasa Melayu", topicTitle: "Karangan", paperNumber: 1, type: "essay",
    stem: "Huraikan langkah-langkah untuk memelihara dan memulihara alam sekitar.",
    markingScheme: "Isi: kempen kesedaran, kitar semula, kuat kuasa undang-undang, penanaman pokok.", marks: 35, kbat: false, year: 2023 },
];

// Papers the admin "uploaded" whose AI categorization is awaiting the moderator.
const PENDING_PAPERS: {
  title: string; subject: string; paperType: string; year: number; state?: string; paperNumber: number;
  questions: QSpec[];
}[] = [
  {
    title: "Additional Mathematics Kertas 1 — Percubaan SPM 2025 (Johor)",
    subject: "Additional Mathematics", paperType: "trial", year: 2025, state: "Johor", paperNumber: 1,
    questions: [
      { subject: "Additional Mathematics", topicTitle: "Functions", paperNumber: 1, type: "structured", number: "1",
        stem: "Given f(x) = 2x + 3 and g(x) = x², find fg(x) and gf(x).",
        answer: "fg(x) = 2x² + 3; gf(x) = (2x + 3)².", markingScheme: "Each composite (1m).", marks: 2, kbat: false, year: 2025 },
      { subject: "Additional Mathematics", topicTitle: "Permutations & Combinations", paperNumber: 1, type: "structured", number: "2",
        stem: "In how many ways can 5 different books be arranged on a shelf?",
        answer: "5! = 120.", markingScheme: "5! (1m); 120 (1m).", marks: 2, kbat: false, year: 2025 },
      { subject: "Additional Mathematics", topicTitle: "Integration", paperNumber: 1, type: "structured", number: "3",
        stem: "Find ∫(6x² − 4x) dx.", answer: "2x³ − 2x² + c.", markingScheme: "Each term (1m); +c (1m).", marks: 2, kbat: true, year: 2025 },
    ],
  },
  {
    title: "Biology Kertas 2 — Percubaan SPM 2024 (Kedah)",
    subject: "Biology", paperType: "trial", year: 2024, state: "Kedah", paperNumber: 2,
    questions: [
      { subject: "Biology", topicTitle: "Cell Structure & Organisation", paperNumber: 2, type: "structured", number: "1",
        stem: "Explain how the structure of a red blood cell is adapted to its function.",
        answer: "Biconcave shape → large surface area; no nucleus → more space for haemoglobin.",
        markingScheme: "Each adaptation + reason (1m).", marks: 4, kbat: true, year: 2024 },
      { subject: "Biology", topicTitle: "Coordination and Response", paperNumber: 2, type: "structured", number: "2",
        stem: "Describe the path of a nerve impulse in a reflex arc.",
        answer: "Receptor → sensory neurone → relay neurone → motor neurone → effector.",
        markingScheme: "Correct sequence (3m).", marks: 3, kbat: false, year: 2024 },
    ],
  },
];

async function main() {
  console.log("Seeding SPM AI LMS (roles + moderation)…");

  const subjectByName = new Map<string, string>();
  const subjectCodeByName = new Map<string, string>();
  const topicByKey = new Map<string, string>();

  for (const s of SUBJECTS) {
    const subject = await prisma.subject.upsert({
      where: { code: s.code },
      update: { name: s.name, nameEn: s.nameEn, color: s.color },
      create: { name: s.name, nameEn: s.nameEn, code: s.code, color: s.color },
    });
    subjectByName.set(s.name, subject.id);
    subjectCodeByName.set(s.name, s.code);
    for (const t of s.topics) {
      const topic = await prisma.topic.upsert({
        where: { subjectId_form_chapter: { subjectId: subject.id, form: t.form, chapter: t.chapter } },
        update: { title: t.title, subtopics: JSON.stringify(t.subtopics) },
        create: { subjectId: subject.id, form: t.form, chapter: t.chapter, title: t.title, subtopics: JSON.stringify(t.subtopics) },
      });
      topicByKey.set(`${s.name}::${t.title}`, topic.id);
    }
  }

  async function createQuestion(q: QSpec, paperId: string | null, status: string) {
    const subjectId = subjectByName.get(q.subject)!;
    const topicId = topicByKey.get(`${q.subject}::${q.topicTitle}`) ?? null;
    return prisma.question.create({
      data: {
        subjectId, topicId, paperId, paperNumber: q.paperNumber, questionType: q.type,
        number: q.number ?? null, stem: q.stem, options: JSON.stringify(q.options ?? []),
        answer: q.answer ?? null, markingScheme: q.markingScheme ?? null, rubric: q.rubric ?? null,
        marks: q.marks, isKbat: q.kbat, subtopic: q.subtopic ?? null, year: q.year, source: "past_paper",
        status, reviewedAt: status === "approved" ? new Date() : null,
      },
    });
  }

  // Approved bank
  const approvedQ: { id: string; subjectId: string }[] = [];
  for (const q of APPROVED) {
    const created = await createQuestion(q, null, "approved");
    approvedQ.push({ id: created.id, subjectId: created.subjectId });
  }

  // Pending papers (await moderation)
  for (const p of PENDING_PAPERS) {
    const subjectId = subjectByName.get(p.subject)!;
    const paper = await prisma.paper.create({
      data: { title: p.title, subjectId, paperType: p.paperType, year: p.year, state: p.state ?? null,
        paperNumber: p.paperNumber, status: "categorized", categorizedAt: new Date(),
        rawText: "Uploaded by admin; AI-categorized; awaiting moderation." },
    });
    for (const q of p.questions) await createQuestion(q, paper.id, "pending");
  }

  // ── Users (admin / moderator / students) ─────────────────────────────────
  await prisma.user.upsert({
    where: { email: "admin@spm.my" },
    update: { password: hashPassword("admin123"), role: "admin", name: "Admin Cikgu" },
    create: { email: "admin@spm.my", name: "Admin Cikgu", role: "admin", password: hashPassword("admin123") },
  });
  await prisma.user.upsert({
    where: { email: "moderator@spm.my" },
    update: { password: hashPassword("mod123"), role: "moderator", name: "Moderator Aisha" },
    create: { email: "moderator@spm.my", name: "Moderator Aisha", role: "moderator", password: hashPassword("mod123") },
  });

  const STUDENTS = [
    { name: "Ahmad", email: "ahmad@student.spm.my", form: 5, subjects: ["Sejarah", "Mathematics", "Physics", "Chemistry", "Biology", "Bahasa Melayu", "English"] },
    { name: "Siti Nurhaliza", email: "siti@student.spm.my", form: 5, subjects: ["Sejarah", "Bahasa Melayu", "English", "Mathematics", "Additional Mathematics", "Physics"] },
    { name: "Kumar Raj", email: "kumar@student.spm.my", form: 4, subjects: ["Mathematics", "Additional Mathematics", "Physics", "Chemistry"] },
    { name: "Mei Ling", email: "meiling@student.spm.my", form: 5, subjects: ["Sejarah", "Bahasa Melayu", "English", "Biology", "Chemistry"] },
  ];

  const PLANS = [
    { description: "Monthly Premium — Jun 2026", amount: 99, method: "fpx", status: "paid" },
    { description: "Monthly Premium — May 2026", amount: 99, method: "card", status: "paid" },
    { description: "Annual Plan 2026", amount: 899, method: "fpx", status: "paid" },
    { description: "Monthly Premium — Jun 2026", amount: 99, method: "ewallet", status: "pending" },
  ];

  const now = Date.now();
  for (let si = 0; si < STUDENTS.length; si++) {
    const s = STUDENTS[si];
    const student = await prisma.student.upsert({
      where: { email: s.email }, update: { name: s.name, form: s.form }, create: { name: s.name, email: s.email, form: s.form },
    });
    await prisma.user.upsert({
      where: { email: s.email },
      update: { password: hashPassword("student123"), role: "student", name: s.name, studentId: student.id },
      create: { email: s.email, name: s.name, role: "student", password: hashPassword("student123"), studentId: student.id },
    });

    // Enrollments
    for (const subj of s.subjects) {
      const subjectId = subjectByName.get(subj);
      if (!subjectId) continue;
      await prisma.enrollment.upsert({
        where: { studentId_subjectId: { studentId: student.id, subjectId } },
        update: {}, create: { studentId: student.id, subjectId, status: "active" },
      });
    }

    // Payments (1–2 per student)
    await prisma.payment.create({ data: { studentId: student.id, ...PLANS[si % PLANS.length], paidAt: new Date(now - (si + 1) * 5 * 864e5) } });
    if (si % 2 === 0) {
      await prisma.payment.create({ data: { studentId: student.id, ...PLANS[(si + 2) % PLANS.length], paidAt: new Date(now - (si + 10) * 864e5) } });
    }

    // Attempts spread over the last ~3 weeks for trend analysis
    const pool = approvedQ.filter((q) => s.subjects.some((sub) => subjectByName.get(sub) === q.subjectId));
    const nAttempts = 5 + si * 2;
    for (let i = 0; i < nAttempts; i++) {
      const pick = pool[(i * 7 + si) % pool.length];
      if (!pick) continue;
      const q = await prisma.question.findUnique({ where: { id: pick.id } });
      if (!q) continue;
      // Vary performance: some students stronger than others.
      const base = 0.4 + (si % 4) * 0.12 + (Math.sin(i) + 1) * 0.12;
      const ratio = Math.max(0, Math.min(1, base));
      const score = Math.round(q.marks * ratio);
      await prisma.attempt.create({
        data: {
          studentId: student.id, questionId: q.id, answer: q.questionType === "mcq" ? (q.answer ?? "A") : "Jawapan contoh pelajar.",
          score, maxScore: q.marks, isCorrect: q.questionType === "mcq" ? score === q.marks : null,
          band: null, feedback: JSON.stringify({ summary: "Seeded attempt.", strengths: [], improvements: [], criteria: [] }),
          gradedByAi: false, timeSpentSec: 60 + i * 20, createdAt: new Date(now - (nAttempts - i) * 1.5 * 864e5),
        },
      });
    }

    await prisma.studySession.create({ data: { studentId: student.id, durationSec: 1200 + si * 600, questionsDone: nAttempts } });
  }

  const counts = {
    subjects: await prisma.subject.count(), topics: await prisma.topic.count(),
    questionsApproved: await prisma.question.count({ where: { status: "approved" } }),
    questionsPending: await prisma.question.count({ where: { status: "pending" } }),
    users: await prisma.user.count(), students: await prisma.student.count(),
    enrollments: await prisma.enrollment.count(), payments: await prisma.payment.count(),
    attempts: await prisma.attempt.count(),
  };
  console.log("Seed complete:", counts);
  console.log("Logins → admin@spm.my/admin123 · moderator@spm.my/mod123 · ahmad@student.spm.my/student123");
}

main().catch((e) => { console.error(e); process.exit(1); }).finally(async () => { await prisma.$disconnect(); });
