"use client";

import { useState } from "react";
import Link from "next/link";

const SAMPLE = `[
  {
    "title": "Sejarah Kertas 1 — Percubaan MRSM 2024",
    "subject": "SEJ",
    "paperType": "trial",
    "year": 2024,
    "state": "MRSM",
    "paperNumber": 1,
    "rawText": "1. Soalan ... A. ... B. ... C. ... D. ...",
    "markingScheme": "1. B  2. C ...",
    "fileName": "sej_k1_mrsm_2024.pdf"
  }
]`;

interface BulkResult {
  created: number;
  skipped: number;
  ids: string[];
  skippedDetail?: { title?: string; reason: string }[];
}

export default function BulkUploadPage() {
  const [text, setText] = useState(SAMPLE);
  const [busy, setBusy] = useState(false);
  const [msg, setMsg] = useState<string | null>(null);
  const [result, setResult] = useState<BulkResult | null>(null);
  const [catProgress, setCatProgress] = useState<{ done: number; total: number } | null>(null);

  async function importPapers() {
    setBusy(true);
    setMsg(null);
    setResult(null);
    setCatProgress(null);
    let papers: unknown;
    try {
      papers = JSON.parse(text);
    } catch {
      setBusy(false);
      setMsg("That isn't valid JSON. Paste an array of paper objects.");
      return;
    }
    if (!Array.isArray(papers)) {
      setBusy(false);
      setMsg("The JSON must be an array, e.g. [ { … }, { … } ].");
      return;
    }
    try {
      const res = await fetch("/api/admin/papers/bulk", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ papers }),
      });
      const data = await res.json();
      if (!res.ok) {
        setMsg(data.error || "Import failed.");
        return;
      }
      setResult(data);
      setMsg(`Imported ${data.created} paper(s), skipped ${data.skipped}. Now categorize to build the question bank.`);
    } finally {
      setBusy(false);
    }
  }

  // Categorize every imported paper sequentially (each AI call is long-running,
  // so we run them one at a time and show progress).
  async function categorizeAll() {
    if (!result?.ids?.length) return;
    setBusy(true);
    setMsg(null);
    const ids = result.ids;
    let done = 0;
    setCatProgress({ done: 0, total: ids.length });
    for (const id of ids) {
      try {
        await fetch(`/api/papers/${id}/categorize`, { method: "POST" });
      } catch {
        /* keep going — one failure shouldn't stop the batch */
      }
      done += 1;
      setCatProgress({ done, total: ids.length });
    }
    setBusy(false);
    setMsg(`Categorized ${done}/${ids.length} papers. High-confidence questions auto-approved; the rest are in the Review queue.`);
  }

  return (
    <div className="space-y-6">
      <div className="flex items-end justify-between gap-3">
        <div>
          <h1 className="text-2xl font-bold">Bulk import papers 📦</h1>
          <p className="text-sm text-slate-500">
            Paste an array of papers (question text + marking scheme). They&apos;re created in one go,
            then the AI splits each into questions, tags topics and pairs the answers.
          </p>
        </div>
        <Link href="/admin/papers" className="btn-ghost shrink-0">← Single upload</Link>
      </div>

      {msg && <div className="rounded-xl border border-brand-200 bg-brand-50 p-3 text-sm text-brand-800">{msg}</div>}

      <div className="card p-5">
        <label className="label">Papers JSON (max 200 per batch)</label>
        <p className="mb-2 text-xs text-slate-500">
          Each item needs at least <code className="rounded bg-slate-100 px-1">subject</code> (code like
          <code className="rounded bg-slate-100 px-1">SEJ</code> or full name) and{" "}
          <code className="rounded bg-slate-100 px-1">year</code>. Optional:{" "}
          <code className="rounded bg-slate-100 px-1">title, paperType, state, paperNumber, rawText, markingScheme, fileName</code>.
        </p>
        <textarea
          value={text}
          onChange={(e) => setText(e.target.value)}
          rows={16}
          className="input resize-y font-mono text-xs"
          spellCheck={false}
        />
        <div className="mt-4 flex flex-wrap gap-2">
          <button onClick={importPapers} disabled={busy} className="btn-primary cursor-pointer">
            {busy && !catProgress ? "Importing…" : "Import papers"}
          </button>
          {result && result.ids.length > 0 && (
            <button onClick={categorizeAll} disabled={busy} className="btn-ghost cursor-pointer">
              {catProgress ? `Categorizing ${catProgress.done}/${catProgress.total}…` : `Categorize all (${result.ids.length})`}
            </button>
          )}
        </div>
        {catProgress && (
          <div className="mt-3 h-2 overflow-hidden rounded-full bg-slate-100">
            <div className="h-full bg-emerald-500 transition-all duration-300" style={{ width: `${Math.round((catProgress.done / catProgress.total) * 100)}%` }} />
          </div>
        )}
      </div>

      {result && result.skippedDetail && result.skippedDetail.length > 0 && (
        <section>
          <h2 className="mb-2 text-sm font-bold uppercase tracking-wide text-slate-500">Skipped ({result.skipped})</h2>
          <div className="card divide-y divide-slate-100 text-sm">
            {result.skippedDetail.map((s, i) => (
              <div key={i} className="flex items-center justify-between gap-3 p-3">
                <span className="truncate">{s.title || "(untitled)"}</span>
                <span className="shrink-0 text-xs text-red-600">{s.reason}</span>
              </div>
            ))}
          </div>
        </section>
      )}
    </div>
  );
}
