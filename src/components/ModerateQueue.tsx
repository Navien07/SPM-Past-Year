"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import Icon from "./Icon";

interface Topic { id: string; form: number; chapter: number; title: string }
interface Subject { id: string; name: string; topics: Topic[] }
interface Item {
  id: string;
  stem: string;
  questionType: string;
  paperNumber: number;
  marks: number;
  isKbat: boolean;
  subjectId: string;
  topicId: string | null;
  paperTitle: string | null;
  confidence: number | null;
}

export default function ModerateQueue({ items, subjects }: { items: Item[]; subjects: Subject[] }) {
  if (items.length === 0) {
    return (
      <div className="card p-8 text-center">
        <Icon name="check" className="mx-auto h-10 w-10 text-emerald-600" />
        <p className="mt-2 font-semibold">Queue clear</p>
        <p className="text-sm text-slate-500">No AI-categorized questions are awaiting review.</p>
      </div>
    );
  }
  return (
    <div className="space-y-3">
      {items.map((it) => (
        <ReviewCard key={it.id} item={it} subjects={subjects} />
      ))}
    </div>
  );
}

function ReviewCard({ item, subjects }: { item: Item; subjects: Subject[] }) {
  const router = useRouter();
  const [subjectId, setSubjectId] = useState(item.subjectId);
  const [topicId, setTopicId] = useState(item.topicId ?? "");
  const [isKbat, setIsKbat] = useState(item.isKbat);
  const [marks, setMarks] = useState(item.marks);
  const [busy, setBusy] = useState(false);
  const [done, setDone] = useState<null | "approved" | "rejected">(null);

  const topics = subjects.find((s) => s.id === subjectId)?.topics ?? [];

  async function act(action: "approve" | "reject") {
    setBusy(true);
    const res = await fetch(`/api/moderation/${item.id}`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ action, subjectId, topicId: topicId || null, isKbat, marks }),
    });
    setBusy(false);
    if (res.ok) {
      setDone(action === "approve" ? "approved" : "rejected");
      router.refresh();
    }
  }

  if (done) {
    return (
      <div className={`card flex items-center gap-1.5 p-4 text-sm ${done === "approved" ? "border-emerald-300 bg-emerald-50" : "border-red-200 bg-red-50"}`}>
        {done === "approved" ? (
          <>
            <Icon name="check" className="h-4 w-4 text-emerald-600" />
            Approved, now live for students.
          </>
        ) : (
          <>
            <Icon name="trash" className="h-4 w-4 text-red-600" />
            Rejected, hidden from students.
          </>
        )}
      </div>
    );
  }

  return (
    <div className="card p-4">
      <div className="mb-2 flex flex-wrap items-center gap-2 text-xs">
        <span className="badge bg-slate-100 text-slate-600">{item.questionType}</span>
        <span className="badge bg-slate-100 text-slate-600">Kertas {item.paperNumber}</span>
        {item.confidence != null && (
          <span className={`badge ${item.confidence >= 0.7 ? "bg-amber-100 text-amber-800" : "bg-red-100 text-red-700"}`}>
            AI {Math.round(item.confidence * 100)}% confident
          </span>
        )}
        {item.paperTitle && <span className="text-slate-400">{item.paperTitle}</span>}
      </div>
      <p className="whitespace-pre-wrap text-sm font-medium">{item.stem}</p>

      <div className="mt-3 grid gap-3 sm:grid-cols-2 lg:grid-cols-4">
        <div>
          <label className="label">Subject</label>
          <select className="input" value={subjectId} onChange={(e) => { setSubjectId(e.target.value); setTopicId(""); }}>
            {subjects.map((s) => <option key={s.id} value={s.id}>{s.name}</option>)}
          </select>
        </div>
        <div>
          <label className="label">Topic (form · chapter)</label>
          <select className="input" value={topicId} onChange={(e) => setTopicId(e.target.value)}>
            <option value="">unassigned</option>
            {topics.map((t) => <option key={t.id} value={t.id}>T{t.form} · Bab {t.chapter} · {t.title}</option>)}
          </select>
        </div>
        <div>
          <label className="label">Marks</label>
          <input type="number" min={1} className="input" value={marks} onChange={(e) => setMarks(Number(e.target.value))} />
        </div>
        <label className="flex items-center gap-2 text-sm font-medium sm:mt-7">
          <input type="checkbox" checked={isKbat} onChange={(e) => setIsKbat(e.target.checked)} className="h-4 w-4" />
          KBAT
        </label>
      </div>

      <div className="mt-3 flex gap-2">
        <button onClick={() => act("approve")} disabled={busy} className="btn-primary">
          {busy ? "…" : "Approve"}
        </button>
        <button onClick={() => act("reject")} disabled={busy} className="btn-ghost text-red-600">
          Reject
        </button>
      </div>
    </div>
  );
}
