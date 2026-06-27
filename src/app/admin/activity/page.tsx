import Link from "next/link";
import { prisma } from "@/lib/db";

export const dynamic = "force-dynamic";

const ACTION_LABEL: Record<string, string> = {
  login: "Signed in",
  "login.failed": "Failed sign-in",
  signup: "Signed up",
  logout: "Signed out",
  "attempt.graded": "Answered a question",
  "questions.generate": "Generated questions",
  "chat.message": "Asked Cikgu AI",
  "bookmark.toggle": "Bookmarked",
  "paper.create": "Uploaded a paper",
  "paper.categorize": "Categorized a paper",
  "moderation.review": "Reviewed a question",
  "knowledge.create": "Added knowledge",
  "password.forgot": "Requested password reset",
  "password.reset": "Reset password",
  "admin.change_password": "Changed admin password",
  "admin.reset_student_password": "Reset a student password",
};

function timeAgo(d: Date) {
  const s = Math.floor((Date.now() - new Date(d).getTime()) / 1000);
  if (s < 60) return `${s}s ago`;
  if (s < 3600) return `${Math.floor(s / 60)}m ago`;
  if (s < 86400) return `${Math.floor(s / 3600)}h ago`;
  return `${Math.floor(s / 86400)}d ago`;
}

export default async function ActivityPage() {
  let logs: { id: string; name: string | null; role: string | null; action: string; detail: string | null; ip: string | null; createdAt: Date }[] = [];
  let total = 0;
  try {
    [logs, total] = await Promise.all([
      prisma.activityLog.findMany({ orderBy: { createdAt: "desc" }, take: 200 }),
      prisma.activityLog.count(),
    ]);
  } catch {
    return (
      <div className="card mx-auto max-w-xl p-8 text-center">
        <div className="text-4xl">🧾</div>
        <h1 className="mt-3 text-xl font-bold">Activity log not ready</h1>
        <p className="mt-2 text-sm text-slate-600">Run the latest <code className="rounded bg-slate-100 px-1">supabase_setup.sql</code> to create the ActivityLog table.</p>
      </div>
    );
  }

  return (
    <div className="space-y-5">
      <div>
        <h1 className="text-2xl font-bold">Activity log 🧾</h1>
        <p className="text-sm text-slate-500">Latest 200 of {total.toLocaleString()} events. Every key user action is traced.</p>
      </div>
      <div className="card overflow-x-auto">
        <table className="w-full text-sm">
          <thead className="border-b border-slate-200 bg-slate-50 text-left text-xs uppercase tracking-wide text-slate-500">
            <tr>
              <th className="px-4 py-3">When</th>
              <th className="px-4 py-3">User</th>
              <th className="px-4 py-3">Action</th>
              <th className="px-4 py-3">Detail</th>
              <th className="px-4 py-3">IP</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-100">
            {logs.map((l) => (
              <tr key={l.id} className="hover:bg-slate-50">
                <td className="whitespace-nowrap px-4 py-2 text-slate-500">{timeAgo(l.createdAt)}</td>
                <td className="px-4 py-2">
                  <span className="font-medium">{l.name ?? "-"}</span>
                  {l.role && <span className="ml-1 text-xs text-slate-400">({l.role})</span>}
                </td>
                <td className="px-4 py-2">
                  <span className={`badge ${l.action.includes("failed") ? "bg-red-100 text-red-700" : "bg-slate-100 text-slate-600"}`}>
                    {ACTION_LABEL[l.action] ?? l.action}
                  </span>
                </td>
                <td className="px-4 py-2 text-slate-500">{l.detail ?? ""}</td>
                <td className="px-4 py-2 text-xs text-slate-400">{l.ip ?? ""}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
      <Link href="/admin" className="text-sm text-brand-600 hover:underline">← Overview</Link>
    </div>
  );
}
