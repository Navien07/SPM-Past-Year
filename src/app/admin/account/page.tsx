"use client";

import { useState } from "react";

export default function AdminAccountPage() {
  const [cur, setCur] = useState("");
  const [next, setNext] = useState("");
  const [confirm, setConfirm] = useState("");
  const [msg, setMsg] = useState<string | null>(null);
  const [err, setErr] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  async function submit(e: React.FormEvent) {
    e.preventDefault();
    setMsg(null);
    setErr(null);
    if (next !== confirm) return setErr("New passwords don't match.");
    setLoading(true);
    const res = await fetch("/api/admin/change-password", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ currentPassword: cur, newPassword: next }),
    });
    const data = await res.json().catch(() => ({}));
    setLoading(false);
    if (!res.ok) return setErr(data.error || "Failed");
    setMsg("Password updated.");
    setCur(""); setNext(""); setConfirm("");
  }

  return (
    <div className="mx-auto max-w-md space-y-4">
      <div>
        <h1 className="text-2xl font-bold">Admin account 🔐</h1>
        <p className="text-sm text-slate-500">Change your administrator password.</p>
      </div>
      <form onSubmit={submit} className="card space-y-4 p-5">
        <div>
          <label className="label">Current password</label>
          <input className="input" type="password" value={cur} onChange={(e) => setCur(e.target.value)} required />
        </div>
        <div>
          <label className="label">New password (min 8 chars)</label>
          <input className="input" type="password" value={next} onChange={(e) => setNext(e.target.value)} required minLength={8} />
        </div>
        <div>
          <label className="label">Confirm new password</label>
          <input className="input" type="password" value={confirm} onChange={(e) => setConfirm(e.target.value)} required minLength={8} />
        </div>
        {msg && <p className="text-sm text-emerald-600">{msg}</p>}
        {err && <p className="text-sm text-red-600">{err}</p>}
        <button className="btn-primary" disabled={loading}>{loading ? "Saving…" : "Update password"}</button>
      </form>
    </div>
  );
}
