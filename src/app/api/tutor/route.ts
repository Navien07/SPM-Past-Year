import { NextResponse } from "next/server";
import { prisma } from "@/lib/db";
import { tutorRecommend } from "@/lib/ai";
import { getSessionStudent } from "@/lib/student";

export const maxDuration = 60;

// Module 5: AI tutor — aggregate the student's attempts per topic, then ask the
// tutor agent for weak areas + a focus plan.
export async function GET() {
  const student = await getSessionStudent();
  if (!student) return NextResponse.json({ error: "Not signed in as a student" }, { status: 401 });

  const attempts = await prisma.attempt.findMany({
    where: { studentId: student.id },
    include: { question: { include: { subject: true, topic: true } } },
  });

  const agg = new Map<string, { subject: string; topic: string; sum: number; n: number }>();
  for (const a of attempts) {
    const subject = a.question.subject.name;
    const topic = a.question.topic?.title ?? "Umum";
    const key = `${subject}::${topic}`;
    const pct = a.maxScore > 0 ? (a.score / a.maxScore) * 100 : 0;
    const cur = agg.get(key) ?? { subject, topic, sum: 0, n: 0 };
    cur.sum += pct;
    cur.n += 1;
    agg.set(key, cur);
  }

  const perTopic = [...agg.values()].map((v) => ({
    subject: v.subject,
    topic: v.topic,
    attempts: v.n,
    avgPercent: Math.round(v.sum / v.n),
  }));

  const { result, byAi } = await tutorRecommend({ studentName: student.name, perTopic });
  return NextResponse.json({ recommendation: result, byAi, perTopic });
}
