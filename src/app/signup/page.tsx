"use client";

import { useEffect, useState } from "react";
import Link from "next/link";

interface Subject { id: string; name: string }

export default function SignupPage() {
  const [subjects, setSubjects] = useState<Subject[]>([]);
  const [picked, setPicked] = useState<Set<string>>(new Set());
  const [form, setForm] = useState({ name: "", email: "", whatsapp: "", form: "5", password: "", confirm: "" });
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
            <label className="label">Email (this is your login)</label>
            <input className="input" type="email" autoComplete="username" value={form.email} onChange={(e) => setForm({ ...form, email: e.target.value })} required />
          </div>
          <div>
            <label className="label">WhatsApp number</label>
            <input className="input" type="tel" placeholder="e.g. 0123456789" value={form.whatsapp} onChange={(e) => setForm({ ...form, whatsapp: e.target.value })} required />
            <p className="mt-1 text-xs text-slate-400">We&apos;ll add you to the pilot WhatsApp group to share feedback &amp; updates.</p>
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
              <Link href="/privacy" target="_blank" className="font-semibold text-brand-600 hover:underline">Privacy Policy &amp; PDPA notice</Link>.
              I consent to SPM AI processing my personal data (incl. my WhatsApp number) under the
              Personal Data Protection Act 2010 and to being added to the pilot WhatsApp feedback group.
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
