import type { PaperType } from "./types";

export const PAPER_TYPES: { value: PaperType; label: string }[] = [
  { value: "past_year", label: "Past Year (SPM)" },
  { value: "trial", label: "Trial Paper" },
  { value: "state", label: "State Paper" },
  { value: "mock", label: "Mock Paper" },
];

export const PAPER_TYPE_LABEL: Record<string, string> = Object.fromEntries(
  PAPER_TYPES.map((p) => [p.value, p.label]),
);

// Malaysian states + common trial-paper bodies, for tagging state/trial papers.
export const MALAYSIA_STATES = [
  "Johor",
  "Kedah",
  "Kelantan",
  "Melaka",
  "Negeri Sembilan",
  "Pahang",
  "Perak",
  "Perlis",
  "Pulau Pinang",
  "Sabah",
  "Sarawak",
  "Selangor",
  "Terengganu",
  "Kuala Lumpur",
  "Putrajaya",
  "Labuan",
  "MRSM",
  "SBP",
];

// SPM grade bands (used by the grader for a qualitative label).
export const SPM_BANDS = [
  { band: "A+", min: 90, descriptor: "Cemerlang Tertinggi" },
  { band: "A", min: 80, descriptor: "Cemerlang" },
  { band: "A-", min: 70, descriptor: "Cemerlang" },
  { band: "B+", min: 65, descriptor: "Kepujian Tinggi" },
  { band: "B", min: 60, descriptor: "Kepujian" },
  { band: "C+", min: 55, descriptor: "Kepujian" },
  { band: "C", min: 50, descriptor: "Lulus Atas" },
  { band: "D", min: 45, descriptor: "Lulus" },
  { band: "E", min: 40, descriptor: "Lulus Bawah" },
  { band: "G", min: 0, descriptor: "Gagal" },
];

export function bandForPercent(pct: number): string {
  const b = SPM_BANDS.find((x) => pct >= x.min) ?? SPM_BANDS[SPM_BANDS.length - 1];
  return `${b.band} · ${b.descriptor}`;
}

export const QUESTION_TYPE_LABEL: Record<string, string> = {
  mcq: "Objektif (MCQ)",
  structured: "Struktur",
  essay: "Esei",
};

// ── Official SPM paper structure per subject (KSSM, Form 4–5) ───────────────
// SPM is a Form 4–5 examination (Form 3 = PT3, a separate exam). The pure
// sciences carry a practical Paper 3 (Kertas 3 / amali); most others have two
// papers. Used to drive paper-number options and the moderator's expectations.
export interface PaperSpec {
  number: number;
  name: string; // e.g. "Kertas 1"
  format: string; // what it contains
  types: string[]; // expected question types
}
export const SUBJECT_PAPER_STRUCTURE: Record<string, PaperSpec[]> = {
  // code -> papers
  SEJ: [
    { number: 1, name: "Kertas 1", format: "Objektif (aneka pilihan)", types: ["mcq"] },
    { number: 2, name: "Kertas 2", format: "Struktur & esei", types: ["structured", "essay"] },
  ],
  BM: [
    { number: 1, name: "Kertas 1", format: "Karangan", types: ["essay"] },
    { number: 2, name: "Kertas 2", format: "Pemahaman, rumusan, KOMSAS, tatabahasa", types: ["structured", "essay"] },
  ],
  ENG: [
    { number: 1, name: "Paper 1", format: "Writing", types: ["essay"] },
    { number: 2, name: "Paper 2", format: "Reading comprehension & literature", types: ["mcq", "structured", "essay"] },
  ],
  MATE: [
    { number: 1, name: "Kertas 1", format: "Objektif / jawapan pendek", types: ["mcq", "structured"] },
    { number: 2, name: "Kertas 2", format: "Subjektif", types: ["structured"] },
  ],
  ADDMATE: [
    { number: 1, name: "Kertas 1", format: "Subjektif (semua soalan)", types: ["structured"] },
    { number: 2, name: "Kertas 2", format: "Subjektif (bahagian A, B, C)", types: ["structured"] },
  ],
  FIZ: [
    { number: 1, name: "Kertas 1", format: "Objektif (aneka pilihan)", types: ["mcq"] },
    { number: 2, name: "Kertas 2", format: "Struktur & esei", types: ["structured", "essay"] },
    { number: 3, name: "Kertas 3", format: "Amali / eksperimen", types: ["structured"] },
  ],
  KIM: [
    { number: 1, name: "Kertas 1", format: "Objektif (aneka pilihan)", types: ["mcq"] },
    { number: 2, name: "Kertas 2", format: "Struktur & esei", types: ["structured", "essay"] },
    { number: 3, name: "Kertas 3", format: "Amali / eksperimen", types: ["structured"] },
  ],
  BIO: [
    { number: 1, name: "Kertas 1", format: "Objektif (aneka pilihan)", types: ["mcq"] },
    { number: 2, name: "Kertas 2", format: "Struktur & esei", types: ["structured", "essay"] },
    { number: 3, name: "Kertas 3", format: "Amali / eksperimen", types: ["structured"] },
  ],
};

export function papersForSubjectCode(code?: string | null): PaperSpec[] {
  return (code && SUBJECT_PAPER_STRUCTURE[code]) || [
    { number: 1, name: "Kertas 1", format: "Objektif", types: ["mcq"] },
    { number: 2, name: "Kertas 2", format: "Subjektif", types: ["structured", "essay"] },
  ];
}

export const ROLE_LABEL: Record<string, string> = {
  admin: "Administrator",
  moderator: "Moderator",
  student: "Student",
};

export const MODERATION_STATUS_LABEL: Record<string, string> = {
  pending: "Pending review",
  approved: "Approved",
  rejected: "Rejected",
};

// Confidence-gated moderation: AI categorizations at/above this confidence are
// auto-approved; below it they are flagged `pending` for a human moderator.
export const AUTO_APPROVE_THRESHOLD = Number(process.env.SPM_AUTOAPPROVE_THRESHOLD ?? 0.85);
