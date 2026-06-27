// Gamification derived from existing activity (no new tables). XP from marks
// earned + attempts; levels grow quadratically; badges unlock at milestones.

export interface Badge { key: string; label: string; icon: string; earned: boolean }
export interface GameStats {
  xp: number;
  level: number;
  levelProgress: number; // 0-100 toward next level
  xpIntoLevel: number;
  xpForLevel: number;
  badges: Badge[];
}

export function computeGameStats(o: {
  totalScore: number; attempts: number; streak: number; subjectsPractised: number;
}): GameStats {
  const xp = Math.round(o.totalScore * 10 + o.attempts * 3);
  const level = Math.floor(Math.sqrt(xp / 80)) + 1;
  const curBase = (level - 1) ** 2 * 80;
  const nextBase = level ** 2 * 80;
  const xpIntoLevel = xp - curBase;
  const xpForLevel = nextBase - curBase;
  const levelProgress = xpForLevel > 0 ? Math.min(100, Math.round((xpIntoLevel / xpForLevel) * 100)) : 100;

  const badges: Badge[] = [
    { key: "first", label: "First Steps", icon: "bolt", earned: o.attempts >= 1 },
    { key: "ten", label: "Warming Up", icon: "check", earned: o.attempts >= 10 },
    { key: "streak3", label: "On a Roll", icon: "flame", earned: o.streak >= 3 },
    { key: "streak7", label: "Week Warrior", icon: "flame", earned: o.streak >= 7 },
    { key: "fifty", label: "Half Century", icon: "progress", earned: o.attempts >= 50 },
    { key: "allrounder", label: "All-Rounder", icon: "syllabus", earned: o.subjectsPractised >= 5 },
    { key: "century", label: "Centurion", icon: "papers", earned: o.attempts >= 100 },
  ];
  return { xp, level, levelProgress, xpIntoLevel, xpForLevel, badges };
}
