import { NextRequest, NextResponse } from "next/server";
import { prisma } from "@/lib/db";
import { getCurrentUser } from "@/lib/auth";

// Moderator action on a pending question: approve (with optional corrections to
// subject/topic/KBAT/marks) or reject.
export async function POST(req: NextRequest, ctx: { params: Promise<{ id: string }> }) {
  const user = await getCurrentUser();
  if (!user || user.role !== "admin") {
    return NextResponse.json({ error: "Forbidden" }, { status: 403 });
  }

  const { id } = await ctx.params;
  const body = await req.json();
  const { action, subjectId, topicId, isKbat, marks, note } = body as {
    action: "approve" | "reject";
    subjectId?: string;
    topicId?: string | null;
    isKbat?: boolean;
    marks?: number;
    note?: string;
  };

  const question = await prisma.question.findUnique({ where: { id } });
  if (!question) return NextResponse.json({ error: "Question not found" }, { status: 404 });

  const data: Record<string, unknown> = {
    reviewedById: user.id,
    reviewedAt: new Date(),
    reviewNote: note ?? null,
  };

  if (action === "reject") {
    data.status = "rejected";
  } else {
    data.status = "approved";
    // Apply moderator corrections.
    if (subjectId) data.subjectId = subjectId;
    if (topicId !== undefined) data.topicId = topicId || null;
    if (typeof isKbat === "boolean") data.isKbat = isKbat;
    if (typeof marks === "number" && marks > 0) data.marks = marks;
  }

  const updated = await prisma.question.update({ where: { id }, data });
  return NextResponse.json({ ok: true, status: updated.status });
}
