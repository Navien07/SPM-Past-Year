"use client";

import { useState } from "react";

// Admin: run a live AI key check (real ping) and show whether the live
// Anthropic key actually works, catches "key set but out of credit".
export default function AiStatusButton() {
  const [state, setState] = useState<"idle" | "checking" | "ok" | "fail">("idle");
  const [detail, setDetail] = useState("");

  async function check() {
    setState("checking");
    setDetail("");
    try {
      const res = await fetch("/api/admin/ai-check");
      const d = await res.json();
      if (d.ok) { setState("ok"); setDetail(`Model: ${d.model}`); }
      else { setState("fail"); setDetail(d.detail || `status ${d.status ?? "?"}`); }
    } catch {
      setState("fail");
      setDetail("Network error");
    }
  }

  return (
    <div className="card flex flex-wrap items-center justify-between gap-3 p-4">
      <div>
        <p className="font-semibold">Live AI status</p>
        <p className="text-xs text-slate-500">
          {state === "idle" && "Checks the live Anthropic key actually works (grading, tutor, Cikgu AI, generator)."}
          {state === "checking" && "Pinging Anthropic…"}
          {state === "ok" && <span className="text-emerald-700">✅ AI is working. {detail}</span>}
          {state === "fail" && <span className="text-red-600">❌ AI not working, {detail}</span>}
        </p>
      </div>
      <button onClick={check} disabled={state === "checking"} className="btn-ghost cursor-pointer">
        {state === "checking" ? "Checking…" : "Test AI key"}
      </button>
    </div>
  );
}
