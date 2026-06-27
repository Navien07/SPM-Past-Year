import Link from "next/link";
import { prisma } from "@/lib/db";
import { requireStudent } from "@/lib/student";
import { examLabel, PAPER_TYPES } from "@/lib/constants";

export const dynamic = "force-dynamic";

type SP = Promise<{ subject?: string; year?: string; type?: string; page?: string }>;

// Browse real past/trial/state papers with filters (subject, year, type) and
// pagination — there are thousands, so never load them all.
export default async function PapersPage({ searchParams }: { searchParams: SP }) {
  await requireStudent();
  const sp = await searchParams;
  const PAGE_SIZE = 30;
  const page = Math.max(1, Number(sp.page) || 1);

  const [subjects, years] = await Promise.all([
    prisma.subject.findMany({ orderBy: { name: "asc" }, select: { id: true, name: true } }),
    prisma.paper.findMany({
      where: { questions: { some: { status: "approved" } } },
      distinct: ["year"], orderBy: { year: "desc" }, select: { year: true },
    }),
  ]);

  const where: Record<string, unknown> = { questions: { some: { status: "approved" } } };
  if (sp.subject) where.subjectId = sp.subject;
  if (sp.year) where.year = Number(sp.year);
  if (sp.type) where.paperType = sp.type;

  const [papers, total] = await Promise.all([
    prisma.paper.findMany({
      where,
      orderBy: [{ year: "desc" }, { createdAt: "desc" }],
      skip: (page - 1) * PAGE_SIZE,
      take: PAGE_SIZE,
      select: {
        id: true, title: true, paperType: true, year: true, state: true, paperNumber: true,
        subject: { select: { name: true } },
        _count: { select: { questions: { where: { status: "approved" } } } },
      },
    }),
    prisma.paper.count({ where }),
  ]);

  const pages = Math.ceil(total / PAGE_SIZE);
  const qs = (extra: Record<string, string>) => {
    const p = new URLSearchParams();
    if (sp.subject) p.set("subject", sp.subject);
    if (sp.year) p.set("year", sp.year);
    if (sp.type) p.set("type", sp.type);
    for (const [k, v] of Object.entries(extra)) v ? p.set(k, v) : p.delete(k);
    return `/papers?${p.toString()}`;
  };

  return (
    <div className="space-y-5">
      <div>
        <h1 className="text-2xl font-bold">Past Papers</h1>
        <p className="text-sm text-slate-500">Attempt a full paper end to end and get it marked instantly. {total.toLocaleString("en-MY")} papers.</p>
      </div>

      {/* Filters */}
      <form action="/papers" method="get" className="card grid gap-3 p-4 sm:grid-cols-4">
        <select name="subject" defaultValue={sp.subject ?? ""} className="input">
          <option value="">All subjects</option>
          {subjects.map((s) => <option key={s.id} value={s.id}>{s.name}</option>)}
        </select>
        <select name="year" defaultValue={sp.year ?? ""} className="input">
          <option value="">All years</option>
          {years.map((y) => <option key={y.year} value={y.year}>{y.year}</option>)}
        </select>
        <select name="type" defaultValue={sp.type ?? ""} className="input">
          <option value="">All types</option>
          {PAPER_TYPES.map((p) => <option key={p.value} value={p.value}>{p.label}</option>)}
        </select>
        <div className="flex gap-2">
          <button className="btn-primary flex-1 cursor-pointer">Filter</button>
          {(sp.subject || sp.year || sp.type) && <Link href="/papers" className="btn-ghost">Clear</Link>}
        </div>
      </form>

      {papers.length === 0 ? (
        <div className="card p-8 text-center text-slate-500">No papers match these filters.</div>
      ) : (
        <div className="grid gap-3 sm:grid-cols-2">
          {papers.map((p) => (
            <Link key={p.id} href={`/paper/${p.id}`} className="card p-4 transition-all duration-200 hover:-translate-y-0.5 hover:border-brand-300 hover:shadow-sm">
              <div className="mb-1 flex flex-wrap items-center gap-2 text-xs">
                <span className="badge bg-brand-50 text-brand-700">{p.subject.name}</span>
                <span className="badge bg-slate-100 text-slate-600">Kertas {p.paperNumber}</span>
                <span className="badge bg-slate-100 text-slate-600">{examLabel({ paperType: p.paperType, state: p.state, year: p.year })}</span>
              </div>
              <p className="font-semibold">{p.title}</p>
              <p className="mt-1 text-xs text-slate-400">{p._count.questions} soalan</p>
            </Link>
          ))}
        </div>
      )}

      {/* Pagination */}
      {pages > 1 && (
        <div className="flex items-center justify-between text-sm">
          {page > 1 ? <Link href={qs({ page: String(page - 1) })} className="btn-ghost">← Prev</Link> : <span />}
          <span className="text-slate-500">Page {page} of {pages}</span>
          {page < pages ? <Link href={qs({ page: String(page + 1) })} className="btn-ghost">Next →</Link> : <span />}
        </div>
      )}
    </div>
  );
}
