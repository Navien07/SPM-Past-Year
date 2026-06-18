"use client";

import { useState } from "react";
import Link from "next/link";

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
          <p className="text-center text-sm text-slate-500">
            New here? <Link href="/signup" className="font-semibold text-brand-600 hover:underline">Create an account</Link>
          </p>
        </form>
      </div>
    </div>
  );
}
