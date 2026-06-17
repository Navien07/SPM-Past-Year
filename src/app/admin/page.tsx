import Link from "next/link";
import { prisma } from "@/lib/db";
import { aiEnabled } from "@/lib/ai";

export const dynamic = "force-dynamic";

function rm(n: number) {
  return "RM " + n.toLocaleString("en-MY", { minimumFractionDigits: 2, maximumFractionDigits: 2 });
}

export default async function AdminOverview() {
  const [students, enrollments, paidAgg, pendingMod, papers, approvedQ, attempts, recentPayments] = await Promise.all([
    prisma.student.count(),
    prisma.enrollment.count({ where: { status: "active" } }),
    prisma.payment.aggregate({ _sum: { amount: true }, where: { status: "paid" } }),
    prisma.question.count({ where: { status: "pending" } }),
    prisma.paper.count(),
    prisma.question.count({ where: { status: "approved" } }),
    prisma.attempt.count(),
    prisma.payment.findMany({ orderBy: { paidAt: "desc" }, take: 5, include: { student: true } }),
  ]);

  const revenue = paidAgg._sum.amount ?? 0;

  const kpis = [
    { label: "Students", value: students, href: "/admin/students" },
    { label: "Active enrollments", value: enrollments },
    { label: "Revenue (paid)", value: rm(revenue) },
    { label: "Pending moderation", value: pendingMod, href: "/moderate", alert: pendingMod > 0 },
    { label: "Papers uploaded", value: papers, href: "/admin/papers" },
    { label: "Approved questions", value: approvedQ },
    { label: "Total attempts", value: attempts },
    { label: "AI", value: aiEnabled() ? "Live" : "Offline" },
  ];

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold">Admin Overview 📈</h1>
        <p className="text-sm text-slate-500">Students, revenue, content and moderation at a glance.</p>
      </div>

      <section className="grid grid-cols-2 gap-3 sm:grid-cols-4">
        {kpis.map((k) => {
          const card = (
            <div className={`card p-4 ${k.alert ? "border-amber-300 bg-amber-50" : ""}`}>
              <div className="text-2xl font-bold text-brand-700">{k.value}</div>
              <div className="mt-1 text-xs text-slate-500">{k.label}</div>
            </div>
          );
          return k.href ? <Link key={k.label} href={k.href}>{card}</Link> : <div key={k.label}>{card}</div>;
        })}
      </section>

      <div className="grid gap-4 lg:grid-cols-2">
        <section className="card p-5">
          <div className="mb-3 flex items-center justify-between">
            <h2 className="font-bold">Recent payments</h2>
            <Link href="/admin/students" className="text-sm text-brand-600 hover:underline">All students →</Link>
          </div>
          <div className="divide-y divide-slate-100">
            {recentPayments.length === 0 && <p className="text-sm text-slate-400">No payments yet.</p>}
            {recentPayments.map((p) => (
              <div key={p.id} className="flex items-center justify-between py-2 text-sm">
                <div>
                  <Link href={`/admin/students/${p.studentId}`} className="font-medium hover:text-brand-700">{p.student.name}</Link>
                  <div className="text-xs text-slate-400">{p.description} · {p.method}</div>
                </div>
                <div className="text-right">
                  <div className="font-semibold">{rm(p.amount)}</div>
                  <span className={`badge ${p.status === "paid" ? "bg-emerald-100 text-emerald-700" : "bg-amber-100 text-amber-700"}`}>{p.status}</span>
                </div>
              </div>
            ))}
          </div>
        </section>

        <section className="card p-5">
          <h2 className="mb-3 font-bold">Quick actions</h2>
          <div className="space-y-2">
            <Link href="/admin/papers" className="btn-ghost w-full justify-start">🗂️ Upload & categorize papers</Link>
            <Link href="/moderate" className="btn-ghost w-full justify-start">
              ✅ Review AI categorization {pendingMod > 0 && <span className="tag-kbat ml-2">{pendingMod} pending</span>}
            </Link>
            <Link href="/admin/students" className="btn-ghost w-full justify-start">👥 View students & performance</Link>
          </div>
        </section>
      </div>
    </div>
  );
}
