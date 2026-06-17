"use client";

import { useState } from "react";

const DEMO = [
  { role: "Admin", email: "admin@spm.my", password: "admin123" },
  { role: "Student", email: "ahmad@student.spm.my", password: "student123" },
];

export default function LoginPage() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  async function submit(e: React.FormEvent) {
    e.preventDefault();
    setLoading(true);
    setError(null);
    try {
      const res = await fetch("/api/auth/login", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ email, password }),
      });
      const data = await res.json().catch(() => ({}));
      if (!res.ok) throw new Error(data.error || "Login failed");
      // Full-page navigation so the freshly-set session cookie is sent on the
      // next request (a soft client navigation can race the cookie).
      window.location.assign(data.redirect || "/");
    } catch (e) {
      setError(e instanceof Error ? e.message : "Login failed");
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="mx-auto max-w-md py-6">
      <div className="card overflow-hidden">
        <div className="bg-gradient-to-br from-brand-600 to-brand-800 p-6 text-white">
          <div className="flex items-center gap-2">
            <span className="grid h-9 w-9 place-items-center rounded-lg bg-white/20 font-bold">SP</span>
            <div>
              <div className="text-lg font-bold">SPM AI</div>
              <div className="text-xs text-brand-100">Sign in to continue</div>
            </div>
          </div>
        </div>
        <form onSubmit={submit} className="space-y-4 p-6">
          <div>
            <label className="label">Email</label>
            <input className="input" type="email" value={email} onChange={(e) => setEmail(e.target.value)} required autoComplete="username" />
          </div>
          <div>
            <label className="label">Password</label>
            <input className="input" type="password" value={password} onChange={(e) => setPassword(e.target.value)} required autoComplete="current-password" />
          </div>
          {error && <p className="text-sm text-red-600">{error}</p>}
          <button className="btn-primary w-full" disabled={loading}>
            {loading ? "Signing in…" : "Sign in"}
          </button>
        </form>
      </div>

      <div className="card mt-4 p-4">
        <p className="mb-2 text-xs font-semibold uppercase tracking-wide text-slate-500">Demo accounts (tap to fill)</p>
        <div className="space-y-2">
          {DEMO.map((d) => (
            <button
              key={d.email}
              onClick={() => {
                setEmail(d.email);
                setPassword(d.password);
              }}
              className="flex w-full items-center justify-between rounded-lg border border-slate-200 px-3 py-2 text-left text-sm hover:bg-slate-50"
            >
              <span className="font-medium">{d.role}</span>
              <span className="text-xs text-slate-500">{d.email} · {d.password}</span>
            </button>
          ))}
        </div>
      </div>
    </div>
  );
}
