import { NextRequest, NextResponse } from "next/server";
import { prisma } from "@/lib/db";
import { verifyPassword } from "@/lib/password";
import { setSession, roleHome } from "@/lib/auth";

export async function POST(req: NextRequest) {
  const { email, password } = await req.json();
  if (!email || !password) {
    return NextResponse.json({ error: "Email and password required" }, { status: 400 });
  }

  const user = await prisma.user.findUnique({ where: { email: String(email).toLowerCase().trim() } });
  if (!user || !verifyPassword(String(password), user.password)) {
    return NextResponse.json({ error: "Invalid email or password" }, { status: 401 });
  }

  await setSession(user.id);
  return NextResponse.json({ role: user.role, redirect: roleHome(user.role), name: user.name });
}
