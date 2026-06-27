"use client";

import { useEffect, useState } from "react";
import Link from "next/link";

interface Assignment {
  id: string; title: string; type: string; dueAt: string | null; scope: string | null;
  paperId: string | null; topicId: string | null; subjectId: string | null;
  total: number; done: number;
}

export default function AssignmentsPage() {
  const [items, setItems] = useState<Assignment[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetch("/api/assignments").then((r) => (r.ok ? r.json() : [])).then((d) => { setItems(d); setLoading(false); });
  }, []);

  return (
    <div className="space-y-5">
      <div>
 <h1 className="text-2xl font-bold">My Assignments</h1>
        <p className="text-sm text-slate-500">Work set by your teacher.</p>
      </div>

      {loading ? (
        <p className="text-sm text-slate-400">Loading…</p>
      ) : items.length === 0 ? (
        <div className="card p-8 text-center text-slate-500">
          No assignments right now. <Link href="/practice" className="font-semibold text-brand-600 hover:underline">Practise freely →</Link>
        </div>
      ) : (
        <div className="space-y-3">
          {items.map((a) => {
            const pct = a.total ? Math.round((a.done / a.total) * 100) : 0;
            const overdue = a.dueAt && new Date(a.dueAt) < new Date() && pct < 100;
            return (
              <div key={a.id} className="card p-4">
                <div className="flex items-start justify-between gap-3">
                  <div>
                    <p className="font-semibold">{a.title}</p>
                    <p className="text-xs text-slate-400">
                      {a.scope ? `${a.scope} · ` : ""}
                      {a.dueAt ? <span className={overdue ? "font-semibold text-red-600" : ""}>Due {new Date(a.dueAt).toLocaleDateString("en-MY")}</span> : "No due date"}
                    </p>
                  </div>
                  {pct >= 100 ? <span className="badge bg-emerald-100 text-emerald-700">✓ Done</span> : <span className="badge bg-amber-100 text-amber-800">{pct}%</span>}
                </div>
                <div className="mt-2 h-2 overflow-hidden rounded-full bg-slate-100">
                  <div className={`h-full ${pct >= 100 ? "bg-emerald-500" : "bg-brand-500"}`} style={{ width: `${pct}%` }} />
                </div>
                <p className="mt-1 text-xs text-slate-500">{a.done}/{a.total} questions done</p>
                <Link
                  href={a.paperId ? `/paper/${a.paperId}` : a.subjectId ? `/practice?subject=${a.subjectId}` : "/practice"}
                  className="btn-primary mt-3 inline-flex px-3 py-1.5 text-xs"
                >
                  {pct >= 100 ? "Review" : "Start"}
                </Link>
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}
