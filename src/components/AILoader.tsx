"use client";

import { useEffect, useState } from "react";

// Animated multi-step loader for AI tasks (tutor analysis, etc.). Cycles through
// stage messages with bouncing dots so the wait feels alive.
export default function AILoader({
  steps = ["Analysing your attempts…", "Identifying weak topics…", "Preparing your focus plan…"],
  note = "This can take a few seconds while the AI thinks.",
}: {
  steps?: string[];
  note?: string;
}) {
  const [i, setI] = useState(0);
  useEffect(() => {
    const t = setInterval(() => setI((x) => (x + 1) % steps.length), 2200);
    return () => clearInterval(t);
  }, [steps.length]);

  return (
    <div className="card flex flex-col items-center gap-3 p-8 text-center">
      <div className="flex items-end gap-1.5">
        <span className="h-3 w-3 animate-bounce rounded-full bg-brand-500 [animation-delay:-0.3s]" />
        <span className="h-3 w-3 animate-bounce rounded-full bg-brand-500 [animation-delay:-0.15s]" />
        <span className="h-3 w-3 animate-bounce rounded-full bg-brand-500" />
      </div>
      <div className="text-sm font-semibold text-slate-700">{steps[i]}</div>
      <div className="text-xs text-slate-400">{note}</div>
      <div className="mt-1 h-1 w-40 overflow-hidden rounded-full bg-slate-100">
        <div className="h-full w-1/3 animate-[loader_1.4s_ease-in-out_infinite] rounded-full bg-brand-400" />
      </div>
    </div>
  );
}
