"use client";

import { useState } from "react";
import Link from "next/link";

const SAMPLE = `{
  "docs": [
    {
      "title": "Sejarah Tingkatan 4 — Bab 8: Usaha ke Arah Kemerdekaan",
      "subject": "SEJ",
      "form": 4,
      "chapter": 8,
      "topicTitle": "Usaha ke Arah Kemerdekaan",
      "kind": "textbook",
      "source": "Buku Teks KSSM Sejarah T4 (KPM)",
      "sourceUrl": "https://…",
      "sourceKey": "sej-t4-bab8",
      "language": "bm",
      "content": "Clean chapter text here (≈500–2000 words)…"
    }
  ]
}`;

export default function KnowledgeBulkPage() {
  const [text, setText] = useState(SAMPLE);
  const [busy, setBusy] = useState(false);
  const [msg, setMsg] = useState<string | null>(null);

  async function importDocs() {
    setBusy(true);
    setMsg(null);
    let body: unknown;
    try {
      body = JSON.parse(text);
    } catch {
      setBusy(false);
      setMsg("That isn't valid JSON. Paste an object like { \"docs\": [ … ] }.");
      return;
    }
    try {
      const res = await fetch("/api/admin/knowledge/bulk", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(body),
      });
      const data = await res.json();
      setMsg(res.ok
        ? `Imported ${data.created} new + ${data.updated} updated chunk(s); ${data.skipped} skipped.`
        : data.error || "Import failed.");
    } finally {
      setBusy(false);
    }
  }

  return (
    <div className="space-y-6">
      <div className="flex items-end justify-between gap-3">
        <div>
          <h1 className="text-2xl font-bold">Bulk import textbooks 📚</h1>
          <p className="text-sm text-slate-500">
            Paste chunked textbook/notes (one chunk per chapter/section). Re-running with the same
            <code className="mx-1 rounded bg-slate-100 px-1">sourceKey</code> updates in place — no duplicates.
          </p>
        </div>
        <Link href="/admin/knowledge" className="btn-ghost shrink-0">← Single upload</Link>
      </div>

      {msg && <div className="rounded-xl border border-brand-200 bg-brand-50 p-3 text-sm text-brand-800">{msg}</div>}

      <div className="card p-5">
        <label className="label">Knowledge JSON (max 1000 chunks)</label>
        <p className="mb-2 text-xs text-slate-500">
          Each chunk needs <code className="rounded bg-slate-100 px-1">title</code> &amp;
          <code className="mx-1 rounded bg-slate-100 px-1">content</code>. Add
          <code className="mx-1 rounded bg-slate-100 px-1">subject</code> +
          <code className="mx-1 rounded bg-slate-100 px-1">form</code>/<code className="rounded bg-slate-100 px-1">chapter</code> or
          <code className="mx-1 rounded bg-slate-100 px-1">topicTitle</code> to auto-link it to a KSSM topic.
        </p>
        <textarea value={text} onChange={(e) => setText(e.target.value)} rows={16} className="input resize-y font-mono text-xs" spellCheck={false} />
        <button onClick={importDocs} disabled={busy} className="btn-primary mt-4 cursor-pointer">
          {busy ? "Importing…" : "Import textbooks"}
        </button>
      </div>
    </div>
  );
}
