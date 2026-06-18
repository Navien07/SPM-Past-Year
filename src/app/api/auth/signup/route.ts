import { NextRequest, NextResponse } from "next/server";
import { prisma } from "@/lib/db";
import { hashPassword } from "@/lib/password";
import { setSession } from "@/lib/auth";

// Self-serve onboarding: email is the username, the user sets their own password.
export async function POST(req: NextRequest) {
  const { name, email, password, form, subjectIds } = await req.json();

  const cleanEmail = String(email || "").toLowerCase().trim();
  if (!name || !cleanEmail || !password) {
    return NextResponse.json({ error: "Name, email and password are required." }, { status: 400 });
  }
  if (!/^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(cleanEmail)) {
    return NextResponse.json({ error: "Please enter a valid email address." }, { status: 400 });
  }
  if (String(password).length < 6) {
    return NextResponse.json({ error: "Password must be at least 6 characters." }, { status: 400 });
  }

  const existing = await prisma.user.findUnique({ where: { email: cleanEmail } });
  if (existing) {
    return NextResponse.json({ error: "An account with this email already exists. Please sign in." }, { status: 409 });
  }

  const formNum = Number(form) === 4 ? 4 : 5;

  // Create the student profile + the auth user, then enrol in chosen subjects
  // (default: all subjects).
  const student = await prisma.student.create({
    data: { name: String(name).trim(), email: cleanEmail, form: formNum },
  });
  const user = await prisma.user.create({
    data: {
      email: cleanEmail,
      name: String(name).trim(),
      role: "student",
      password: hashPassword(String(password)),
      studentId: student.id,
    },
  });

  let ids: string[] = Array.isArray(subjectIds) ? subjectIds : [];
  if (ids.length === 0) {
    ids = (await prisma.subject.findMany({ select: { id: true } })).map((s) => s.id);
  }
  for (const subjectId of ids) {
    await prisma.enrollment.upsert({
      where: { studentId_subjectId: { studentId: student.id, subjectId } },
      update: {},
      create: { studentId: student.id, subjectId, status: "active" },
    }).catch(() => {});
  }

  await setSession(user.id);
  return NextResponse.json({ ok: true, redirect: "/" });
}
