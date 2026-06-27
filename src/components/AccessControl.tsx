"use client";

import { useState } from "react";

// Admin control to set a student's access: sponsor (free for underprivileged
// students), comp paid months, reset trial, or revoke.
export default function AccessControl({
  studentId,
  accessType,
  accessUntil,
  trialEndsAt,
}: {
  studentId: string;
  accessType: string;
  accessUntil: string | null;
  trialEndsAt: string | null;
}) {
  const [busy, setBusy] = useState(false);
  const [current, setCurrent] = useState(accessType);
  const [msg, setMsg] = useState("");

  async function set(type: string, months?: number) {
    setBusy(true);
    setMsg("");
    const res = await fetch("/api/admin/grant-access", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ studentId, accessType: type, months }),
    });
    setBusy(false);
    if (res.ok) {
      setCurrent(type);
      setMsg("Updated.");
    } else {
      const d = await res.json().catch(() => ({}));
      setMsg(d.error || "Failed.");
    }
  }

  const until = accessUntil ? new Date(accessUntil) : null;
  const trial = trialEndsAt ? new Date(trialEndsAt) : null;
  const badge =
    current === "sponsored" ? "bg-violet-100 text-violet-700"
    : current === "pilot" ? "bg-emerald-100 text-emerald-700"
    : current === "paid" ? "bg-blue-100 text-blue-700"
    : current === "trial" ? "bg-amber-100 text-amber-700"
    : "bg-slate-100 text-slate-600";

  return (
    <section className="card p-5">
      <h2 className="mb-3 font-bold">Access</h2>
      <div className="flex flex-wrap items-center gap-2 text-sm">
        <span className={`badge ${badge}`}>{current}</span>
        {current === "paid" && until && <span className="text-xs text-slate-500">until {until.toLocaleDateString("en-MY")}</span>}
        {current === "trial" && trial && <span className="text-xs text-slate-500">trial ends {trial.toLocaleDateString("en-MY")}</span>}
      </div>
      <div className="mt-3 flex flex-wrap gap-2">
        <button onClick={() => set("sponsored")} disabled={busy} className="rounded-lg bg-violet-600 px-3 py-1.5 text-xs font-semibold text-white hover:bg-violet-700 disabled:opacity-60 cursor-pointer">Sponsor (free)</button>
        <button onClick={() => set("paid", 12)} disabled={busy} className="rounded-lg bg-blue-600 px-3 py-1.5 text-xs font-semibold text-white hover:bg-blue-700 disabled:opacity-60 cursor-pointer">Comp 1 year</button>
        <button onClick={() => set("trial")} disabled={busy} className="rounded-lg border border-slate-200 px-3 py-1.5 text-xs font-semibold text-slate-700 hover:bg-slate-50 disabled:opacity-60 cursor-pointer">Reset trial</button>
        <button onClick={() => set("expired")} disabled={busy} className="rounded-lg px-3 py-1.5 text-xs font-semibold text-red-600 hover:underline disabled:opacity-60 cursor-pointer">Revoke</button>
      </div>
      {msg && <p className="mt-2 text-xs font-medium text-slate-500">{msg}</p>}
      <p className="mt-2 text-[11px] text-slate-400">Sponsor underprivileged students with free unlimited access.</p>
    </section>
  );
}
