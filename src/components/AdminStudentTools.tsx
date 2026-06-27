"use client";

import { useState } from "react";
import Icon from "./Icon";

// Admin sets a new password for a student (no email needed).
export default function AdminStudentTools({ studentId }: { studentId: string }) {
  const [pw, setPw] = useState("");
  const [msg, setMsg] = useState<string | null>(null);
  const [ok, setOk] = useState(false);
  const [busy, setBusy] = useState(false);

  async function reset() {
    setBusy(true);
    setMsg(null);
    const res = await fetch(`/api/admin/students/${studentId}/password`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ password: pw }),
    });
    const data = await res.json().catch(() => ({}));
    setBusy(false);
    setOk(res.ok);
    setMsg(res.ok ? "Password updated, share it with the student." : data.error || "Failed");
    if (res.ok) setPw("");
  }

  return (
    <div className="flex flex-wrap items-end gap-2">
      <div>
        <label className="label">Set a new password for this student</label>
        <input className="input w-56" type="text" value={pw} onChange={(e) => setPw(e.target.value)} placeholder="min 6 chars" />
      </div>
      <button onClick={reset} disabled={busy || pw.length < 6} className="btn-ghost">
        {busy ? "Saving…" : "Reset password"}
      </button>
      {msg && (
        <span className="inline-flex items-center gap-1 text-sm text-slate-600">
          {ok && <Icon name="check" className="h-4 w-4 text-emerald-600" />}
          {msg}
        </span>
      )}
    </div>
  );
}
