"use client";

import { useCallback, useEffect, useState } from "react";

interface Topic { id: string; form: number; chapter: number; title: string }
interface Subject { id: string; name: string; code: string; topics: Topic[] }
interface QAItem {
  id: string; stem: string; questionType: string; status: string; reviewNote: string | null;
  marks: number; topicId: string | null; answer: string | null; subjectId: string;
  subject: { name: string; code: string };
  topic: { title: string; form: number; chapter: number } | null;
  paper: { title: string } | null;
}

export default function QAPage() {
  const [items, setItems] = useState<QAItem[]>([]);
  const [counts, setCounts] = useState<Record<string, number>>({});
  const [untagged, setUntagged] = useState(0);
  const [subjects, setSubjects] = useState<Subject[]>([]);
  const [filter, setFilter] = useState("flagged");
  const [subject, setSubject] = useState("");
  const [q, setQ] = useState("");
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetch("/api/taxonomy").then((r) => r.json()).then(setSubjects).catch(() => {});
  }, []);

  const load = useCallback(async () => {
    setLoading(true);
    const p = new URLSearchParams({ filter });
    if (subject) p.set("subject", subject);
    if (q) p.set("q", q);
    const res = await fetch(`/api/admin/qa?${p.toString()}`);
    const data = res.ok ? await res.json() : { items: [], counts: {}, untagged: 0 };
    setItems(data.items);
    setCounts(data.counts);
    setUntagged(data.untagged ?? 0);
    setLoading(false);
  }, [filter, subject, q]);

  useEffect(() => { load(); }, [load]);

  async function act(id: string, action: "approve" | "reject" | "delete") {
    setItems((xs) => xs.filter((x) => x.id !== id));
    await fetch("/api/admin/qa", {
      method: "PATCH", headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ id, action }),
    });
  }

  async function assignTopic(item: QAItem, topicId: string) {
    if (!topicId) return;
    const tp = subjects.find((s) => s.id === item.subjectId)?.topics.find((t) => t.id === topicId) ?? null;
    setItems((xs) => xs.map((x) => (x.id === item.id ? { ...x, topicId, topic: tp ? { title: tp.title, form: tp.form, chapter: tp.chapter } : x.topic } : x)));
    await fetch("/api/admin/set-topics", {
      method: "POST", headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ target: "questions", items: [{ id: item.id, topicId }] }),
    });
  }

  const topicsFor = (subjectId: string) => subjects.find((s) => s.id === subjectId)?.topics ?? [];

  return (
    <div className="space-y-5">
      <div>
        <h1 className="text-2xl font-bold">Content QA</h1>
        <p className="text-sm text-slate-500">Review flagged questions and assign topics manually where the AI couldn&apos;t.</p>
      </div>

      <div className="flex flex-wrap gap-2 text-sm">
        <span className="badge bg-emerald-100 text-emerald-700">{counts.approved ?? 0} approved</span>
        <span className="badge bg-amber-100 text-amber-800">{counts.pending ?? 0} pending</span>
        <span className="badge bg-red-100 text-red-700">{counts.rejected ?? 0} rejected</span>
        <span className="badge bg-slate-100 text-slate-600">{untagged.toLocaleString("en-MY")} unlinked</span>
      </div>

      {/* Filters */}
      <div className="card grid gap-3 p-4 sm:grid-cols-4">
        <select value={filter} onChange={(e) => setFilter(e.target.value)} className="input">
          <option value="flagged">Flagged (pending / issues / no topic)</option>
          <option value="unlinked">Unlinked (no topic)</option>
          <option value="linked">Linked to a topic</option>
          <option value="all">All questions</option>
        </select>
        <select value={subject} onChange={(e) => setSubject(e.target.value)} className="input">
          <option value="">All subjects</option>
          {subjects.map((s) => <option key={s.id} value={s.code}>{s.name}</option>)}
        </select>
        <input value={q} onChange={(e) => setQ(e.target.value)} onKeyDown={(e) => e.key === "Enter" && load()} placeholder="Search question text…" className="input sm:col-span-2" />
      </div>

      {loading ? (
        <p className="text-sm text-slate-400">Loading…</p>
      ) : items.length === 0 ? (
        <div className="card p-8 text-center text-slate-500">Nothing matches this filter.</div>
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
              {it.reviewNote && <p className="mt-1 text-xs font-medium text-red-600">{it.reviewNote}</p>}
              <p className="mt-1 text-xs text-slate-400">{it.paper?.title ?? "—"} · answer: {it.answer ?? "—"}</p>
              <div className="mt-3 flex flex-wrap items-center gap-2">
                <select
                  value={it.topicId ?? ""}
                  onChange={(e) => assignTopic(it, e.target.value)}
                  className="input max-w-xs py-1.5 text-xs"
                >
                  <option value="">Assign topic…</option>
                  {topicsFor(it.subjectId).map((t) => (
                    <option key={t.id} value={t.id}>T{t.form} · Bab {t.chapter} · {t.title}</option>
                  ))}
                </select>
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
