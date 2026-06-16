// Shared shapes used across the AI layer, API routes and UI.

export type PaperType = "past_year" | "trial" | "state" | "mock";
export type QuestionType = "mcq" | "structured" | "essay";

export interface McqOption {
  key: string; // "A" | "B" | ...
  text: string;
}

// Rubric used to grade essays / structured answers.
export interface RubricCriterion {
  name: string; // e.g. "Isi / Content"
  maxMarks: number;
  descriptor?: string; // what full marks looks like
}
export interface Rubric {
  criteria: RubricCriterion[];
  bands?: { band: string; range: string; descriptor: string }[];
}

// Output of the categorization agent for one extracted question.
export interface CategorizedQuestion {
  number?: string;
  questionType: QuestionType;
  stem: string;
  options?: McqOption[];
  answer?: string;
  markingScheme?: string;
  marks: number;
  isKbat: boolean;
  form?: number;
  chapter?: number;
  chapterTitle?: string;
  subtopic?: string;
}

export interface CategorizationResult {
  questions: CategorizedQuestion[];
}

// Output of the grading agent.
export interface GradeCriterion {
  name: string;
  awarded: number;
  max: number;
  comment: string;
}
export interface GradeResult {
  score: number;
  maxScore: number;
  band: string;
  isCorrect?: boolean;
  summary: string;
  strengths: string[];
  improvements: string[];
  criteria: GradeCriterion[];
  modelAnswer?: string;
}

// Output of the tutor agent.
export interface TutorRecommendation {
  overview: string;
  weakSubjects: { subject: string; reason: string; priority: number }[];
  weakTopics: { subject: string; topic: string; reason: string }[];
  focusPlan: { step: string; detail: string }[];
  motivational: string;
}

// Output of the generator agent.
export interface GeneratedItem {
  questionType: QuestionType;
  stem: string;
  options?: McqOption[];
  answer?: string;
  markingScheme?: string;
  marks: number;
  isKbat: boolean;
  basedOn?: string;
}
