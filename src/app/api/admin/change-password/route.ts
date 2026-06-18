import { NextRequest, NextResponse } from "next/server";
import { prisma } from "@/lib/db";
import { getCurrentUser } from "@/lib/auth";
import { verifyPassword, hashPassword } from "@/lib/password";
import { logActivity, clientIp } from "@/lib/activity";

// Admin changes their own password (verify current → set new).
export async function POST(req: NextRequest) {
  const user = await getCurrentUser();
  if (!user || user.role !== "admin") return NextResponse.json({ error: "Forbidden" }, { status: 403 });

  const { currentPassword, newPassword } = await req.json();
  if (!verifyPassword(String(currentPassword || ""), user.password)) {
    return NextResponse.json({ error: "Current password is incorrect." }, { status: 400 });
  }
  if (String(newPassword || "").length < 8) {
    return NextResponse.json({ error: "New password must be at least 8 characters." }, { status: 400 });
  }

  await prisma.user.update({ where: { id: user.id }, data: { password: hashPassword(String(newPassword)) } });
  await logActivity({ userId: user.id, name: user.name, role: "admin", action: "admin.change_password", ip: clientIp(req) });
  return NextResponse.json({ ok: true });
}
