"use client";

import { useState } from "react";
import Icon from "./Icon";
import type { Plan } from "@/lib/access";

// Plan cards used on the paywall. Clicking a plan starts Billplz checkout and
// redirects to the hosted payment page.
export default function PlanPicker({ plans }: { plans: Plan[] }) {
  const [busy, setBusy] = useState<string | null>(null);
  const [error, setError] = useState("");

  async function choose(plan: string) {
    setBusy(plan);
    setError("");
    try {
      const res = await fetch("/api/billing/checkout", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ plan }),
      });
      const data = await res.json();
      if (!res.ok || !data.url) {
        setError(data.error || "Couldn't start checkout. Please try again.");
        setBusy(null);
        return;
      }
      window.location.href = data.url;
    } catch {
      setError("Network error, please try again.");
      setBusy(null);
    }
  }

  async function signOut() {
    await fetch("/api/auth/logout", { method: "POST" });
    window.location.href = "/login";
  }

  return (
    <div className="space-y-4">
      <div className="grid gap-4 sm:grid-cols-2">
        {plans.map((p, i) => {
          const best = i === 0;
          return (
            <div key={p.id} className={`card relative p-5 ${best ? "border-brand-300 ring-2 ring-brand-200" : ""}`}>
              {best && <span className="absolute -top-2.5 left-5 rounded-full bg-brand-600 px-2.5 py-0.5 text-xs font-bold text-white">Best value</span>}
              <h3 className="font-display text-lg font-bold">{p.label}</h3>
              <div className="mt-1 flex items-baseline gap-1">
                <span className="text-3xl font-extrabold">{p.priceLabel}</span>
                <span className="text-sm text-slate-500">/{p.id === "annual" ? "year" : "month"}</span>
              </div>
              <p className="mt-1 text-sm text-slate-600">{p.blurb}</p>
              <button
                onClick={() => choose(p.id)}
                disabled={!!busy}
                className={`mt-4 inline-flex w-full items-center justify-center gap-1.5 rounded-xl py-2.5 text-sm font-bold transition cursor-pointer ${
                  best ? "bg-brand-600 text-white hover:bg-brand-700" : "border border-slate-200 text-slate-700 hover:bg-slate-50"
                } disabled:opacity-60`}
              >
                {busy === p.id ? "Starting…" : <>Subscribe <Icon name="arrow" className="h-4 w-4" /></>}
              </button>
            </div>
          );
        })}
      </div>
      {error && <p className="text-center text-sm font-medium text-red-600">{error}</p>}
      <div className="text-center">
        <button onClick={signOut} className="text-sm text-slate-500 hover:underline cursor-pointer">Sign out</button>
      </div>
    </div>
  );
}
