"use client";

import { useState } from "react";

// Admin: broadcast a push notification to every subscribed device.
export default function NotifyPage() {
  const [form, setForm] = useState({ title: "SPM AI", body: "", url: "/" });
  const [busy, setBusy] = useState(false);
  const [msg, setMsg] = useState<string | null>(null);

  async function send(e: React.FormEvent) {
    e.preventDefault();
    setBusy(true);
    setMsg(null);
    try {
      const res = await fetch("/api/admin/push", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(form),
      });
      const data = await res.json();
      if (!res.ok) setMsg(data.error || "Failed to send.");
      else setMsg(`Sent to ${data.sent} device(s)${data.failed ? `, ${data.failed} failed/expired` : ""}.`);
    } finally {
      setBusy(false);
    }
  }

  const presets = [
    { title: "Jom latih hari ini! 📚", body: "5 soalan sehari cukup untuk kekalkan streak anda." },
    { title: "Kertas baharu ditambah ✨", body: "Soalan SPM baharu tersedia. Cuba sekarang!" },
    { title: "SPM makin dekat ⏰", body: "Buat satu peperiksaan bermasa hari ini untuk uji diri." },
  ];

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold">Send notification 🔔</h1>
        <p className="text-sm text-slate-500">Push a message to every student who turned on notifications.</p>
      </div>

      {msg && <div className="rounded-xl border border-brand-200 bg-brand-50 p-3 text-sm text-brand-800">{msg}</div>}

      <form onSubmit={send} className="card space-y-4 p-5">
        <div>
          <label className="label">Title</label>
          <input className="input" maxLength={80} required value={form.title} onChange={(e) => setForm({ ...form, title: e.target.value })} />
        </div>
        <div>
          <label className="label">Message</label>
          <textarea className="input resize-y" rows={3} maxLength={240} required value={form.body} onChange={(e) => setForm({ ...form, body: e.target.value })} placeholder="Tulis mesej…" />
        </div>
        <div>
          <label className="label">Open URL when tapped</label>
          <input className="input" value={form.url} onChange={(e) => setForm({ ...form, url: e.target.value })} placeholder="/practice" />
        </div>
        <div className="flex flex-wrap gap-2">
          {presets.map((p) => (
            <button key={p.title} type="button" onClick={() => setForm({ ...form, title: p.title, body: p.body })} className="cursor-pointer rounded-full border border-slate-200 px-3 py-1 text-xs text-slate-600 hover:bg-slate-50">
              {p.title}
            </button>
          ))}
        </div>
        <button type="submit" disabled={busy} className="btn-primary cursor-pointer">{busy ? "Sending…" : "Send to all"}</button>
      </form>

      <p className="text-xs text-slate-400">
        Requires the <code className="rounded bg-slate-100 px-1">VAPID_PUBLIC_KEY</code>,{" "}
        <code className="rounded bg-slate-100 px-1">VAPID_PRIVATE_KEY</code> and{" "}
        <code className="rounded bg-slate-100 px-1">NEXT_PUBLIC_VAPID_PUBLIC_KEY</code> env vars to be set.
      </p>
    </div>
  );
}
