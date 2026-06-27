"use client";

import { useCallback, useEffect, useState } from "react";
import Link from "next/link";

interface QImg { id: string; number: string | null; stem: string; subject: string; paperTitle: string | null; images: string[] }
interface Subject { id: string; name: string; code: string }

// Admin gallery to spot-check diagram crops: shows each question's stem next to
// its attached figure(s), so crop quality can be verified without logging in as
// a student.
export default function ImageQAPage() {
  const [items, setItems] = useState<QImg[]>([]);
  const [subjects, setSubjects] = useState<Subject[]>([]);
  const [subject, setSubject] = useState("");
  const [cursor, setCursor] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    fetch("/api/taxonomy").then((r) => r.json()).then(setSubjects).catch(() => {});
  }, []);

  const load = useCallback(async (after: string | null, reset: boolean) => {
    setLoading(true);
    const p = new URLSearchParams({ withImages: "1", take: "30" });
    if (subject) p.set("subject", subject);
    if (after) p.set("afterId", after);
    const res = await fetch(`/api/admin/questions?${p.toString()}`);
    const data = res.ok ? await res.json() : { items: [], nextCursor: null };
    setItems((prev) => (reset ? data.items : [...prev, ...data.items]));
    setCursor(data.nextCursor);
    setLoading(false);
  }, [subject]);

  useEffect(() => { load(null, true); }, [load]);

  return (
    <div className="space-y-5">
      <div className="flex items-center justify-between gap-3">
        <div>
          <h1 className="font-display text-2xl font-bold">Diagram QA</h1>
          <p className="text-sm text-slate-500">Spot-check that each attached figure matches its question and is cropped tightly.</p>
        </div>
        <Link href="/admin/qa" className="text-sm font-semibold text-brand-600 hover:underline">Back to QA</Link>
      </div>

      <select value={subject} onChange={(e) => setSubject(e.target.value)} className="input max-w-xs">
        <option value="">All subjects</option>
        {subjects.map((s) => <option key={s.id} value={s.code}>{s.name}</option>)}
      </select>

      {items.length === 0 && !loading ? (
        <div className="card p-8 text-center text-slate-500">No questions with images yet.</div>
      ) : (
        <div className="grid gap-4 lg:grid-cols-2">
          {items.map((q) => (
            <div key={q.id} className="card p-4">
              <div className="mb-1 flex items-center gap-2 text-xs text-slate-400">
                <span className="badge bg-brand-50 text-brand-700">{q.subject}</span>
                {q.number && <span>{q.number}</span>}
                <span className="truncate">{q.paperTitle}</span>
              </div>
              <p className="line-clamp-3 text-sm text-slate-700">{q.stem}</p>
              <div className="mt-2 space-y-2">
                {q.images.map((src, i) => (
                  // eslint-disable-next-line @next/next/no-img-element
                  <img key={i} src={src} alt={`figure ${i + 1}`} className="max-h-72 w-auto rounded-lg border border-slate-200" />
                ))}
              </div>
              <p className="mt-1 break-all text-[10px] text-slate-300">{q.id}</p>
            </div>
          ))}
        </div>
      )}

      {cursor && (
        <button onClick={() => load(cursor, false)} disabled={loading} className="btn-ghost mx-auto block cursor-pointer">
          {loading ? "Loading…" : "Show more"}
        </button>
      )}
    </div>
  );
}
