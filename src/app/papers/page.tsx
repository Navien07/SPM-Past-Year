import Link from "next/link";
import { prisma } from "@/lib/db";
import { requireStudent } from "@/lib/student";
import { examLabel } from "@/lib/constants";

export const dynamic = "force-dynamic";

// Browse real past/trial papers that have approved questions, to attempt
// end-to-end (the whole paper in one sitting).
export default async function PapersPage() {
  await requireStudent();

  const papers = await prisma.paper.findMany({
    where: { questions: { some: { status: "approved" } } },
    orderBy: [{ year: "desc" }, { createdAt: "desc" }],
    take: 200,
    select: {
      id: true, title: true, paperType: true, year: true, state: true, paperNumber: true,
      subject: { select: { name: true } },
      _count: { select: { questions: { where: { status: "approved" } } } },
    },
  });

  return (
    <div className="space-y-5">
      <div>
        <h1 className="text-2xl font-bold">Past Papers 📄</h1>
        <p className="text-sm text-slate-500">Attempt a full paper end-to-end and get it marked instantly.</p>
      </div>

      {papers.length === 0 ? (
        <div className="card p-8 text-center text-slate-500">
          No full papers available yet. Practise by topic in the meantime.
          <div className="mt-3"><Link href="/practice" className="btn-primary">Go to Practice</Link></div>
        </div>
      ) : (
        <div className="grid gap-3 sm:grid-cols-2">
          {papers.map((p) => (
            <Link key={p.id} href={`/paper/${p.id}`} className="card p-4 hover:border-brand-300 hover:shadow-sm">
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
    </div>
  );
}
