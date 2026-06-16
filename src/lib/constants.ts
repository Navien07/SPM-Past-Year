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
