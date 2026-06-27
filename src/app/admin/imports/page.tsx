import Link from "next/link";
import { prisma } from "@/lib/db";
import TagTopicsButton from "@/components/TagTopicsButton";
import Icon from "@/components/Icon";

export const dynamic = "force-dynamic";
export const maxDuration = 60;

// Observability for bulk loads: live content counts + a log of import runs.
export default async function ImportsPage() {
  let papers = 0, questions = 0, approved = 0, pending = 0, knowledge = 0, runs: { id: string; detail: string | null; name: string | null; createdAt: Date; action: string }[] = [];
  try {
    [papers, questions, approved, pending, knowledge, runs] = await Promise.all([
      prisma.paper.count(),
      prisma.question.count(),
      prisma.question.count({ where: { status: "approved" } }),
      prisma.question.count({ where: { status: "pending" } }),
      prisma.knowledgeDoc.count(),
      prisma.activityLog.findMany({
        where: { action: { in: ["papers.bulk_import", "knowledge.bulk_import"] } },
        orderBy: { createdAt: "desc" },
        take: 100,
        select: { id: true, detail: true, name: true, createdAt: true, action: true },
      }),
    ]);
  } catch {
    /* tables may be mid-migration */
  }

  const stats = [
    { label: "Papers", value: papers },
    { label: "Questions", value: questions },
    { label: "Approved", value: approved },
    { label: "In QA (pending)", value: pending, href: "/admin/qa" },
    { label: "Knowledge chunks", value: knowledge },
  ];

  return (
    <div className="space-y-6">
      <div className="flex items-end justify-between gap-3">
        <div>
          <h1 className="flex items-center gap-2 text-2xl font-bold"><Icon name="download" className="h-6 w-6" /> Import runs</h1>
          <p className="text-sm text-slate-500">Live content totals and a log of every bulk import.</p>
        </div>
        <Link href="/admin/papers/bulk" className="btn-ghost shrink-0 gap-2"><Icon name="package" className="h-4 w-4" /> Import papers</Link>
      </div>

      <section className="grid grid-cols-2 gap-3 sm:grid-cols-5">
        {stats.map((s) => {
          const card = (
            <div className="card p-4 text-center">
              <div className="text-2xl font-bold text-brand-700">{s.value.toLocaleString("en-MY")}</div>
              <div className="mt-1 text-xs text-slate-500">{s.label}</div>
            </div>
          );
          return s.href ? <Link key={s.label} href={s.href}>{card}</Link> : <div key={s.label}>{card}</div>;
        })}
      </section>

      <TagTopicsButton />

      <section>
        <h2 className="mb-2 text-sm font-bold uppercase tracking-wide text-slate-500">Recent import runs</h2>
        <div className="card divide-y divide-slate-100">
          {runs.length === 0 && <p className="p-4 text-sm text-slate-400">No imports yet.</p>}
          {runs.map((r) => (
            <div key={r.id} className="flex items-start justify-between gap-3 p-3 text-sm">
              <div>
                <span className={`badge ${r.action.startsWith("papers") ? "bg-brand-50 text-brand-700" : "bg-accent-100 text-accent-700"}`}>
                  {r.action === "papers.bulk_import" ? "Papers" : "Textbooks"}
                </span>
                <span className="ml-2 text-slate-600">{r.detail}</span>
              </div>
              <span className="shrink-0 text-xs text-slate-400">{new Date(r.createdAt).toLocaleString("en-MY")}</span>
            </div>
          ))}
        </div>
      </section>
    </div>
  );
}
