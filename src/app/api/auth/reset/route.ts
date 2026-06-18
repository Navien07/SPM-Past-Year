import { NextRequest, NextResponse } from "next/server";
import { prisma } from "@/lib/db";
import { hashPassword } from "@/lib/password";
import { rateLimit } from "@/lib/ratelimit";
import { logActivity, clientIp } from "@/lib/activity";

// Complete a password reset with a valid token.
export async function POST(req: NextRequest) {
  const ip = clientIp(req);
  if (!rateLimit(`reset:${ip}`, 20, 60 * 60 * 1000)) {
    return NextResponse.json({ error: "Too many attempts. Please try again later." }, { status: 429 });
  }
  const { token, password } = await req.json();
  if (!token || !password || String(password).length < 6) {
    return NextResponse.json({ error: "A valid token and a password (min 6 chars) are required." }, { status: 400 });
  }

  const reset = await prisma.passwordReset.findUnique({ where: { token: String(token) } });
  if (!reset || reset.usedAt || reset.expiresAt < new Date()) {
    return NextResponse.json({ error: "This reset link is invalid or has expired. Please request a new one." }, { status: 400 });
  }

  await prisma.user.update({ where: { id: reset.userId }, data: { password: hashPassword(String(password)) } });
  await prisma.passwordReset.update({ where: { id: reset.id }, data: { usedAt: new Date() } });
  await logActivity({ userId: reset.userId, action: "password.reset", ip });

  return NextResponse.json({ ok: true });
}
