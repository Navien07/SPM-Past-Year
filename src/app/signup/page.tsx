"use client";

import { useEffect, useState } from "react";
import Link from "next/link";

interface Subject { id: string; name: string }

const STATES = [
  "Johor", "Kedah", "Kelantan", "Melaka", "Negeri Sembilan", "Pahang", "Perak", "Perlis",
  "Pulau Pinang", "Sabah", "Sarawak", "Selangor", "Terengganu",
  "Kuala Lumpur", "Putrajaya", "Labuan",
];

export default function SignupPage() {
  const [subjects, setSubjects] = useState<Subject[]>([]);
  const [picked, setPicked] = useState<Set<string>>(new Set());
  const [form, setForm] = useState({ name: "", school: "", age: "", state: "", email: "", whatsapp: "", form: "5", password: "", confirm: "" });
  const [consent, setConsent] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    fetch("/api/taxonomy")
      .then((r) => r.json())
      .then((data: Subject[]) => {
        setSubjects(data);
        setPicked(new Set(data.map((s) => s.id))); // default: enrol in all
      })
      .catch(() => {});
  }, []);

  function toggle(id: string) {
    setPicked((prev) => {
      const n = new Set(prev);
      n.has(id) ? n.delete(id) : n.add(id);
      return n;
    });
  }

  async function submit(e: React.FormEvent) {
    e.preventDefault();
    setError(null);
    if (form.password !== form.confirm) {
      setError("Passwords don't match.");
      return;
    }
    setLoading(true);
    try {
      const res = await fetch("/api/auth/signup", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          name: form.name,
          school: form.school,
          age: form.age,
          state: form.state,
          email: form.email,
          whatsapp: form.whatsapp,
          consent,
          password: form.password,
          form: Number(form.form),
          subjectIds: [...picked],
        }),
      });
      const data = await res.json().catch(() => ({}));
      if (!res.ok) throw new Error(data.error || "Sign up failed");
      window.location.assign(data.redirect || "/");
    } catch (e) {
      setError(e instanceof Error ? e.message : "Sign up failed");
      setLoading(false);
    }
  }

  return (
    <div className="mx-auto max-w-md py-6">
      <div className="card overflow-hidden">
        <div className="bg-gradient-to-br from-brand-600 to-brand-800 p-6 text-white">
          <div className="text-lg font-bold">Create your SPM AI account</div>
          <div className="text-xs text-brand-100">Free pilot — practise every SPM, trial, MRSM, SPP & state paper.</div>
        </div>
        <form onSubmit={submit} className="space-y-4 p-6">
          <div>
            <label className="label">Full name</label>
            <input className="input" value={form.name} onChange={(e) => setForm({ ...form, name: e.target.value })} required />
          </div>
          <div>
            <label className="label">School name</label>
            <input className="input" value={form.school} onChange={(e) => setForm({ ...form, school: e.target.value })} placeholder="e.g. SMK Seksyen 9" required />
          </div>
          <div className="grid grid-cols-2 gap-3">
            <div>
              <label className="label">Age</label>
              <input className="input" type="number" min={10} max={25} value={form.age} onChange={(e) => setForm({ ...form, age: e.target.value })} required />
            </div>
            <div>
              <label className="label">State</label>
              <select className="input" value={form.state} onChange={(e) => setForm({ ...form, state: e.target.value })} required>
                <option value="">— select —</option>
                {STATES.map((s) => <option key={s} value={s}>{s}</option>)}
              </select>
            </div>
          </div>
          <div>
            <label className="label">Phone / WhatsApp number</label>
            <input className="input" type="tel" placeholder="e.g. 0123456789" value={form.whatsapp} onChange={(e) => setForm({ ...form, whatsapp: e.target.value })} required />
            <p className="mt-1 text-xs text-slate-400">We&apos;ll add you to the pilot WhatsApp group to share feedback &amp; updates.</p>
          </div>
          <div>
            <label className="label">Email (this is your login)</label>
            <input className="input" type="email" autoComplete="username" value={form.email} onChange={(e) => setForm({ ...form, email: e.target.value })} required />
          </div>
          <div>
            <label className="label">Form</label>
            <select className="input" value={form.form} onChange={(e) => setForm({ ...form, form: e.target.value })}>
              <option value="4">Tingkatan 4</option>
              <option value="5">Tingkatan 5</option>
            </select>
          </div>
          <div className="grid grid-cols-2 gap-3">
            <div>
              <label className="label">Password</label>
              <input className="input" type="password" autoComplete="new-password" value={form.password} onChange={(e) => setForm({ ...form, password: e.target.value })} required minLength={6} />
            </div>
            <div>
              <label className="label">Confirm</label>
              <input className="input" type="password" autoComplete="new-password" value={form.confirm} onChange={(e) => setForm({ ...form, confirm: e.target.value })} required minLength={6} />
            </div>
          </div>
          <div>
            <label className="label">Subjects you&apos;re taking</label>
            <div className="flex flex-wrap gap-2">
              {subjects.map((s) => (
                <button
                  type="button"
                  key={s.id}
                  onClick={() => toggle(s.id)}
                  className={`badge border px-3 py-1.5 ${picked.has(s.id) ? "border-brand-300 bg-brand-50 text-brand-700" : "border-slate-200 bg-white text-slate-500"}`}
                >
                  {picked.has(s.id) ? "✓ " : ""}{s.name}
                </button>
              ))}
            </div>
          </div>
          <label className="flex items-start gap-2 rounded-xl bg-slate-50 p-3 text-xs text-slate-600">
            <input type="checkbox" checked={consent} onChange={(e) => setConsent(e.target.checked)} className="mt-0.5 h-4 w-4" required />
            <span>
              I have read and agree to the{" "}
              <Link href="/privacy" target="_blank" className="font-semibold text-brand-600 hover:underline">Privacy Policy &amp; PDPA notice</Link>{" "}
              and the <Link href="/terms" target="_blank" className="font-semibold text-brand-600 hover:underline">Terms of Use</Link>. Under the
              Personal Data Protection Act 2010 (Malaysia), I consent to SPM AI <strong>collecting, storing and processing</strong> my
              personal data and all my activity (answers, attempts, scores, time and usage), and to it being used to
              <strong> analyse my learning, behaviour and performance</strong> (including learning analytics and psychometric/aptitude
              analysis) to improve the service. I understand that all platform content and any insights or data derived from my
              usage <strong>belong to SPM AI (all rights reserved)</strong>, and I agree to be added to the pilot WhatsApp group.
              If I am under 18, I confirm my parent or guardian agrees to the above.
            </span>
          </label>
          {error && <p className="text-sm text-red-600">{error}</p>}
          <button className="btn-primary w-full" disabled={loading || !consent}>
            {loading ? "Creating your account…" : "Create account & start"}
          </button>
          <p className="text-center text-sm text-slate-500">
            Already have an account? <Link href="/login" className="font-semibold text-brand-600 hover:underline">Sign in</Link>
          </p>
        </form>
      </div>
    </div>
  );
}
