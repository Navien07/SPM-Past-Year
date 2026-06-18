import Link from "next/link";
import { prisma } from "@/lib/db";

export const dynamic = "force-dynamic";

function rm(n: number) {
  return "RM " + n.toLocaleString("en-MY", { minimumFractionDigits: 2, maximumFractionDigits: 2 });
}

export default async function StudentsPage() {
  const students = await prisma.student.findMany({
    orderBy: { createdAt: "asc" },
    include: {
      attempts: { select: { score: true, maxScore: true } },
      enrollments: { select: { id: true } },
      payments: { where: { status: "paid" }, select: { amount: true } },
    },
  });

  const rows = students.map((s) => {
    const n = s.attempts.length;
    const avg = n === 0 ? 0 : Math.round((s.attempts.reduce((a, x) => a + (x.maxScore ? x.score / x.maxScore : 0), 0) / n) * 100);
    const paid = s.payments.reduce((a, p) => a + p.amount, 0);
    return { id: s.id, name: s.name, email: s.email, form: s.form, subjects: s.enrollments.length, attempts: n, avg, paid };
  });

  return (
    <div className="space-y-5">
      <div className="flex items-end justify-between gap-3">
        <div>
          <h1 className="text-2xl font-bold">Students 👥</h1>
          <p className="text-sm text-slate-500">{rows.length} students · click a row for full performance & payments.</p>
        </div>
        <div className="flex shrink-0 gap-2">
          <Link href="/admin/waitlist" className="btn-ghost">📝 Waitlist</Link>
          <Link href="/admin/students/new" className="btn-primary">＋ Add student</Link>
        </div>
      </div>

      <div className="card overflow-x-auto">
        <table className="w-full text-sm">
          <thead className="border-b border-slate-200 bg-slate-50 text-left text-xs uppercase tracking-wide text-slate-500">
            <tr>
              <th className="px-4 py-3">Student</th>
              <th className="px-4 py-3">Form</th>
              <th className="px-4 py-3">Subjects</th>
              <th className="px-4 py-3">Attempts</th>
              <th className="px-4 py-3">Avg score</th>
              <th className="px-4 py-3">Paid</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-100">
            {rows.map((r) => (
              <tr key={r.id} className="hover:bg-slate-50">
                <td className="px-4 py-3">
                  <Link href={`/admin/students/${r.id}`} className="font-medium text-brand-700 hover:underline">{r.name}</Link>
                  <div className="text-xs text-slate-400">{r.email}</div>
                </td>
                <td className="px-4 py-3">T{r.form}</td>
                <td className="px-4 py-3">{r.subjects}</td>
                <td className="px-4 py-3">{r.attempts}</td>
                <td className="px-4 py-3">
                  <span className={`badge ${r.avg >= 70 ? "bg-emerald-100 text-emerald-700" : r.avg >= 40 ? "bg-amber-100 text-amber-700" : "bg-red-100 text-red-700"}`}>{r.avg}%</span>
                </td>
                <td className="px-4 py-3 font-medium">{rm(r.paid)}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
