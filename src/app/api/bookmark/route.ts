import { NextRequest, NextResponse } from "next/server";
import { prisma } from "@/lib/db";
import { getSessionStudent } from "@/lib/student";
import { logActivity, clientIp } from "@/lib/activity";

// Toggle a bookmark for the current student. Returns { bookmarked }.
export async function POST(req: NextRequest) {
  const student = await getSessionStudent();
  if (!student) return NextResponse.json({ error: "Not signed in" }, { status: 401 });
  const { questionId } = await req.json();
  if (!questionId) return NextResponse.json({ error: "questionId required" }, { status: 400 });

  const existing = await prisma.bookmark.findUnique({
    where: { studentId_questionId: { studentId: student.id, questionId } },
  });
  if (existing) {
    await prisma.bookmark.delete({ where: { id: existing.id } });
    return NextResponse.json({ bookmarked: false });
  }
  await prisma.bookmark.create({ data: { studentId: student.id, questionId } });
  await logActivity({ studentId: student.id, name: student.name, role: "student", action: "bookmark.toggle", ip: clientIp(req) });
  return NextResponse.json({ bookmarked: true });
}
