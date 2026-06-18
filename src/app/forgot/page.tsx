"use client";

import { useState } from "react";
import Link from "next/link";

export default function ForgotPage() {
  const [email, setEmail] = useState("");
  const [sent, setSent] = useState(false);
  const [loading, setLoading] = useState(false);

  async function submit(e: React.FormEvent) {
    e.preventDefault();
    setLoading(true);
    await fetch("/api/auth/forgot", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ email }),
    });
    setLoading(false);
    setSent(true);
  }

  return (
    <div className="mx-auto max-w-md py-6">
      <div className="card p-6">
        <h1 className="text-xl font-bold">Forgot your password?</h1>
        {sent ? (
          <div className="mt-4 space-y-3 text-sm text-slate-600">
            <p className="rounded-xl bg-emerald-50 p-3 text-emerald-800">
              If that email is registered, we&apos;ve sent a reset link. Check your inbox (and spam).
            </p>
            <p>The link is valid for 1 hour. Didn&apos;t get it? Ask your admin to reset it for you.</p>
            <Link href="/login" className="btn-ghost">Back to sign in</Link>
          </div>
        ) : (
          <form onSubmit={submit} className="mt-4 space-y-4">
            <p className="text-sm text-slate-500">Enter your email and we&apos;ll send a reset link.</p>
            <div>
              <label className="label">Email</label>
              <input className="input" type="email" value={email} onChange={(e) => setEmail(e.target.value)} required />
            </div>
            <button className="btn-primary w-full" disabled={loading}>{loading ? "Sending…" : "Send reset link"}</button>
            <p className="text-center text-sm text-slate-500">
              <Link href="/login" className="font-semibold text-brand-600 hover:underline">Back to sign in</Link>
            </p>
          </form>
        )}
      </div>
    </div>
  );
}
