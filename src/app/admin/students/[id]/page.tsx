import Link from "next/link";
import { notFound } from "next/navigation";
import { prisma } from "@/lib/db";
import AdminStudentTools from "@/components/AdminStudentTools";
import Icon from "@/components/Icon";

export const dynamic = "force-dynamic";

function timeAgo(d: Date) {
  const s = Math.floor((Date.now() - new Date(d).getTime()) / 1000);
  if (s < 60) return `${s}s ago`;
  if (s < 3600) return `${Math.floor(s / 60)}m ago`;
  if (s < 86400) return `${Math.floor(s / 3600)}h ago`;
  return `${Math.floor(s / 86400)}d ago`;
}

function rm(n: number) {
  return "RM " + n.toLocaleString("en-MY", { minimumFractionDigits: 2, maximumFractionDigits: 2 });
}

export default async function StudentDetail({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  const student = await prisma.student.findUnique({
    where: { id },
    include: {
      enrollments: { include: { subject: true } },
      payments: { orderBy: { paidAt: "desc" } },
      attempts: {
        orderBy: { createdAt: "asc" },
        include: { question: { include: { subject: true, topic: true } } },
      },
    },
  });
  if (!student) notFound();

  const recentActivity = await prisma.activityLog.findMany({
    where: { studentId: id },
    orderBy: { createdAt: "desc" },
    take: 25,
  }).catch(() => []);

  const n = student.attempts.length;
  const avg = n === 0 ? 0 : Math.round((student.attempts.reduce((a, x) => a + (x.maxScore ? x.score / x.maxScore : 0), 0) / n) * 100);
  const paid = student.payments.filter((p) => p.status === "paid").reduce((a, p) => a + p.amount, 0);

  // Mastery per subject
  const bySubject = new Map<string, { name: string; sum: number; n: number }>();
  for (const a of student.attempts) {
    const name = a.question.subject.name;
    const cur = bySubject.get(name) ?? { name, sum: 0, n: 0 };
    cur.sum += a.maxScore ? (a.score / a.maxScore) * 100 : 0;
    cur.n += 1;
    bySubject.set(name, cur);
  }
  const mastery = [...bySubject.values()].map((s) => ({ name: s.name, pct: Math.round(s.sum / s.n) })).sort((a, b) => b.pct - a.pct);

  // Trend: rolling average over attempts (in order)
  const trend: { pct: number }[] = [];
  let run = 0;
  student.attempts.forEach((a, i) => {
    run += a.maxScore ? (a.score / a.maxScore) * 100 : 0;
    trend.push({ pct: Math.round(run / (i + 1)) });
  });

  const stats = [
    { label: "Attempts", value: n },
    { label: "Avg score", value: `${avg}%` },
    { label: "Subjects", value: student.enrollments.length },
    { label: "Total paid", value: rm(paid) },
  ];

  return (
    <div className="space-y-6">
      <Link href="/admin/students" className="inline-flex items-center gap-1 text-sm text-brand-600 hover:underline"><Icon name="arrow" className="h-4 w-4 rotate-180" /> All students</Link>

      <div className="card p-5">
        <h1 className="text-2xl font-bold">{student.name}</h1>
        <p className="text-sm text-slate-500">{student.email} · Tingkatan {student.form}</p>
        <p className="mt-0.5 text-sm text-slate-500">
          {[student.school, student.state, student.age ? `${student.age} yrs` : null].filter(Boolean).join(" · ") || "-"}
        </p>
        <div className="mt-2 flex flex-wrap items-center gap-2 text-xs">
          {student.whatsapp && (
            <a
              href={`https://wa.me/${student.whatsapp.replace(/[^0-9]/g, "")}`}
              target="_blank"
              className="badge inline-flex items-center gap-1 bg-emerald-100 text-emerald-700 hover:bg-emerald-200"
            >
              <Icon name="chat" className="h-3.5 w-3.5" /> {student.whatsapp}
            </a>
          )}
          <span className={`badge inline-flex items-center gap-1 ${student.pdpaConsent ? "bg-emerald-100 text-emerald-700" : "bg-slate-100 text-slate-500"}`}>
            {student.pdpaConsent ? <><Icon name="check" className="h-3.5 w-3.5" /> PDPA consent</> : "No consent on file"}
          </span>
        </div>
        <div className="mt-4 grid grid-cols-2 gap-3 sm:grid-cols-4">
          {stats.map((s) => (
            <div key={s.label} className="rounded-xl bg-slate-50 p-3 text-center">
              <div className="text-xl font-bold text-brand-700">{s.value}</div>
              <div className="text-xs text-slate-500">{s.label}</div>
            </div>
          ))}
        </div>
      </div>

      <div className="grid gap-4 lg:grid-cols-2">
        <section className="card p-5">
          <h2 className="mb-3 font-bold">Enrolled subjects</h2>
          <div className="flex flex-wrap gap-2">
            {student.enrollments.map((e) => (
              <span key={e.id} className="badge bg-brand-50 text-brand-700">{e.subject.name}</span>
            ))}
            {student.enrollments.length === 0 && <p className="text-sm text-slate-400">None.</p>}
          </div>
        </section>

        <section className="card p-5">
          <h2 className="mb-3 font-bold">Mastery by subject</h2>
          <div className="space-y-2">
            {mastery.map((m) => (
              <div key={m.name} className="flex items-center gap-3">
                <span className="w-28 truncate text-sm">{m.name}</span>
                <div className="h-2.5 flex-1 overflow-hidden rounded-full bg-slate-100">
                  <div className={`h-full ${m.pct >= 70 ? "bg-emerald-500" : m.pct >= 40 ? "bg-amber-500" : "bg-red-500"}`} style={{ width: `${m.pct}%` }} />
                </div>
                <span className="w-10 text-right text-sm font-semibold">{m.pct}%</span>
              </div>
            ))}
            {mastery.length === 0 && <p className="text-sm text-slate-400">No attempts yet.</p>}
          </div>
        </section>
      </div>

      <section>
        <h2 className="mb-2 text-sm font-bold uppercase tracking-wide text-slate-500">Performance trend (rolling avg)</h2>
        <div className="card flex items-end gap-1.5 overflow-x-auto p-4" style={{ height: 150 }}>
          {trend.length === 0 ? (
            <p className="text-sm text-slate-400">No attempts yet.</p>
          ) : (
            trend.map((t, i) => (
              <div key={i} className={`w-4 rounded-t ${t.pct >= 50 ? "bg-brand-500" : "bg-amber-400"}`} style={{ height: `${Math.max(6, t.pct)}%` }} title={`${t.pct}%`} />
            ))
          )}
        </div>
      </section>

      <section className="card p-5">
        <h2 className="mb-3 font-bold">Payment history</h2>
        <div className="divide-y divide-slate-100">
          {student.payments.length === 0 && <p className="text-sm text-slate-400">No payments.</p>}
          {student.payments.map((p) => (
            <div key={p.id} className="flex items-center justify-between py-2 text-sm">
              <div>
                <div className="font-medium">{p.description}</div>
                <div className="text-xs text-slate-400">{new Date(p.paidAt).toLocaleDateString("en-MY")} · {p.method}</div>
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
        <h2 className="mb-3 font-bold">Recent activity</h2>
        <div className="divide-y divide-slate-100">
          {recentActivity.length === 0 && <p className="text-sm text-slate-400">No activity logged yet.</p>}
          {recentActivity.map((a) => (
            <div key={a.id} className="flex items-center justify-between py-1.5 text-sm">
              <span>{a.action}{a.detail ? <span className="text-slate-400">, {a.detail}</span> : null}</span>
              <span className="text-xs text-slate-400">{timeAgo(a.createdAt)}</span>
            </div>
          ))}
        </div>
      </section>

      <section className="card p-5">
        <h2 className="mb-3 font-bold">Account</h2>
        <AdminStudentTools studentId={student.id} />
      </section>
    </div>
  );
}
