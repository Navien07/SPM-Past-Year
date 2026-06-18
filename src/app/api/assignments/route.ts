import { NextRequest, NextResponse } from "next/server";
import { prisma } from "@/lib/db";
import { getCurrentUser } from "@/lib/auth";
import { logActivity, clientIp } from "@/lib/activity";

export const maxDuration = 60;

// Class assignments set by an admin/teacher for the pilot cohort.
// GET: students see assignments + their own completion; staff see all.
export async function GET() {
  const user = await getCurrentUser();
  if (!user) return NextResponse.json({ error: "Unauthorized" }, { status: 401 });

  const assignments = await prisma.assignment.findMany({ orderBy: { createdAt: "desc" }, take: 100 });

  // Resolve display names for paper/topic/subject scopes.
  const paperIds = assignments.map((a) => a.paperId).filter(Boolean) as string[];
  const topicIds = assignments.map((a) => a.topicId).filter(Boolean) as string[];
  const [papers, topics] = await Promise.all([
    paperIds.length ? prisma.paper.findMany({ where: { id: { in: paperIds } }, select: { id: true, title: true } }) : [],
    topicIds.length ? prisma.topic.findMany({ where: { id: { in: topicIds } }, select: { id: true, title: true } }) : [],
  ]);
  const paperName = new Map(papers.map((p) => [p.id, p.title]));
  const topicName = new Map(topics.map((tp) => [tp.id, tp.title]));

  const student = user.role === "student" ? user.student : null;

  const out = await Promise.all(
    assignments.map(async (a) => {
      const where: Record<string, unknown> = { status: "approved" };
      if (a.type === "paper" && a.paperId) where.paperId = a.paperId;
      else if (a.type === "topic" && a.topicId) where.topicId = a.topicId;
      else if (a.subjectId) where.subjectId = a.subjectId;

      const total = await prisma.question.count({ where });
      let done = 0;
      if (student && total > 0) {
        const qs = await prisma.question.findMany({ where, select: { id: true } });
        const ids = qs.map((q) => q.id);
        const attempted = await prisma.attempt.findMany({
          where: { studentId: student.id, questionId: { in: ids } },
          select: { questionId: true },
          distinct: ["questionId"],
        });
        done = attempted.length;
      }
      return {
        id: a.id, title: a.title, type: a.type, dueAt: a.dueAt,
        scope: a.type === "paper" ? paperName.get(a.paperId ?? "") : a.type === "topic" ? topicName.get(a.topicId ?? "") : null,
        total, done,
      };
    }),
  );

  return NextResponse.json(out);
}

export async function POST(req: NextRequest) {
  const user = await getCurrentUser();
  if (!user || (user.role !== "admin" && user.role !== "teacher")) {
    return NextResponse.json({ error: "Forbidden" }, { status: 403 });
  }
  const { title, type, paperId, topicId, subjectId, dueAt } = await req.json();
  if (!title) return NextResponse.json({ error: "Title is required" }, { status: 400 });

  const a = await prisma.assignment.create({
    data: {
      title: String(title).slice(0, 160),
      type: type === "topic" ? "topic" : "paper",
      paperId: paperId || null,
      topicId: topicId || null,
      subjectId: subjectId || null,
      dueAt: dueAt ? new Date(dueAt) : null,
      createdById: user.id,
    },
  });
  await logActivity({ userId: user.id, name: user.name, role: user.role, action: "assignment.create", detail: a.title, ip: clientIp(req) });
  return NextResponse.json(a, { status: 201 });
}

export async function DELETE(req: NextRequest) {
  const user = await getCurrentUser();
  if (!user || (user.role !== "admin" && user.role !== "teacher")) {
    return NextResponse.json({ error: "Forbidden" }, { status: 403 });
  }
  const { id } = await req.json();
  if (id) await prisma.assignment.delete({ where: { id } }).catch(() => {});
  return NextResponse.json({ ok: true });
}
