"use client";

import { useEffect } from "react";
import { celebrate } from "./Confetti";

// Fires a confetti burst the first time the daily goal is reached each day.
export default function GoalCelebrate({ done }: { done: boolean }) {
  useEffect(() => {
    if (!done) return;
    try {
      const today = new Date().toDateString();
      if (localStorage.getItem("spm_goal_celebrated") === today) return;
      localStorage.setItem("spm_goal_celebrated", today);
      setTimeout(() => celebrate(1.2), 400);
    } catch {
      /* ignore */
    }
  }, [done]);
  return null;
}
