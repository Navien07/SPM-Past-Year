import { prisma } from "@/lib/db";
import { getCurrentUser } from "@/lib/auth";
import AssignmentManager from "@/components/AssignmentManager";
export const dynamic = "force-dynamic";
export const maxDuration = 60;

// Teacher home: cohort snapshot + assignment management.
export default async function TeacherPage() {
  const user = await getCurrentUser();

  let students = 0, attempts = 0, avg = 0;
  try {
    const all = await prisma.attempt.findMany({ select: { score: true, maxScore: true } });
    students = await prisma.student.count();
    attempts = all.length;
    avg = all.length ? Math.round((all.reduce((a, x) => a + (x.maxScore ? x.score / x.maxScore : 0), 0) / all.length) * 100) : 0;
  } catch {
    /* ignore */
  }

  const stats = [
    { label: "Students", value: students },
    { label: "Total attempts", value: attempts },
    { label: "Class average", value: `${avg}%` },
  ];

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold">Salam, {user?.name} 👩‍🏫</h1>
        <p className="text-sm text-slate-500">Your class at a glance — and set work for the cohort.</p>
      </div>

      <div className="grid grid-cols-3 gap-3">
        {stats.map((s) => (
          <div key={s.label} className="card p-4 text-center">
            <div className="text-2xl font-bold text-brand-700">{s.value}</div>
            <div className="mt-1 text-xs text-slate-500">{s.label}</div>
          </div>
        ))}
      </div>

      <AssignmentManager />
    </div>
  );
}
