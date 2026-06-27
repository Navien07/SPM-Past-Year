"use client";

import { useEffect, useState } from "react";

// Drives the AI topic-tagger: loops POST /api/admin/tag-topics until every
// question AND knowledge chunk is linked to a KSSM topic, with live progress.
export default function TagTopicsButton() {
  const [counts, setCounts] = useState<{ untagged: number; untaggedKnowledge: number } | null>(null);
  const [running, setRunning] = useState(false);
  const [status, setStatus] = useState("");

  async function refresh() {
    const r = await fetch("/api/admin/tag-topics");
    if (r.ok) setCounts(await r.json());
  }
  useEffect(() => { refresh(); }, []);

  async function loop(target: "questions" | "knowledge", label: string) {
    let total = 0, guard = 0, cursor: string | null = null;
    while (guard++ < 2000) {
      const res: Response = await fetch("/api/admin/tag-topics", {
        method: "POST", headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ target, limit: 120, afterId: cursor }),
      });
      const data = await res.json();
      if (!res.ok) { setStatus(data.error || "Tagging failed."); return; }
      total += data.tagged || 0;
      cursor = data.nextCursor;
      setStatus(`${label}: tagged ${total} so far…`);
      await refresh();
      if (data.done) break;
    }
    return total;
  }

  async function run() {
    setRunning(true);
    setStatus("Starting…");
    try {
      await loop("questions", "Questions");
      await loop("knowledge", "Textbooks");
      setStatus("✓ All questions and textbooks tagged to KSSM topics.");
    } finally {
      setRunning(false);
      refresh();
    }
  }

  return (
    <div className="card p-4">
      <div className="flex flex-wrap items-center justify-between gap-3">
        <div>
          <p className="font-semibold">AI topic tagging</p>
          <p className="text-xs text-slate-500">
            {counts === null
              ? "…"
              : `${counts.untagged.toLocaleString("en-MY")} questions + ${counts.untaggedKnowledge.toLocaleString("en-MY")} textbook chunks need a KSSM topic`}
          </p>
        </div>
        <button onClick={run} disabled={running || (counts?.untagged === 0 && counts?.untaggedKnowledge === 0)} className="btn-primary cursor-pointer">
          {running ? "Tagging…" : "Auto-tag topics (AI)"}
        </button>
      </div>
      {status && <p className="mt-2 text-sm text-slate-600">{status}</p>}
      {running && <p className="mt-2 text-xs text-slate-400">Keep this tab open, runs in batches; thousands of items take a few minutes.</p>}
    </div>
  );
}
