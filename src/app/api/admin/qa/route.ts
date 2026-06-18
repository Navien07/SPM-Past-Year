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
  const q = req.nextUrl.searchParams.get("q")?.trim();

  const where: Record<string, unknown> = {
    OR: [
      { status: "pending" },
      { reviewNote: { not: null } },
      { topicId: null },
    ],
  };
  if (q) where.stem = { contains: q, mode: "insensitive" };

  const [counts, items] = await Promise.all([
    prisma.question.groupBy({ by: ["status"], _count: true }),
    prisma.question.findMany({
      where: q ? { stem: { contains: q, mode: "insensitive" } } : where,
      orderBy: { createdAt: "desc" },
      take: 200,
      select: {
        id: true, stem: true, questionType: true, status: true, reviewNote: true,
        marks: true, topicId: true, answer: true,
        subject: { select: { name: true, code: true } },
        topic: { select: { title: true, form: true, chapter: true } },
        paper: { select: { title: true } },
      },
    }),
  ]);

  return NextResponse.json({
    counts: Object.fromEntries(counts.map((c) => [c.status, c._count])),
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
