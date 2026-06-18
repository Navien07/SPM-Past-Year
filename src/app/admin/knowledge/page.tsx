"use client";

import Link from "next/link";
import { useEffect, useState } from "react";

interface Subject { id: string; name: string }
interface Doc {
  id: string;
  title: string;
  kind: string;
  form: number | null;
  source: string | null;
  content: string;
  subject: { name: string } | null;
  createdAt: string;
}

export default function KnowledgePage() {
  const [subjects, setSubjects] = useState<Subject[]>([]);
  const [docs, setDocs] = useState<Doc[]>([]);
  const [busy, setBusy] = useState(false);
  const [msg, setMsg] = useState<string | null>(null);
  const [file, setFile] = useState<File | null>(null);
  const [form, setForm] = useState({ title: "", subjectId: "", form: "", kind: "note", source: "", content: "" });

  async function load() {
    const [s, d] = await Promise.all([
      fetch("/api/taxonomy").then((r) => r.json()),
      fetch("/api/knowledge").then((r) => r.json()),
    ]);
    setSubjects(s);
    setDocs(d);
  }
  useEffect(() => { load(); }, []);

  async function submit(e: React.FormEvent) {
    e.preventDefault();
    setBusy(true);
    setMsg(file ? "Reading PDF…" : null);

    let res: Response;
    const LARGE = 4 * 1024 * 1024;
    if (file && file.size > LARGE) {
      setMsg("Uploading large PDF to storage…");
      try {
        const r = await fetch("/api/upload-url", {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ kind: "knowledge", filename: file.name }),
        });
        const d = await r.json();
        if (!r.ok || !d.signedUrl) throw new Error(d.error || "Storage not configured for large files");
        const up = await fetch(d.signedUrl, { method: "PUT", headers: { "content-type": file.type || "application/pdf" }, body: file });
        if (!up.ok) throw new Error("Upload to storage failed");
        res = await fetch("/api/knowledge", {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ ...form, kind: form.kind === "note" ? "textbook" : form.kind, storagePath: d.path }),
        });
      } catch (err) {
        setBusy(false);
        setMsg(err instanceof Error ? err.message : "Large upload failed");
        return;
      }
    } else if (file) {
      const fd = new FormData();
      fd.append("title", form.title);
      fd.append("subjectId", form.subjectId);
      fd.append("form", form.form);
      fd.append("kind", form.kind === "note" ? "textbook" : form.kind);
      fd.append("source", form.source);
      fd.append("file", file);
      res = await fetch("/api/knowledge", { method: "POST", body: fd });
    } else {
      res = await fetch("/api/knowledge", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(form),
      });
    }

    const data = await res.json();
    setBusy(false);
    if (!res.ok) { setMsg(data.error || "Failed"); return; }
    setMsg("Added to the knowledge base. Cikgu AI will now ground answers on it.");
    setForm({ ...form, title: "", source: "", content: "" });
    setFile(null);
    load();
  }

  return (
    <div className="space-y-6">
      <div className="flex items-end justify-between gap-3">
        <div>
          <h1 className="text-2xl font-bold">Knowledge Base 🧠</h1>
          <p className="text-sm text-slate-500">
            Ingest reference notes & summaries. Cikgu AI retrieves relevant snippets to ground its
            answers (it explains in its own words — it won&apos;t reproduce material verbatim).
          </p>
        </div>
        <Link href="/admin/knowledge/bulk" className="btn-ghost shrink-0">📚 Bulk import</Link>
      </div>

      {msg && <div className="rounded-xl border border-brand-200 bg-brand-50 p-3 text-sm text-brand-800">{msg}</div>}

      <form onSubmit={submit} className="card grid gap-4 p-5 sm:grid-cols-2">
        <div className="sm:col-span-2">
          <label className="label">Title</label>
          <input className="input" required value={form.title} onChange={(e) => setForm({ ...form, title: e.target.value })} placeholder="e.g. Photosynthesis — key concepts" />
        </div>
        <div>
          <label className="label">Subject (optional)</label>
          <select className="input" value={form.subjectId} onChange={(e) => setForm({ ...form, subjectId: e.target.value })}>
            <option value="">— any —</option>
            {subjects.map((s) => <option key={s.id} value={s.id}>{s.name}</option>)}
          </select>
        </div>
        <div>
          <label className="label">Form (optional)</label>
          <select className="input" value={form.form} onChange={(e) => setForm({ ...form, form: e.target.value })}>
            <option value="">— any —</option>
            <option value="4">Tingkatan 4</option>
            <option value="5">Tingkatan 5</option>
          </select>
        </div>
        <div>
          <label className="label">Kind</label>
          <select className="input" value={form.kind} onChange={(e) => setForm({ ...form, kind: e.target.value })}>
            <option value="note">Note</option>
            <option value="summary">Summary</option>
            <option value="textbook">Textbook extract</option>
          </select>
        </div>
        <div>
          <label className="label">Source (optional)</label>
          <input className="input" value={form.source} onChange={(e) => setForm({ ...form, source: e.target.value })} placeholder="e.g. Buku Teks KSSM Tingkatan 4" />
        </div>
        <div className="sm:col-span-2">
          <label className="label">Upload PDF (textbook / notes — text auto-extracted)</label>
          <input
            type="file"
            accept="application/pdf"
            className="input"
            onChange={(e) => setFile(e.target.files?.[0] ?? null)}
          />
          <p className="mt-1 text-xs text-slate-400">
            Tag it with the subject & form above so retrieval can prioritise it. Max 4 MB; text-based
            PDFs (not scans). Cikgu AI explains from it in its own words.{file ? ` Selected: ${file.name}` : ""}
          </p>
        </div>
        <div className="sm:col-span-2">
          <label className="label">…or paste content {file ? "(ignored — PDF selected)" : ""}</label>
          <textarea className="input resize-y" rows={5} disabled={!!file} value={form.content} onChange={(e) => setForm({ ...form, content: e.target.value })} placeholder="Paste notes / summary text…" />
        </div>
        <div className="sm:col-span-2">
          <button className="btn-primary" disabled={busy}>{busy ? "Adding…" : "Add to knowledge base"}</button>
        </div>
      </form>

      <section>
        <h2 className="mb-2 text-sm font-bold uppercase tracking-wide text-slate-500">{docs.length} documents</h2>
        <div className="space-y-2">
          {docs.map((d) => (
            <div key={d.id} className="card p-4">
              <div className="flex flex-wrap items-center gap-2">
                <span className="font-semibold">{d.title}</span>
                <span className="badge bg-slate-100 text-slate-600">{d.kind}</span>
                {d.subject && <span className="badge bg-brand-50 text-brand-700">{d.subject.name}</span>}
                {d.form && <span className="badge bg-slate-100 text-slate-600">T{d.form}</span>}
              </div>
              <p className="mt-1 line-clamp-2 text-sm text-slate-500">{d.content}</p>
              {d.source && <p className="mt-1 text-xs text-slate-400">Source: {d.source}</p>}
            </div>
          ))}
          {docs.length === 0 && <p className="text-sm text-slate-400">No documents yet.</p>}
        </div>
      </section>
    </div>
  );
}
