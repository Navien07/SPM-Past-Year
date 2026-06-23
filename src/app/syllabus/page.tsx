import Link from "next/link";
import { prisma } from "@/lib/db";
import { getCurrentUser } from "@/lib/auth";
import { redirect } from "next/navigation";
import { getLang } from "@/lib/lang-server";
import { t } from "@/lib/i18n";

export const dynamic = "force-dynamic";

type SP = Promise<{ subject?: string }>;

// KSSM syllabus browser: every subject's topics grouped by Tingkatan 4 / 5,
// with subtopics and how many practiceable questions each topic has.
export default async function SyllabusPage({ searchParams }: { searchParams: SP }) {
  const user = await getCurrentUser();
  if (!user) redirect("/login");
  const lang = await getLang();
  const sp = await searchParams;

  const subjects = await prisma.subject.findMany({ orderBy: { name: "asc" }, select: { id: true, name: true, code: true } });
  const subjectId = sp.subject || subjects[0]?.id;
  const subject = subjects.find((s) => s.id === subjectId);

  const topics = subjectId
    ? await prisma.topic.findMany({
        where: { subjectId },
        orderBy: [{ form: "asc" }, { chapter: "asc" }],
        include: { _count: { select: { questions: { where: { status: "approved" } } } } },
      })
    : [];

  const byForm = (form: number) => topics.filter((t) => t.form === form);

  function FormSection({ form }: { form: number }) {
    const list = byForm(form);
    if (list.length === 0) return null;
    return (
      <section className="space-y-2">
        <h2 className="text-sm font-bold uppercase tracking-wide text-slate-500">Tingkatan {form}</h2>
        <div className="grid gap-3 sm:grid-cols-2">
          {list.map((tp) => {
            const subs = JSON.parse(tp.subtopics || "[]") as string[];
            return (
              <div key={tp.id} className="card p-4">
                <div className="flex items-start justify-between gap-2">
                  <div>
                    <div className="text-xs font-semibold text-slate-400">Bab {tp.chapter}</div>
                    <h3 className="font-semibold">{tp.title}</h3>
                  </div>
                  <span className={`badge shrink-0 ${tp._count.questions > 0 ? "bg-emerald-100 text-emerald-700" : "bg-slate-100 text-slate-500"}`}>
                    {tp._count.questions} {t(lang, "common.marks") === "markah" ? "soalan" : "questions"}
                  </span>
                </div>
                {subs.length > 0 && (
                  <div className="mt-2 flex flex-wrap gap-1.5">
                    {subs.map((s) => <span key={s} className="rounded-full bg-slate-100 px-2 py-0.5 text-xs text-slate-600">{s}</span>)}
                  </div>
                )}
                {tp._count.questions > 0 && (
                  <Link href={`/practice?subject=${subjectId}&view=topic&topic=${tp.id}`} className="btn-ghost mt-3 inline-flex px-3 py-1.5 text-xs">
                    {lang === "bm" ? "Berlatih" : "Practise"} →
                  </Link>
                )}
              </div>
            );
          })}
        </div>
      </section>
    );
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold">{lang === "bm" ? "Sukatan Pelajaran KSSM" : "KSSM Syllabus"}</h1>
        <p className="text-sm text-slate-500">{lang === "bm" ? "Terokai setiap bab mengikut subjek dan tingkatan." : "Browse every chapter by subject and form."}</p>
      </div>

      <div className="flex flex-wrap gap-2">
        {subjects.map((s) => (
          <Link key={s.id} href={`/syllabus?subject=${s.id}`}
            className={`badge border px-3 py-1.5 ${s.id === subjectId ? "border-brand-300 bg-brand-50 text-brand-700" : "border-slate-200 bg-white text-slate-600"}`}>
            {s.name}
          </Link>
        ))}
      </div>

      <div>
        <h2 className="mb-1 text-lg font-bold">{subject?.name}</h2>
        <p className="mb-4 text-xs text-slate-400">{topics.length} {lang === "bm" ? "bab keseluruhan" : "chapters total"}</p>
        <div className="space-y-6">
          <FormSection form={4} />
          <FormSection form={5} />
          {topics.length === 0 && <p className="text-sm text-slate-400">{lang === "bm" ? "Tiada topik lagi." : "No topics yet."}</p>}
        </div>
      </div>
    </div>
  );
}
