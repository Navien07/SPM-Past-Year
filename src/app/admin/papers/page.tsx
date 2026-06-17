"use client";

import { useEffect, useState } from "react";
import { PAPER_TYPES, PAPER_TYPE_LABEL, MALAYSIA_STATES } from "@/lib/constants";

interface Subject {
  id: string;
  name: string;
}
interface Paper {
  id: string;
  title: string;
  paperType: string;
  year: number;
  state: string | null;
  paperNumber: number;
  status: string;
  subject: { name: string };
  _count: { questions: number };
}

const SAMPLE_TEXT = `1. Tamadun awal manusia muncul di lembah sungai yang subur. Antara berikut, yang manakah merupakan tamadun yang muncul di Lembah Sungai Nil?
A. Tamadun Mesopotamia
B. Tamadun Mesir Purba
C. Tamadun Indus
D. Tamadun Hwang Ho

2. Mengapakah masyarakat awal memilih untuk menetap di kawasan lembah sungai?

3. Huraikan sumbangan tamadun awal manusia dalam bidang ilmu pengetahuan dan teknologi.`;

export default function AdminPage() {
  const [subjects, setSubjects] = useState<Subject[]>([]);
  const [papers, setPapers] = useState<Paper[]>([]);
  const [busy, setBusy] = useState<string | null>(null);
  const [msg, setMsg] = useState<string | null>(null);
  const [file, setFile] = useState<File | null>(null);

  const [form, setForm] = useState({
    title: "",
    subjectId: "",
    paperType: "trial",
    year: new Date().getFullYear(),
    state: "",
    paperNumber: 1,
    rawText: SAMPLE_TEXT,
    markingScheme: "",
  });

  async function loadAll() {
    const [s, p] = await Promise.all([
      fetch("/api/taxonomy").then((r) => r.json()),
      fetch("/api/papers").then((r) => r.json()),
    ]);
    setSubjects(s);
    setPapers(p);
    if (!form.subjectId && s[0]) setForm((f) => ({ ...f, subjectId: s[0].id }));
  }

  useEffect(() => {
    loadAll();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  async function createPaper(e: React.FormEvent) {
    e.preventDefault();
    setBusy("create");
    setMsg(null);

    let res: Response;
    if (file) {
      // PDF upload → server extracts the text into rawText.
      setMsg("Reading PDF…");
      const fd = new FormData();
      fd.append("title", form.title);
      fd.append("subjectId", form.subjectId);
      fd.append("paperType", form.paperType);
      fd.append("year", String(form.year));
      fd.append("state", form.state);
      fd.append("paperNumber", String(form.paperNumber));
      fd.append("markingScheme", form.markingScheme);
      fd.append("file", file);
      res = await fetch("/api/papers", { method: "POST", body: fd });
    } else {
      res = await fetch("/api/papers", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(form),
      });
    }

    const data = await res.json();
    if (!res.ok) {
      setBusy(null);
      setMsg(data.error || "Failed to create paper");
      return;
    }

    setForm((f) => ({ ...f, title: "" }));
    setFile(null);

    // PDF flow auto-categorizes immediately so it's "drop-in & parsed".
    if (file && data.id) {
      setMsg("PDF read. Auto-categorizing with AI…");
      await categorize(data.id);
    } else {
      setBusy(null);
      setMsg("Paper added. Click Categorize to build the question bank.");
      loadAll();
    }
  }

  async function categorize(id: string) {
    setBusy(id);
    setMsg(null);
    const res = await fetch(`/api/papers/${id}/categorize`, { method: "POST" });
    const data = await res.json();
    setBusy(null);
    if (!res.ok) {
      setMsg(data.error || "Categorization failed");
    } else {
      setMsg(
        `Categorized ${data.created} question(s) ${data.byAi ? "with Claude" : "(offline heuristic)"} — ` +
          `${data.autoApproved ?? 0} auto-approved (≥${Math.round((data.threshold ?? 0.85) * 100)}% confidence), ` +
          `${data.pending ?? 0} sent to the Review queue.`,
      );
    }
    loadAll();
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold">Admin · Upload & Categorize 🗂️</h1>
        <p className="text-sm text-slate-500">
          Add past-year, trial, state and mock papers. The AI agent splits each paper into
          questions and tags them by topic, form, year and KBAT.
        </p>
      </div>

      {msg && (
        <div className="rounded-xl border border-brand-200 bg-brand-50 p-3 text-sm text-brand-800">{msg}</div>
      )}

      {/* Upload form */}
      <form onSubmit={createPaper} className="card grid gap-4 p-5 sm:grid-cols-2">
        <div className="sm:col-span-2">
          <label className="label">Paper title</label>
          <input
            className="input"
            required
            placeholder="e.g. Sejarah Kertas 2 — Percubaan SPM 2025 (Kedah)"
            value={form.title}
            onChange={(e) => setForm({ ...form, title: e.target.value })}
          />
        </div>
        <div>
          <label className="label">Subject</label>
          <select className="input" value={form.subjectId} onChange={(e) => setForm({ ...form, subjectId: e.target.value })}>
            {subjects.map((s) => (
              <option key={s.id} value={s.id}>{s.name}</option>
            ))}
          </select>
        </div>
        <div>
          <label className="label">Paper type</label>
          <select className="input" value={form.paperType} onChange={(e) => setForm({ ...form, paperType: e.target.value })}>
            {PAPER_TYPES.map((p) => (
              <option key={p.value} value={p.value}>{p.label}</option>
            ))}
          </select>
        </div>
        <div>
          <label className="label">Year</label>
          <input
            type="number"
            className="input"
            value={form.year}
            onChange={(e) => setForm({ ...form, year: Number(e.target.value) })}
          />
        </div>
        <div>
          <label className="label">Paper number</label>
          <select className="input" value={form.paperNumber} onChange={(e) => setForm({ ...form, paperNumber: Number(e.target.value) })}>
            <option value={1}>Kertas 1</option>
            <option value={2}>Kertas 2</option>
            <option value={3}>Kertas 3 (amali — sains)</option>
          </select>
        </div>
        <div className="sm:col-span-2">
          <label className="label">State / body (for state & trial papers)</label>
          <select className="input" value={form.state} onChange={(e) => setForm({ ...form, state: e.target.value })}>
            <option value="">— none —</option>
            {MALAYSIA_STATES.map((s) => (
              <option key={s} value={s}>{s}</option>
            ))}
          </select>
        </div>
        <div className="sm:col-span-2">
          <label className="label">Upload PDF (auto-parsed & categorized)</label>
          <input
            type="file"
            accept="application/pdf"
            className="input"
            onChange={(e) => setFile(e.target.files?.[0] ?? null)}
          />
          <p className="mt-1 text-xs text-slate-400">
            Drop in the paper PDF — the text is extracted and the AI categorizes every question by
            subject, topic, form & year automatically (max 4 MB; text-based PDFs, not scans).
            {file ? ` Selected: ${file.name}` : ""}
          </p>
        </div>
        <div className="sm:col-span-2">
          <label className="label">…or paste paper text {file ? "(ignored — PDF selected)" : ""}</label>
          <textarea
            className="input resize-y font-mono text-xs"
            rows={6}
            disabled={!!file}
            value={form.rawText}
            onChange={(e) => setForm({ ...form, rawText: e.target.value })}
          />
        </div>
        <div className="sm:col-span-2">
          <label className="label">Marking scheme / answer key (optional)</label>
          <textarea
            className="input resize-y"
            rows={3}
            value={form.markingScheme}
            onChange={(e) => setForm({ ...form, markingScheme: e.target.value })}
          />
        </div>
        <div className="sm:col-span-2">
          <button type="submit" disabled={busy === "create"} className="btn-primary">
            {busy === "create" ? "Adding…" : "Add paper"}
          </button>
        </div>
      </form>

      {/* Papers list */}
      <section>
        <h2 className="mb-2 text-sm font-bold uppercase tracking-wide text-slate-500">Uploaded papers</h2>
        <div className="space-y-2">
          {papers.length === 0 && <p className="text-sm text-slate-400">No papers yet.</p>}
          {papers.map((p) => (
            <div key={p.id} className="card flex flex-wrap items-center justify-between gap-3 p-4">
              <div className="min-w-0">
                <p className="truncate font-semibold">{p.title}</p>
                <div className="mt-1 flex flex-wrap items-center gap-2 text-xs">
                  <span className="badge bg-brand-50 text-brand-700">{p.subject.name}</span>
                  <span className="badge bg-slate-100 text-slate-600">{PAPER_TYPE_LABEL[p.paperType]}</span>
                  <span className="badge bg-slate-100 text-slate-600">{p.year}</span>
                  {p.state && <span className="badge bg-slate-100 text-slate-600">{p.state}</span>}
                  <span className="badge bg-slate-100 text-slate-600">Kertas {p.paperNumber}</span>
                  <StatusBadge status={p.status} />
                  <span className="text-slate-400">{p._count.questions} soalan</span>
                </div>
              </div>
              <button onClick={() => categorize(p.id)} disabled={busy === p.id} className="btn-ghost">
                {busy === p.id ? "Categorizing…" : p._count.questions > 0 ? "Re-categorize" : "Categorize"}
              </button>
            </div>
          ))}
        </div>
      </section>
    </div>
  );
}

function StatusBadge({ status }: { status: string }) {
  const map: Record<string, string> = {
    uploaded: "bg-slate-100 text-slate-600",
    categorizing: "bg-amber-100 text-amber-800",
    categorized: "bg-emerald-100 text-emerald-800",
    failed: "bg-red-100 text-red-700",
  };
  return <span className={`badge ${map[status] ?? map.uploaded}`}>{status}</span>;
}
