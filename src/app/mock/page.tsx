"use client";

import { useEffect, useState } from "react";
import Link from "next/link";

interface Subject {
  id: string;
  name: string;
  _count: { questions: number };
}
interface MockQuestion {
  id: string;
  stem: string;
  marks: number;
  isKbat: boolean;
  topic: string | null;
  questionType: string;
}

export default function MockPage() {
  const [subjects, setSubjects] = useState<Subject[]>([]);
  const [subjectId, setSubjectId] = useState("");
  const [paperNumber, setPaperNumber] = useState(1);
  const [count, setCount] = useState(10);
  const [kbatBias, setKbatBias] = useState(false);
  const [loading, setLoading] = useState(false);
  const [questions, setQuestions] = useState<MockQuestion[]>([]);
  const [title, setTitle] = useState("");
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    fetch("/api/taxonomy")
      .then((r) => r.json())
      .then((data: Subject[]) => {
        setSubjects(data);
        if (data[0]) setSubjectId(data[0].id);
      });
  }, []);

  async function build() {
    setLoading(true);
    setError(null);
    setQuestions([]);
    const res = await fetch("/api/mock", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ subjectId, paperNumber, count, kbatBias }),
    });
    const data = await res.json();
    if (!res.ok) {
      setError(data.error || "Failed to build mock");
    } else {
      setQuestions(data.questions);
      setTitle(data.mock.title);
    }
    setLoading(false);
  }

  const totalMarks = questions.reduce((a, q) => a + q.marks, 0);

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold">Mock Paper Builder 🧪</h1>
        <p className="text-sm text-slate-500">
          Auto-assemble a mock paper from the question bank, spread across topics.
        </p>
      </div>

      <div className="card grid gap-4 p-5 sm:grid-cols-2">
        <div>
          <label className="label">Subject</label>
          <select className="input" value={subjectId} onChange={(e) => setSubjectId(e.target.value)}>
            {subjects.map((s) => (
              <option key={s.id} value={s.id}>{s.name} ({s._count.questions})</option>
            ))}
          </select>
        </div>
        <div>
          <label className="label">Paper</label>
          <select className="input" value={paperNumber} onChange={(e) => setPaperNumber(Number(e.target.value))}>
            <option value={1}>Kertas 1 (Objektif)</option>
            <option value={2}>Kertas 2 (Subjektif)</option>
          </select>
        </div>
        <div>
          <label className="label">Number of questions</label>
          <input
            type="number"
            min={1}
            max={40}
            className="input"
            value={count}
            onChange={(e) => setCount(Number(e.target.value))}
          />
        </div>
        <label className="flex items-center gap-2 text-sm font-medium sm:mt-7">
          <input type="checkbox" checked={kbatBias} onChange={(e) => setKbatBias(e.target.checked)} className="h-4 w-4" />
          Bias toward KBAT
        </label>
        <div className="sm:col-span-2">
          <button onClick={build} disabled={loading || !subjectId} className="btn-primary w-full sm:w-auto">
            {loading ? "Building…" : "Build mock paper"}
          </button>
        </div>
      </div>

      {error && <p className="text-sm text-red-600">{error}</p>}

      {questions.length > 0 && (
        <section className="space-y-3">
          <div className="card flex items-center justify-between p-4">
            <div>
              <h2 className="font-bold">{title}</h2>
              <p className="text-sm text-slate-500">
                {questions.length} questions · {totalMarks} marks
              </p>
            </div>
          </div>
          {questions.map((q, i) => (
            <Link key={q.id} href={`/practice/${q.id}`} className="card block p-4 hover:border-brand-300">
              <div className="mb-1 flex flex-wrap items-center gap-2">
                <span className="grid h-6 w-6 place-items-center rounded-full bg-brand-600 text-xs font-bold text-white">
                  {i + 1}
                </span>
                <span className="badge bg-slate-100 text-slate-600">{q.marks} markah</span>
                {q.isKbat && <span className="tag-kbat">KBAT</span>}
                {q.topic && <span className="text-xs text-slate-400">{q.topic}</span>}
              </div>
              <p className="line-clamp-2 text-sm text-slate-700">{q.stem}</p>
            </Link>
          ))}
        </section>
      )}
    </div>
  );
}
