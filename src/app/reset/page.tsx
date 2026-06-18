"use client";

import { Suspense, useState } from "react";
import Link from "next/link";
import { useSearchParams } from "next/navigation";

function ResetForm() {
  const token = useSearchParams().get("token") || "";
  const [password, setPassword] = useState("");
  const [confirm, setConfirm] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [done, setDone] = useState(false);
  const [loading, setLoading] = useState(false);

  async function submit(e: React.FormEvent) {
    e.preventDefault();
    setError(null);
    if (password !== confirm) return setError("Passwords don't match.");
    setLoading(true);
    const res = await fetch("/api/auth/reset", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ token, password }),
    });
    const data = await res.json().catch(() => ({}));
    setLoading(false);
    if (!res.ok) return setError(data.error || "Reset failed");
    setDone(true);
  }

  if (!token) {
    return <p className="text-sm text-red-600">Missing reset token. Please use the link from your email.</p>;
  }
  if (done) {
    return (
      <div className="space-y-3 text-sm text-slate-600">
        <p className="rounded-xl bg-emerald-50 p-3 text-emerald-800">Password updated! You can now sign in.</p>
        <Link href="/login" className="btn-primary">Sign in</Link>
      </div>
    );
  }
  return (
    <form onSubmit={submit} className="space-y-4">
      <div>
        <label className="label">New password</label>
        <input className="input" type="password" value={password} onChange={(e) => setPassword(e.target.value)} required minLength={6} />
      </div>
      <div>
        <label className="label">Confirm new password</label>
        <input className="input" type="password" value={confirm} onChange={(e) => setConfirm(e.target.value)} required minLength={6} />
      </div>
      {error && <p className="text-sm text-red-600">{error}</p>}
      <button className="btn-primary w-full" disabled={loading}>{loading ? "Saving…" : "Set new password"}</button>
    </form>
  );
}

export default function ResetPage() {
  return (
    <div className="mx-auto max-w-md py-6">
      <div className="card p-6">
        <h1 className="mb-4 text-xl font-bold">Reset your password</h1>
        <Suspense fallback={<p className="text-sm text-slate-400">Loading…</p>}>
          <ResetForm />
        </Suspense>
      </div>
    </div>
  );
}
