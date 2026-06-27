import { NextRequest, NextResponse } from "next/server";
import { prisma } from "@/lib/db";
import { getCurrentUser } from "@/lib/auth";

export const maxDuration = 60;

// QA dashboard data: questions that need a human eye — flagged pending, carrying
// a parse issue (reviewNote), missing a topic link, or with an empty stem.
export async function GET(req: NextRequest) {
  const admin = await getCurrentUser();
  if (!admin || (admin.role !== "admin" && admin.role !== "teacher")) {
    return NextResponse.json({ error: "Forbidden" }, { status: 403 });
  }
  const params = req.nextUrl.searchParams;
  const q = params.get("q")?.trim();
  const filter = params.get("filter") || "flagged"; // flagged | unlinked | linked | all
  const subject = params.get("subject")?.trim();

  const where: Record<string, unknown> = {};
  if (filter === "unlinked") where.topicId = null;
  else if (filter === "linked") where.topicId = { not: null };
  else if (filter === "flagged") where.OR = [{ status: "pending" }, { reviewNote: { not: null } }, { topicId: null }];
  // "all" → no status/topic constraint
  if (subject) where.subject = { code: subject };
  if (q) where.stem = { contains: q, mode: "insensitive" };

  const [counts, items, untaggedCount] = await Promise.all([
    prisma.question.groupBy({ by: ["status"], _count: true }),
    prisma.question.findMany({
      where,
      orderBy: { createdAt: "desc" },
      take: 200,
      select: {
        id: true, stem: true, questionType: true, status: true, reviewNote: true,
        marks: true, topicId: true, answer: true, subjectId: true,
        subject: { select: { name: true, code: true } },
        topic: { select: { title: true, form: true, chapter: true } },
        paper: { select: { title: true } },
      },
    }),
    prisma.question.count({ where: { topicId: null } }),
  ]);

  return NextResponse.json({
    counts: Object.fromEntries(counts.map((c) => [c.status, c._count])),
    untagged: untaggedCount,
    items,
  });
}

// Approve / reject / delete a flagged question.
export async function PATCH(req: NextRequest) {
  const admin = await getCurrentUser();
  if (!admin || (admin.role !== "admin" && admin.role !== "teacher")) {
    return NextResponse.json({ error: "Forbidden" }, { status: 403 });
  }
  const { id, action } = await req.json();
  if (!id || !action) return NextResponse.json({ error: "id and action required" }, { status: 400 });

  if (action === "delete") {
    await prisma.question.delete({ where: { id } }).catch(() => {});
    return NextResponse.json({ ok: true, deleted: true });
  }
  if (action === "approve" || action === "reject") {
    await prisma.question.update({
      where: { id },
      data: { status: action === "approve" ? "approved" : "rejected", reviewedById: admin.id, reviewedAt: new Date() },
    });
    return NextResponse.json({ ok: true });
  }
  return NextResponse.json({ error: "Unknown action" }, { status: 400 });
}
