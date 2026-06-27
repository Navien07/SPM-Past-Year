"use client";

import { useEffect, useState } from "react";

interface Assignment {
  id: string; title: string; type: string; dueAt: string | null; scope: string | null;
  total: number; done: number;
}
interface PaperOpt { id: string; title: string; _count: { questions: number } }

// Create + list class assignments (admin/teacher). Completion shown is cohort
// total; students see their own progress on /assignments.
export default function AssignmentManager() {
  const [items, setItems] = useState<Assignment[]>([]);
  const [papers, setPapers] = useState<PaperOpt[]>([]);
  const [title, setTitle] = useState("");
  const [paperId, setPaperId] = useState("");
  const [dueAt, setDueAt] = useState("");
  const [busy, setBusy] = useState(false);

  async function load() {
    const res = await fetch("/api/assignments");
    if (res.ok) setItems(await res.json());
  }
  useEffect(() => {
    load();
    fetch("/api/papers").then((r) => (r.ok ? r.json() : [])).then((d: PaperOpt[]) =>
      setPapers(d.filter((p) => p._count.questions > 0)),
    );
  }, []);

  async function create(e: React.FormEvent) {
    e.preventDefault();
    if (!title.trim()) return;
    setBusy(true);
    await fetch("/api/assignments", {
      method: "POST", headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        title,
        type: paperId ? "paper" : "topic",
        paperId: paperId || null,
        dueAt: dueAt || null,
      }),
    });
    setTitle(""); setPaperId(""); setDueAt("");
    setBusy(false);
    load();
  }

  async function remove(id: string) {
    setItems((xs) => xs.filter((x) => x.id !== id));
    await fetch("/api/assignments", { method: "DELETE", headers: { "Content-Type": "application/json" }, body: JSON.stringify({ id }) });
  }

  return (
    <section className="space-y-3">
      <h2 className="text-sm font-bold uppercase tracking-wide text-slate-500">Assignments</h2>

      <form onSubmit={create} className="card flex flex-wrap items-end gap-3 p-4">
        <div className="min-w-[12rem] flex-1">
          <label className="label">Title / instruction</label>
          <input value={title} onChange={(e) => setTitle(e.target.value)} className="input" placeholder="e.g. Complete Sejarah Bab 8 questions" />
        </div>
        <div>
          <label className="label">Attach a paper (optional)</label>
          <select value={paperId} onChange={(e) => setPaperId(e.target.value)} className="input">
            <option value="">general / by topic</option>
            {papers.map((p) => <option key={p.id} value={p.id}>{p.title} ({p._count.questions})</option>)}
          </select>
        </div>
        <div>
          <label className="label">Due (optional)</label>
          <input type="date" value={dueAt} onChange={(e) => setDueAt(e.target.value)} className="input" />
        </div>
        <button disabled={busy} className="btn-primary cursor-pointer">{busy ? "…" : "Set assignment"}</button>
      </form>

      <div className="space-y-2">
        {items.length === 0 && <p className="text-sm text-slate-400">No assignments yet.</p>}
        {items.map((a) => (
          <div key={a.id} className="card flex items-center justify-between gap-3 p-3">
            <div className="min-w-0">
              <p className="truncate font-medium">{a.title}</p>
              <p className="text-xs text-slate-400">
                {a.scope ? `${a.scope} · ` : ""}{a.dueAt ? `Due ${new Date(a.dueAt).toLocaleDateString("en-MY")}` : "No due date"}
              </p>
            </div>
            <button onClick={() => remove(a.id)} className="cursor-pointer text-xs font-semibold text-red-600 hover:underline">Remove</button>
          </div>
        ))}
      </div>
    </section>
  );
}
