"use client";

import { useEffect, useState } from "react";
import Link from "next/link";

interface Subject { id: string; name: string }

const STATES = [
  "Johor", "Kedah", "Kelantan", "Melaka", "Negeri Sembilan", "Pahang", "Perak", "Perlis",
  "Pulau Pinang", "Sabah", "Sarawak", "Selangor", "Terengganu", "Kuala Lumpur", "Putrajaya", "Labuan",
];

export default function NewUserPage() {
  const [subjects, setSubjects] = useState<Subject[]>([]);
  const [picked, setPicked] = useState<Set<string>>(new Set());
  const [form, setForm] = useState({ role: "student", name: "", email: "", password: "", school: "", age: "", state: "", whatsapp: "", form: "5" });
  const [msg, setMsg] = useState<string | null>(null);
  const [err, setErr] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    fetch("/api/taxonomy").then((r) => r.json()).then((d: Subject[]) => {
      setSubjects(d);
      setPicked(new Set(d.map((s) => s.id)));
    }).catch(() => {});
  }, []);

  function toggle(id: string) {
    setPicked((p) => { const n = new Set(p); n.has(id) ? n.delete(id) : n.add(id); return n; });
  }

  async function submit(e: React.FormEvent) {
    e.preventDefault();
    setErr(null); setMsg(null); setLoading(true);
    const res = await fetch("/api/admin/users", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ ...form, form: Number(form.form), subjectIds: [...picked] }),
    });
    const data = await res.json().catch(() => ({}));
    setLoading(false);
    if (!res.ok) return setErr(data.error || "Failed to create account");
    setMsg(`✓ ${form.role} account created for ${form.email}. Share the password with them.`);
    setForm({ ...form, name: "", email: "", password: "", school: "", age: "", whatsapp: "" });
  }

  return (
    <div className="mx-auto max-w-lg space-y-4">
      <Link href="/admin/students" className="text-sm text-brand-600 hover:underline">← Students</Link>
      <div>
        <h1 className="text-2xl font-bold">Create an account 👤</h1>
        <p className="text-sm text-slate-500">Add a student (or another admin). They sign in with this email & password.</p>
      </div>
      {msg && <div className="rounded-xl border border-emerald-200 bg-emerald-50 p-3 text-sm text-emerald-800">{msg}</div>}
      <form onSubmit={submit} className="card space-y-4 p-5">
        <div>
          <label className="label">Role</label>
          <select className="input" value={form.role} onChange={(e) => setForm({ ...form, role: e.target.value })}>
            <option value="student">Student</option>
            <option value="teacher">Teacher</option>
            <option value="admin">Admin</option>
          </select>
        </div>
        <div className="grid grid-cols-2 gap-3">
          <div><label className="label">Full name</label><input className="input" value={form.name} onChange={(e) => setForm({ ...form, name: e.target.value })} required /></div>
          <div><label className="label">Email</label><input className="input" type="email" value={form.email} onChange={(e) => setForm({ ...form, email: e.target.value })} required /></div>
        </div>
        <div><label className="label">Initial password (min 6)</label><input className="input" value={form.password} onChange={(e) => setForm({ ...form, password: e.target.value })} required minLength={6} /></div>

        {form.role === "student" && (
          <>
            <div className="grid grid-cols-2 gap-3">
              <div><label className="label">School</label><input className="input" value={form.school} onChange={(e) => setForm({ ...form, school: e.target.value })} /></div>
              <div><label className="label">Form</label>
                <select className="input" value={form.form} onChange={(e) => setForm({ ...form, form: e.target.value })}>
                  <option value="4">Tingkatan 4</option><option value="5">Tingkatan 5</option>
                </select>
              </div>
            </div>
            <div className="grid grid-cols-3 gap-3">
              <div><label className="label">Age</label><input className="input" type="number" value={form.age} onChange={(e) => setForm({ ...form, age: e.target.value })} /></div>
              <div className="col-span-2"><label className="label">State</label>
                <select className="input" value={form.state} onChange={(e) => setForm({ ...form, state: e.target.value })}>
                  <option value="">—</option>{STATES.map((s) => <option key={s} value={s}>{s}</option>)}
                </select>
              </div>
            </div>
            <div><label className="label">Phone / WhatsApp</label><input className="input" type="tel" value={form.whatsapp} onChange={(e) => setForm({ ...form, whatsapp: e.target.value })} /></div>
            <div>
              <label className="label">Subjects</label>
              <div className="flex flex-wrap gap-2">
                {subjects.map((s) => (
                  <button type="button" key={s.id} onClick={() => toggle(s.id)} className={`badge border px-3 py-1.5 ${picked.has(s.id) ? "border-brand-300 bg-brand-50 text-brand-700" : "border-slate-200 bg-white text-slate-500"}`}>
                    {picked.has(s.id) ? "✓ " : ""}{s.name}
                  </button>
                ))}
              </div>
            </div>
          </>
        )}
        {err && <p className="text-sm text-red-600">{err}</p>}
        <button className="btn-primary" disabled={loading}>{loading ? "Creating…" : "Create account"}</button>
      </form>
    </div>
  );
}
