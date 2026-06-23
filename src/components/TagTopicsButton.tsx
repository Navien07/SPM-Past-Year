"use client";

import { useEffect, useState } from "react";

// Drives the AI topic-tagger: loops POST /api/admin/tag-topics until every
// question is linked to a KSSM topic, showing live progress.
export default function TagTopicsButton() {
  const [untagged, setUntagged] = useState<number | null>(null);
  const [running, setRunning] = useState(false);
  const [tagged, setTagged] = useState(0);
  const [msg, setMsg] = useState<string | null>(null);

  async function refresh() {
    const r = await fetch("/api/admin/tag-topics");
    if (r.ok) setUntagged((await r.json()).untagged);
  }
  useEffect(() => { refresh(); }, []);

  async function run() {
    setRunning(true);
    setMsg(null);
    setTagged(0);
    let guard = 0;
    try {
      // Loop batches until nothing remains (cap iterations as a safety net).
      while (guard++ < 500) {
        const res = await fetch("/api/admin/tag-topics", {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ limit: 90 }),
        });
        const data = await res.json();
        if (!res.ok) { setMsg(data.error || "Tagging failed."); break; }
        setTagged((t) => t + (data.tagged || 0));
        setUntagged(data.remaining);
        if (data.done || data.processed === 0) { setMsg("✓ All questions tagged."); break; }
      }
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
            {untagged === null ? "…" : `${untagged.toLocaleString("en-MY")} questions still need a KSSM topic`}
            {running && ` · tagged ${tagged} so far`}
          </p>
        </div>
        <button onClick={run} disabled={running || untagged === 0} className="btn-primary cursor-pointer">
          {running ? "Tagging…" : "Auto-tag topics (AI)"}
        </button>
      </div>
      {msg && <p className="mt-2 text-sm text-emerald-700">{msg}</p>}
      {running && <p className="mt-2 text-xs text-slate-400">Keep this tab open — it runs in batches and may take a few minutes for thousands of questions.</p>}
    </div>
  );
}
