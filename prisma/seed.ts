import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

// ── Subject + topic taxonomy (KSSM-style chapters) ────────────────────────

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
      { form: 4, chapter: 4, title: "Kemunculan Tamadun Islam di Makkah", subtopics: ["Masyarakat Arab Jahiliah", "Riwayat Nabi Muhammad SAW"] },
      { form: 4, chapter: 5, title: "Kerajaan Islam di Madinah", subtopics: ["Piagam Madinah", "Perjanjian Hudaibiyah"] },
      { form: 4, chapter: 9, title: "Perkembangan di Eropah", subtopics: ["Renaissance", "Reformation", "Revolusi Perindustrian"] },
      { form: 5, chapter: 1, title: "Kemunculan & Perkembangan Nasionalisme di Asia Tenggara", subtopics: ["Imperialisme Barat", "Gerakan nasionalis"] },
      { form: 5, chapter: 2, title: "Nasionalisme di Malaysia Sehingga Perang Dunia Kedua", subtopics: ["Faktor kemunculan", "Akhbar & majalah"] },
      { form: 5, chapter: 3, title: "Kesedaran Pembinaan Negara dan Bangsa", subtopics: ["Negara bangsa", "Ciri-ciri negara bangsa"] },
      { form: 5, chapter: 5, title: "Pembinaan Negara dan Bangsa Yang Merdeka", subtopics: ["Persekutuan Tanah Melayu 1948", "Pakatan Murni", "Kemerdekaan 1957"] },
      { form: 5, chapter: 7, title: "Sistem Pemerintahan dan Pentadbiran Negara", subtopics: ["Raja Berperlembagaan", "Demokrasi Berparlimen", "Perlembagaan"] },
    ],
  },
  {
    name: "Bahasa Melayu",
    nameEn: "Malay Language",
    code: "BM",
    color: "#dc2626",
    topics: [
      { form: 4, chapter: 1, title: "Karangan", subtopics: ["Karangan berformat", "Karangan tidak berformat"] },
      { form: 4, chapter: 2, title: "Pemahaman & Rumusan", subtopics: ["Rumusan", "Soalan pemahaman"] },
      { form: 5, chapter: 3, title: "Tatabahasa", subtopics: ["Kata", "Frasa", "Ayat"] },
      { form: 5, chapter: 4, title: "Komponen Sastera (KOMSAS)", subtopics: ["Novel", "Sajak", "Cerpen", "Drama"] },
    ],
  },
  {
    name: "English",
    nameEn: "English",
    code: "ENG",
    color: "#2563eb",
    topics: [
      { form: 4, chapter: 1, title: "Reading Comprehension", subtopics: ["Skimming", "Scanning", "Inference"] },
      { form: 4, chapter: 2, title: "Continuous Writing", subtopics: ["Narrative", "Descriptive", "Argumentative"] },
      { form: 5, chapter: 3, title: "Grammar in Use", subtopics: ["Tenses", "Subject-verb agreement"] },
      { form: 5, chapter: 4, title: "Literature", subtopics: ["Poem", "Short story", "Novel"] },
    ],
  },
  {
    name: "Mathematics",
    nameEn: "Mathematics",
    code: "MATE",
    color: "#059669",
    topics: [
      { form: 4, chapter: 1, title: "Quadratic Functions & Equations", subtopics: ["Roots", "Discriminant", "Graphs"] },
      { form: 4, chapter: 3, title: "Logarithms & Indices", subtopics: ["Laws of indices", "Laws of logarithms"] },
      { form: 5, chapter: 5, title: "Probability", subtopics: ["Combined events", "Mutually exclusive"] },
      { form: 5, chapter: 7, title: "Statistics", subtopics: ["Measures of dispersion", "Standard deviation"] },
    ],
  },
  {
    name: "Additional Mathematics",
    nameEn: "Additional Mathematics",
    code: "ADDMATE",
    color: "#0d9488",
    topics: [
      { form: 4, chapter: 1, title: "Functions", subtopics: ["Composite functions", "Inverse functions"] },
      { form: 4, chapter: 5, title: "Differentiation", subtopics: ["First derivative", "Rates of change"] },
      { form: 5, chapter: 3, title: "Integration", subtopics: ["Indefinite", "Definite", "Area under curve"] },
    ],
  },
  {
    name: "Physics",
    nameEn: "Physics",
    code: "FIZ",
    color: "#7c3aed",
    topics: [
      { form: 4, chapter: 2, title: "Force and Motion", subtopics: ["Newton's laws", "Momentum"] },
      { form: 4, chapter: 4, title: "Heat", subtopics: ["Specific heat capacity", "Latent heat"] },
      { form: 5, chapter: 2, title: "Electricity", subtopics: ["Ohm's law", "Series & parallel"] },
      { form: 5, chapter: 4, title: "Electronics", subtopics: ["Semiconductors", "Logic gates"] },
    ],
  },
  {
    name: "Chemistry",
    nameEn: "Chemistry",
    code: "KIM",
    color: "#db2777",
    topics: [
      { form: 4, chapter: 3, title: "Chemical Formulae & Equations", subtopics: ["Mole concept", "Empirical formula"] },
      { form: 4, chapter: 6, title: "Acids, Bases and Salts", subtopics: ["pH", "Neutralisation", "Preparation of salts"] },
      { form: 5, chapter: 2, title: "Carbon Compounds", subtopics: ["Hydrocarbons", "Alcohols", "Esters"] },
    ],
  },
  {
    name: "Biology",
    nameEn: "Biology",
    code: "BIO",
    color: "#16a34a",
    topics: [
      { form: 4, chapter: 2, title: "Cell Structure & Organisation", subtopics: ["Cell components", "Diffusion & osmosis"] },
      { form: 4, chapter: 6, title: "Nutrition", subtopics: ["Photosynthesis", "Human digestion"] },
      { form: 5, chapter: 3, title: "Coordination and Response", subtopics: ["Nervous system", "Hormones"] },
    ],
  },
];

// ── A realistic Sejarah trial paper (matches the reference shared) ─────────

const SEJ_RUBRIC = JSON.stringify({
  criteria: [
    { name: "Pengenalan", maxMarks: 2, descriptor: "Latar belakang & konteks yang jelas" },
    { name: "Isi / Fakta", maxMarks: 12, descriptor: "Fakta tepat dengan huraian" },
    { name: "Penerapan nilai / iktibar", maxMarks: 4, descriptor: "Nilai & iktibar relevan" },
    { name: "Kesimpulan", maxMarks: 2, descriptor: "Rumusan padat" },
  ],
  bands: [
    { band: "Cemerlang", range: "16-20", descriptor: "Fakta tepat, huraian mendalam, nilai diterapkan" },
    { band: "Baik", range: "11-15", descriptor: "Fakta mencukupi dengan sedikit huraian" },
    { band: "Memuaskan", range: "6-10", descriptor: "Fakta asas sahaja" },
    { band: "Lemah", range: "0-5", descriptor: "Fakta tidak relevan / terhad" },
  ],
});

const sejTrialQuestions: {
  paperNumber: number;
  questionType: "mcq" | "structured" | "essay";
  number: string;
  stem: string;
  options?: { key: string; text: string }[];
  answer?: string;
  markingScheme?: string;
  rubric?: string;
  marks: number;
  isKbat: boolean;
  topicTitle: string; // matched to a Sejarah topic title above
  subtopic: string;
}[] = [
  {
    paperNumber: 1,
    questionType: "mcq",
    number: "1",
    stem: "Tamadun awal manusia muncul di lembah sungai. Apakah faktor utama yang menggalakkan kemunculan tamadun di lembah sungai?",
    options: [
      { key: "A", text: "Tanah yang subur untuk pertanian" },
      { key: "B", text: "Kawasan tanah tinggi yang selamat" },
      { key: "C", text: "Kemudahan perlombongan bijih timah" },
      { key: "D", text: "Hutan tebal untuk perburuan" },
    ],
    answer: "A",
    marks: 1,
    isKbat: false,
    topicTitle: "Kemunculan Tamadun Awal Manusia",
    subtopic: "Mesopotamia",
  },
  {
    paperNumber: 1,
    questionType: "mcq",
    number: "2",
    stem: "Piagam Madinah merupakan perlembagaan bertulis yang pertama di dunia. Mengapakah Piagam Madinah penting kepada masyarakat Madinah?",
    options: [
      { key: "A", text: "Menyatukan masyarakat pelbagai kaum dan agama" },
      { key: "B", text: "Menyekat kegiatan perdagangan orang Yahudi" },
      { key: "C", text: "Menghapuskan sistem perhambaan sepenuhnya" },
      { key: "D", text: "Mewajibkan semua penduduk memeluk Islam" },
    ],
    answer: "A",
    marks: 1,
    isKbat: true,
    topicTitle: "Kerajaan Islam di Madinah",
    subtopic: "Piagam Madinah",
  },
  {
    paperNumber: 1,
    questionType: "mcq",
    number: "3",
    stem: "Sistem Raja Berperlembagaan diamalkan di Malaysia. Apakah maksud Raja Berperlembagaan?",
    options: [
      { key: "A", text: "Raja memerintah mengikut budi bicara mutlak" },
      { key: "B", text: "Raja memerintah mengikut peruntukan Perlembagaan" },
      { key: "C", text: "Raja tidak mempunyai sebarang kuasa" },
      { key: "D", text: "Raja dilantik melalui pilihan raya" },
    ],
    answer: "B",
    marks: 1,
    isKbat: false,
    topicTitle: "Sistem Pemerintahan dan Pentadbiran Negara",
    subtopic: "Raja Berperlembagaan",
  },
  {
    paperNumber: 2,
    questionType: "structured",
    number: "1(a)",
    stem: "Nyatakan dua ciri kerajaan maritim yang wujud di Asia Tenggara.",
    answer: "Kegiatan ekonomi berasaskan perdagangan; terletak di kawasan pesisir pantai/muara sungai; mempunyai pelabuhan.",
    markingScheme: "1 markah bagi setiap ciri yang betul (maksimum 2).",
    marks: 2,
    isKbat: false,
    topicTitle: "Tamadun Awal di Asia Tenggara",
    subtopic: "Kerajaan maritim",
  },
  {
    paperNumber: 2,
    questionType: "structured",
    number: "1(b)",
    stem: "Pada pendapat anda, mengapakah kedudukan di muara sungai penting kepada kerajaan maritim?",
    answer: "Memudahkan urusan perdagangan; menjadi pusat pengumpulan barang dagangan; kawalan laluan perdagangan; pertahanan.",
    markingScheme: "2 markah bagi setiap jawapan munasabah dengan huraian (maksimum 4).",
    marks: 4,
    isKbat: true,
    topicTitle: "Tamadun Awal di Asia Tenggara",
    subtopic: "Kerajaan maritim",
  },
  {
    paperNumber: 2,
    questionType: "essay",
    number: "5",
    stem: "Kemerdekaan Persekutuan Tanah Melayu pada tahun 1957 dicapai melalui semangat perpaduan dan rundingan. Huraikan usaha-usaha ke arah mencapai kemerdekaan Persekutuan Tanah Melayu dan nyatakan iktibar yang boleh diperoleh untuk mengekalkan kemerdekaan negara.",
    markingScheme:
      "Isi: Pakatan Murni; Pilihan Raya 1955; Rombongan ke London 1956; Suruhanjaya Reid; pembentukan Perlembagaan. Nilai/iktibar: perpaduan, semangat patriotik, toleransi kaum, kepimpinan bijaksana.",
    rubric: SEJ_RUBRIC,
    marks: 20,
    isKbat: true,
    topicTitle: "Pembinaan Negara dan Bangsa Yang Merdeka",
    subtopic: "Kemerdekaan 1957",
  },
];

async function main() {
  console.log("Seeding SPM AI LMS…");

  // Subjects + topics
  const subjectByName = new Map<string, string>();
  const topicByKey = new Map<string, string>(); // `${subject}::${title}` -> topicId

  for (const s of SUBJECTS) {
    const subject = await prisma.subject.upsert({
      where: { code: s.code },
      update: { name: s.name, nameEn: s.nameEn, color: s.color },
      create: { name: s.name, nameEn: s.nameEn, code: s.code, color: s.color },
    });
    subjectByName.set(s.name, subject.id);

    for (const t of s.topics) {
      const topic = await prisma.topic.upsert({
        where: { subjectId_form_chapter: { subjectId: subject.id, form: t.form, chapter: t.chapter } },
        update: { title: t.title, subtopics: JSON.stringify(t.subtopics) },
        create: {
          subjectId: subject.id,
          form: t.form,
          chapter: t.chapter,
          title: t.title,
          subtopics: JSON.stringify(t.subtopics),
        },
      });
      topicByKey.set(`${s.name}::${t.title}`, topic.id);
    }
  }

  // The Sejarah trial paper (Paper 2 holds the structured + essay; Paper 1 the MCQ)
  const sejId = subjectByName.get("Sejarah")!;

  const trialPaper = await prisma.paper.create({
    data: {
      title: "Sejarah Kertas 1 & 2 — Percubaan SPM 2025 (Negeri)",
      subjectId: sejId,
      paperType: "trial",
      year: 2025,
      state: "Selangor",
      paperNumber: 2,
      status: "categorized",
      categorizedAt: new Date(),
      markingScheme: "Skema pemarkahan rasmi disertakan untuk setiap soalan.",
      rubric: SEJ_RUBRIC,
      rawText: "Kertas percubaan SPM Sejarah 2025 — soalan telah dikategorikan.",
    },
  });

  const createdQuestions: { id: string; topicId: string | null; subjectId: string }[] = [];
  for (const q of sejTrialQuestions) {
    const topicId = topicByKey.get(`Sejarah::${q.topicTitle}`) ?? null;
    const created = await prisma.question.create({
      data: {
        subjectId: sejId,
        topicId,
        paperId: trialPaper.id,
        paperNumber: q.paperNumber,
        questionType: q.questionType,
        number: q.number,
        stem: q.stem,
        options: JSON.stringify(q.options ?? []),
        answer: q.answer,
        markingScheme: q.markingScheme,
        rubric: q.rubric,
        marks: q.marks,
        isKbat: q.isKbat,
        subtopic: q.subtopic,
        year: 2025,
        source: "past_paper",
      },
    });
    createdQuestions.push({ id: created.id, topicId, subjectId: sejId });
  }

  // A few questions for other subjects so "browse by subject/topic/year" is populated.
  const extra: {
    subject: string;
    topicTitle: string;
    type: "mcq" | "structured" | "essay";
    stem: string;
    options?: { key: string; text: string }[];
    answer?: string;
    markingScheme?: string;
    marks: number;
    kbat: boolean;
    year: number;
  }[] = [
    {
      subject: "Mathematics",
      topicTitle: "Quadratic Functions & Equations",
      type: "structured",
      stem: "The quadratic equation x² - 6x + k = 0 has two equal roots. Find the value of k.",
      answer: "Equal roots ⇒ b² - 4ac = 0 ⇒ 36 - 4k = 0 ⇒ k = 9.",
      markingScheme: "Use discriminant = 0 (1m); substitute (1m); k = 9 (1m).",
      marks: 3,
      kbat: false,
      year: 2024,
    },
    {
      subject: "Physics",
      topicTitle: "Force and Motion",
      type: "mcq",
      stem: "A car of mass 1000 kg accelerates at 2 m/s². What is the net force acting on it?",
      options: [
        { key: "A", text: "500 N" },
        { key: "B", text: "1000 N" },
        { key: "C", text: "2000 N" },
        { key: "D", text: "4000 N" },
      ],
      answer: "C",
      marks: 1,
      kbat: false,
      year: 2024,
    },
    {
      subject: "Chemistry",
      topicTitle: "Acids, Bases and Salts",
      type: "structured",
      stem: "Explain why a solution of ammonia in water is alkaline.",
      answer: "Ammonia reacts with water to produce ammonium ions and hydroxide ions (OH⁻), making the solution alkaline.",
      markingScheme: "OH⁻ ions present (1m); reaction with water (1m).",
      marks: 2,
      kbat: true,
      year: 2023,
    },
    {
      subject: "Biology",
      topicTitle: "Nutrition",
      type: "essay",
      stem: "Describe the process of photosynthesis and explain its importance to living organisms.",
      markingScheme: "Light reaction & Calvin cycle; raw materials (CO₂, H₂O, light, chlorophyll); products (glucose, O₂); importance (food, oxygen).",
      marks: 10,
      kbat: true,
      year: 2024,
    },
    {
      subject: "English",
      topicTitle: "Continuous Writing",
      type: "essay",
      stem: "Write a story that ends with: '…and that was the day I learned the true meaning of courage.'",
      markingScheme: "Assess language (grammar, vocabulary), content relevance, and organisation.",
      marks: 30,
      kbat: false,
      year: 2024,
    },
    {
      subject: "Bahasa Melayu",
      topicTitle: "Karangan",
      type: "essay",
      stem: "Kebersihan alam sekitar menjadi tanggungjawab bersama. Huraikan langkah-langkah untuk memelihara dan memulihara alam sekitar.",
      markingScheme: "Isi: kempen kesedaran, kitar semula, kuatkuasa undang-undang, penanaman pokok. Huraian & contoh.",
      marks: 35,
      kbat: false,
      year: 2023,
    },
  ];

  for (const e of extra) {
    const subjectId = subjectByName.get(e.subject)!;
    const topicId = topicByKey.get(`${e.subject}::${e.topicTitle}`) ?? null;
    const created = await prisma.question.create({
      data: {
        subjectId,
        topicId,
        paperNumber: e.type === "mcq" ? 1 : 2,
        questionType: e.type,
        stem: e.stem,
        options: JSON.stringify(e.options ?? []),
        answer: e.answer,
        markingScheme: e.markingScheme,
        marks: e.marks,
        isKbat: e.kbat,
        year: e.year,
        source: "past_paper",
      },
    });
    if (e.subject === "Sejarah") createdQuestions.push({ id: created.id, topicId, subjectId });
  }

  // Demo student
  const student = await prisma.student.upsert({
    where: { email: "ahmad@student.spm.my" },
    update: {},
    create: { name: "Ahmad", email: "ahmad@student.spm.my", form: 5 },
  });

  // A few attempts so analytics + tutor have signal on first run.
  const sampleAttempts = createdQuestions.slice(0, 4);
  const scores = [1, 0, 3, 12]; // varied performance
  for (let i = 0; i < sampleAttempts.length; i++) {
    const q = await prisma.question.findUnique({ where: { id: sampleAttempts[i].id } });
    if (!q) continue;
    const score = Math.min(scores[i] ?? 0, q.marks);
    await prisma.attempt.create({
      data: {
        studentId: student.id,
        questionId: q.id,
        answer: i === 1 ? "B" : "Jawapan contoh pelajar untuk tujuan demonstrasi.",
        score,
        maxScore: q.marks,
        isCorrect: q.questionType === "mcq" ? score === q.marks : undefined,
        band: undefined,
        feedback: JSON.stringify({ summary: "Seeded sample attempt.", strengths: [], improvements: [], criteria: [] }),
        gradedByAi: false,
        timeSpentSec: 120 + i * 30,
      },
    });
  }

  await prisma.studySession.create({
    data: { studentId: student.id, subjectId: sejId, durationSec: 1800, questionsDone: 4 },
  });

  const counts = {
    subjects: await prisma.subject.count(),
    topics: await prisma.topic.count(),
    questions: await prisma.question.count(),
    papers: await prisma.paper.count(),
  };
  console.log("Seed complete:", counts);
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
