"use client";

import { useState } from "react";
import { MALAYSIA_STATES } from "@/lib/constants";

// Public waitlist capture. Used on the landing page (and emphasised when the
// free pilot is full). Plain-language errors, disabled-while-sending button.
export default function WaitlistForm({ full }: { full: boolean }) {
  const [form, setForm] = useState({ name: "", email: "", whatsapp: "", school: "", state: "" });
  const [status, setStatus] = useState<"idle" | "sending" | "done" | "error">("idle");
  const [message, setMessage] = useState("");

  function set<K extends keyof typeof form>(k: K, v: string) {
    setForm((f) => ({ ...f, [k]: v }));
  }

  async function submit(e: React.FormEvent) {
    e.preventDefault();
    setStatus("sending");
    setMessage("");
    try {
      const res = await fetch("/api/waitlist", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(form),
      });
      const data = await res.json();
      if (!res.ok) {
        setStatus("error");
        setMessage(data.error || "Couldn't save your spot. Please try again.");
        return;
      }
      setStatus("done");
      setMessage(data.position ? `You're #${data.position} on the list.` : "");
    } catch {
      setStatus("error");
      setMessage("Network error, please try again.");
    }
  }

  if (status === "done") {
    return (
      <div className="rounded-2xl border border-emerald-200 bg-emerald-50 p-6 text-center">
        <div className="mx-auto grid h-12 w-12 place-items-center rounded-full bg-emerald-500 text-white">
          <svg viewBox="0 0 24 24" className="h-6 w-6" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" aria-hidden="true"><path d="M20 6 9 17l-5-5" /></svg>
        </div>
        <h3 className="font-display mt-3 text-lg font-bold text-emerald-900">You&apos;re on the list! 🎉</h3>
        <p className="mt-1 text-sm text-emerald-800">
          {message} We&apos;ll WhatsApp you the moment a spot opens up. Terima kasih!
        </p>
      </div>
    );
  }

  return (
    <form onSubmit={submit} className="space-y-3">
      <div className="grid gap-3 sm:grid-cols-2">
        <div>
          <label htmlFor="wl-name" className="label">Full name</label>
          <input id="wl-name" required value={form.name} onChange={(e) => set("name", e.target.value)} className="input" placeholder="Nurul / Vikhash" autoComplete="name" />
        </div>
        <div>
          <label htmlFor="wl-email" className="label">Email</label>
          <input id="wl-email" type="email" required value={form.email} onChange={(e) => set("email", e.target.value)} className="input" placeholder="you@email.com" autoComplete="email" />
        </div>
        <div>
          <label htmlFor="wl-wa" className="label">WhatsApp <span className="font-normal normal-case text-slate-400">(optional)</span></label>
          <input id="wl-wa" value={form.whatsapp} onChange={(e) => set("whatsapp", e.target.value)} className="input" placeholder="0123456789" inputMode="tel" autoComplete="tel" />
        </div>
        <div>
          <label htmlFor="wl-state" className="label">State <span className="font-normal normal-case text-slate-400">(optional)</span></label>
          <select id="wl-state" value={form.state} onChange={(e) => set("state", e.target.value)} className="input">
            <option value="">pilih</option>
            {MALAYSIA_STATES.map((s) => (
              <option key={s} value={s}>{s}</option>
            ))}
          </select>
        </div>
      </div>
      <div>
        <label htmlFor="wl-school" className="label">School <span className="font-normal normal-case text-slate-400">(optional)</span></label>
        <input id="wl-school" value={form.school} onChange={(e) => set("school", e.target.value)} className="input" placeholder="SMK …" autoComplete="organization" />
      </div>
      {status === "error" && <p className="text-sm font-medium text-red-600">{message}</p>}
      <button type="submit" disabled={status === "sending"} className="btn-primary w-full cursor-pointer">
        {status === "sending" ? "Saving…" : full ? "Join the waitlist" : "Notify me about new spots"}
      </button>
      <p className="text-center text-xs text-slate-500">
        We only use this to invite you. No spam, ever.
      </p>
    </form>
  );
}
