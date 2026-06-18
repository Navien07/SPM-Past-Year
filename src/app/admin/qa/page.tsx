"use client";

import { useCallback, useEffect, useState } from "react";

interface QAItem {
  id: string;
  stem: string;
  questionType: string;
  status: string;
  reviewNote: string | null;
  marks: number;
  topicId: string | null;
  answer: string | null;
  subject: { name: string; code: string };
  topic: { title: string; form: number; chapter: number } | null;
  paper: { title: string } | null;
}

export default function QAPage() {
  const [items, setItems] = useState<QAItem[]>([]);
  const [counts, setCounts] = useState<Record<string, number>>({});
  const [q, setQ] = useState("");
  const [loading, setLoading] = useState(true);

  const load = useCallback(async (query = "") => {
    setLoading(true);
    const res = await fetch(`/api/admin/qa${query ? `?q=${encodeURIComponent(query)}` : ""}`);
    const data = res.ok ? await res.json() : { items: [], counts: {} };
    setItems(data.items);
    setCounts(data.counts);
    setLoading(false);
  }, []);

  useEffect(() => { load(); }, [load]);

  async function act(id: string, action: "approve" | "reject" | "delete") {
    setItems((xs) => xs.filter((x) => x.id !== id));
    await fetch("/api/admin/qa", {
      method: "PATCH",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ id, action }),
    });
  }

  return (
    <div className="space-y-5">
      <div>
        <h1 className="text-2xl font-bold">Content QA 🔍</h1>
        <p className="text-sm text-slate-500">Catch bad parses before students see them — flagged, untagged or invalid questions.</p>
      </div>

      <div className="flex flex-wrap gap-2 text-sm">
        <span className="badge bg-emerald-100 text-emerald-700">{counts.approved ?? 0} approved</span>
        <span className="badge bg-amber-100 text-amber-800">{counts.pending ?? 0} pending</span>
        <span className="badge bg-red-100 text-red-700">{counts.rejected ?? 0} rejected</span>
      </div>

      <form
        onSubmit={(e) => { e.preventDefault(); load(q); }}
        className="flex gap-2"
      >
        <input value={q} onChange={(e) => setQ(e.target.value)} placeholder="Search question text…" className="input" />
        <button className="btn-primary cursor-pointer">Search</button>
        {q && <button type="button" onClick={() => { setQ(""); load(); }} className="btn-ghost cursor-pointer">Clear</button>}
      </form>

      {loading ? (
        <p className="text-sm text-slate-400">Loading…</p>
      ) : items.length === 0 ? (
        <div className="card p-8 text-center text-slate-500">🎉 Nothing flagged. The question bank is clean.</div>
      ) : (
        <div className="space-y-3">
          {items.map((it) => (
            <div key={it.id} className="card p-4">
              <div className="mb-1 flex flex-wrap items-center gap-2 text-xs">
                <span className="badge bg-brand-50 text-brand-700">{it.subject.code}</span>
                <span className="badge bg-slate-100 text-slate-600">{it.questionType}</span>
                <span className="badge bg-slate-100 text-slate-600">{it.marks} markah</span>
                <span className={`badge ${it.status === "approved" ? "bg-emerald-100 text-emerald-700" : it.status === "rejected" ? "bg-red-100 text-red-700" : "bg-amber-100 text-amber-800"}`}>{it.status}</span>
                {it.topic ? (
                  <span className="text-slate-400">T{it.topic.form} · Bab {it.topic.chapter} · {it.topic.title}</span>
                ) : (
                  <span className="badge bg-red-100 text-red-700">No topic</span>
                )}
              </div>
              <p className="line-clamp-2 text-sm text-slate-700">{it.stem || <em className="text-red-500">(empty stem)</em>}</p>
              {it.reviewNote && <p className="mt-1 text-xs font-medium text-red-600">⚠ {it.reviewNote}</p>}
              <p className="mt-1 text-xs text-slate-400">{it.paper?.title ?? "—"} · answer: {it.answer ?? "—"}</p>
              <div className="mt-3 flex flex-wrap gap-2">
                <button onClick={() => act(it.id, "approve")} className="btn-primary cursor-pointer px-3 py-1.5 text-xs">Approve</button>
                <button onClick={() => act(it.id, "reject")} className="btn-ghost cursor-pointer px-3 py-1.5 text-xs">Reject</button>
                <button onClick={() => act(it.id, "delete")} className="cursor-pointer px-3 py-1.5 text-xs font-semibold text-red-600 hover:underline">Delete</button>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
