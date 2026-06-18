import { NextRequest, NextResponse } from "next/server";
import { prisma } from "@/lib/db";
import { getCurrentUser } from "@/lib/auth";
import { hashPassword } from "@/lib/password";
import { logActivity, clientIp } from "@/lib/activity";

// Admin sets a new password for a student (fallback when email reset isn't set up).
export async function POST(req: NextRequest, ctx: { params: Promise<{ id: string }> }) {
  const admin = await getCurrentUser();
  if (!admin || admin.role !== "admin") return NextResponse.json({ error: "Forbidden" }, { status: 403 });

  const { id } = await ctx.params;
  const { password } = await req.json();
  if (String(password || "").length < 6) {
    return NextResponse.json({ error: "Password must be at least 6 characters." }, { status: 400 });
  }

  const user = await prisma.user.findFirst({ where: { studentId: id } });
  if (!user) return NextResponse.json({ error: "Student account not found." }, { status: 404 });

  await prisma.user.update({ where: { id: user.id }, data: { password: hashPassword(String(password)) } });
  await logActivity({ userId: admin.id, studentId: id, name: admin.name, role: "admin", action: "admin.reset_student_password", detail: user.email, ip: clientIp(req) });
  return NextResponse.json({ ok: true });
}
