import { NextRequest, NextResponse } from "next/server";
import { prisma } from "@/lib/db";
import { verifyPassword } from "@/lib/password";
import { setSession, roleHome } from "@/lib/auth";
import { rateLimit } from "@/lib/ratelimit";
import { logActivity, clientIp } from "@/lib/activity";

export async function POST(req: NextRequest) {
  const ip = clientIp(req);
  if (!rateLimit(`login:${ip}`, 20, 15 * 60 * 1000)) {
    return NextResponse.json({ error: "Too many sign-in attempts. Please wait a few minutes." }, { status: 429 });
  }
  const { email, password } = await req.json();
  if (!email || !password) {
    return NextResponse.json({ error: "Email and password required" }, { status: 400 });
  }

  const cleanEmail = String(email).toLowerCase().trim();
  const user = await prisma.user.findUnique({ where: { email: cleanEmail }, include: { student: true } });
  if (!user || !verifyPassword(String(password), user.password)) {
    await logActivity({ name: cleanEmail, action: "login.failed", ip });
    return NextResponse.json({ error: "Invalid email or password" }, { status: 401 });
  }

  await logActivity({ userId: user.id, studentId: user.studentId, name: user.name, role: user.role, action: "login", ip });
  await setSession(user.id);
  return NextResponse.json({ role: user.role, redirect: roleHome(user.role), name: user.name });
}
