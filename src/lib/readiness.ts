// Exam-readiness score + SPM grade forecast, derived from existing attempt
// data (no new tables). Readiness blends three honest signals:
//   - mastery   : average % correct on attempted questions
//   - coverage  : share of the subject's topics the student has touched
//   - volume    : confidence from sheer practice count (caps out at 30)
// A forecast grade is mapped from the composite so a student who scores well
// but has barely covered the syllabus isn't told they're ready for an A+.

export interface SubjectReadiness {
  name: string;
  readiness: number;   // 0-100 composite
  mastery: number;     // 0-100 avg correct
  coverage: number;    // 0-100 topics touched
  attempts: number;
  grade: string;       // forecast SPM grade band
  band: GradeBand;
}

export type GradeBand = "a-plus" | "a" | "b" | "c" | "d" | "fail";

// Official SPM (KSSM) grade boundaries.
const GRADES: { min: number; grade: string; band: GradeBand }[] = [
  { min: 90, grade: "A+", band: "a-plus" },
  { min: 80, grade: "A", band: "a" },
  { min: 70, grade: "A-", band: "a" },
  { min: 65, grade: "B+", band: "b" },
  { min: 60, grade: "B", band: "b" },
  { min: 55, grade: "C+", band: "c" },
  { min: 50, grade: "C", band: "c" },
  { min: 45, grade: "D", band: "d" },
  { min: 40, grade: "E", band: "d" },
  { min: 0, grade: "G", band: "fail" },
];

export function gradeForScore(pct: number): { grade: string; band: GradeBand } {
  const hit = GRADES.find((g) => pct >= g.min) ?? GRADES[GRADES.length - 1];
  return { grade: hit.grade, band: hit.band };
}

export function subjectReadiness(o: {
  name: string;
  mastery: number;      // 0-100
  topicsDone: number;
  topicsTotal: number;
  attempts: number;
}): SubjectReadiness {
  const coverage = o.topicsTotal > 0 ? Math.min(100, (o.topicsDone / o.topicsTotal) * 100) : 0;
  const volume = Math.min(100, (o.attempts / 30) * 100);
  const readiness = Math.round(0.55 * o.mastery + 0.3 * coverage + 0.15 * volume);
  const { grade, band } = gradeForScore(readiness);
  return {
    name: o.name,
    readiness,
    mastery: Math.round(o.mastery),
    coverage: Math.round(coverage),
    attempts: o.attempts,
    grade,
    band,
  };
}

export interface OverallReadiness {
  score: number;        // 0-100 across enrolled subjects (untouched count as 0)
  grade: string;
  band: GradeBand;
  started: number;      // subjects with at least one attempt
  total: number;        // enrolled subjects
  message: string;
}

// Overall readiness averages across ALL enrolled subjects so an untouched
// subject honestly drags the exam-readiness picture down.
export function overallReadiness(subjects: SubjectReadiness[], enrolledTotal: number): OverallReadiness {
  const total = Math.max(enrolledTotal, subjects.length);
  const sum = subjects.reduce((a, s) => a + s.readiness, 0);
  const score = total > 0 ? Math.round(sum / total) : 0;
  const { grade, band } = gradeForScore(score);
  const started = subjects.filter((s) => s.attempts > 0).length;

  let message: string;
  if (started === 0) message = "Start practising to unlock your readiness forecast.";
  else if (score >= 80) message = "You're on track for top grades. Keep the momentum going.";
  else if (score >= 60) message = "Solid progress. Push your weakest subjects to lift your forecast.";
  else if (score >= 40) message = "You've made a start. Widen your topic coverage to climb faster.";
  else message = "Early days. Consistent daily practice moves this fast.";

  return { score, grade, band, started, total, message };
}

// Tailwind classes per band, for the ring + grade chips.
export const BAND_COLOR: Record<GradeBand, { ring: string; text: string; bg: string }> = {
  "a-plus": { ring: "#10b981", text: "text-emerald-600", bg: "bg-emerald-50" },
  a: { ring: "#22c55e", text: "text-green-600", bg: "bg-green-50" },
  b: { ring: "#3b82f6", text: "text-blue-600", bg: "bg-blue-50" },
  c: { ring: "#f59e0b", text: "text-amber-600", bg: "bg-amber-50" },
  d: { ring: "#f97316", text: "text-orange-600", bg: "bg-orange-50" },
  fail: { ring: "#ef4444", text: "text-red-600", bg: "bg-red-50" },
};
