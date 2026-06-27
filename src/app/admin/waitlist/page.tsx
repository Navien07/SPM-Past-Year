"use client";

import { useEffect, useState } from "react";

interface Row {
  id: string;
  name: string;
  email: string;
  whatsapp: string | null;
  school: string | null;
  state: string | null;
  invited: boolean;
  createdAt: string;
}

export default function WaitlistPage() {
  const [rows, setRows] = useState<Row[]>([]);
  const [loading, setLoading] = useState(true);

  async function load() {
    setLoading(true);
    const res = await fetch("/api/admin/waitlist");
    setRows(res.ok ? await res.json() : []);
    setLoading(false);
  }
  useEffect(() => { load(); }, []);

  async function toggle(r: Row) {
    setRows((rs) => rs.map((x) => (x.id === r.id ? { ...x, invited: !x.invited } : x)));
    await fetch("/api/admin/waitlist", {
      method: "PATCH",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ id: r.id, invited: !r.invited }),
    });
  }

  function exportCsv() {
    const head = ["Name", "Email", "WhatsApp", "School", "State", "Invited", "Joined"];
    const lines = rows.map((r) =>
      [r.name, r.email, r.whatsapp ?? "", r.school ?? "", r.state ?? "", r.invited ? "yes" : "no", new Date(r.createdAt).toISOString()]
        .map((c) => `"${String(c).replace(/"/g, '""')}"`)
        .join(","),
    );
    const csv = [head.join(","), ...lines].join("\n");
    const url = URL.createObjectURL(new Blob([csv], { type: "text/csv" }));
    const a = document.createElement("a");
    a.href = url;
    a.download = `spm-ai-waitlist-${new Date().toISOString().slice(0, 10)}.csv`;
    a.click();
    URL.revokeObjectURL(url);
  }

  const pending = rows.filter((r) => !r.invited).length;

  return (
    <div className="space-y-5">
      <div className="flex flex-wrap items-end justify-between gap-3">
        <div>
          <h1 className="text-2xl font-bold">Waitlist 📝</h1>
          <p className="text-sm text-slate-500">{rows.length} signups · {pending} not yet invited.</p>
        </div>
        <button onClick={exportCsv} disabled={rows.length === 0} className="btn-ghost cursor-pointer">⬇ Export CSV</button>
      </div>

      <div className="card overflow-x-auto">
        <table className="w-full text-sm">
          <thead className="border-b border-slate-200 bg-slate-50 text-left text-xs uppercase tracking-wide text-slate-500">
            <tr>
              <th className="px-4 py-3">Name</th>
              <th className="px-4 py-3">Email</th>
              <th className="px-4 py-3">WhatsApp</th>
              <th className="px-4 py-3">School</th>
              <th className="px-4 py-3">State</th>
              <th className="px-4 py-3">Joined</th>
              <th className="px-4 py-3">Invited</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-100">
            {loading && <tr><td colSpan={7} className="px-4 py-6 text-center text-slate-400">Loading…</td></tr>}
            {!loading && rows.length === 0 && <tr><td colSpan={7} className="px-4 py-6 text-center text-slate-400">No signups yet.</td></tr>}
            {rows.map((r) => (
              <tr key={r.id} className="hover:bg-slate-50">
                <td className="px-4 py-3 font-medium">{r.name}</td>
                <td className="px-4 py-3 text-slate-600">{r.email}</td>
                <td className="px-4 py-3 text-slate-600">{r.whatsapp ?? "-"}</td>
                <td className="px-4 py-3 text-slate-600">{r.school ?? "-"}</td>
                <td className="px-4 py-3 text-slate-600">{r.state ?? "-"}</td>
                <td className="px-4 py-3 text-xs text-slate-400">{new Date(r.createdAt).toLocaleDateString("en-MY")}</td>
                <td className="px-4 py-3">
                  <button
                    onClick={() => toggle(r)}
                    className={`badge cursor-pointer ${r.invited ? "bg-accent-100 text-accent-700" : "bg-slate-100 text-slate-500 hover:bg-slate-200"}`}
                  >
                    {r.invited ? "✓ Invited" : "Mark invited"}
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
