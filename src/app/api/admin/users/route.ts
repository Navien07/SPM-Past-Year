import { NextRequest, NextResponse } from "next/server";
import { prisma } from "@/lib/db";
import { getCurrentUser } from "@/lib/auth";
import { hashPassword } from "@/lib/password";
import { logActivity, clientIp } from "@/lib/activity";

// Admin creates an account (student or admin). Admin-created accounts bypass the
// public pilot cap. The admin sets the initial password; it can be changed later.
export async function POST(req: NextRequest) {
  const admin = await getCurrentUser();
  if (!admin || admin.role !== "admin") return NextResponse.json({ error: "Forbidden" }, { status: 403 });

  const body = await req.json();
  const name = String(body.name || "").trim();
  const email = String(body.email || "").toLowerCase().trim();
  const password = String(body.password || "");
  const role = body.role === "admin" ? "admin" : "student";

  if (!name || !email || !password) {
    return NextResponse.json({ error: "Name, email and password are required." }, { status: 400 });
  }
  if (!/^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(email)) {
    return NextResponse.json({ error: "Please enter a valid email address." }, { status: 400 });
  }
  if (password.length < 6) {
    return NextResponse.json({ error: "Password must be at least 6 characters." }, { status: 400 });
  }
  if (await prisma.user.findUnique({ where: { email } })) {
    return NextResponse.json({ error: "An account with this email already exists." }, { status: 409 });
  }

  let studentId: string | null = null;
  if (role === "student") {
    const ageNum = Number(body.age);
    const student = await prisma.student.create({
      data: {
        name,
        email,
        form: Number(body.form) === 4 ? 4 : 5,
        school: body.school ? String(body.school).trim().slice(0, 120) : null,
        age: Number.isFinite(ageNum) && ageNum > 0 && ageNum < 100 ? ageNum : null,
        state: body.state ? String(body.state).trim().slice(0, 60) : null,
        whatsapp: body.whatsapp ? String(body.whatsapp).replace(/[\s-]/g, "").slice(0, 20) : null,
        pdpaConsent: true,
        consentAt: new Date(),
      },
    });
    studentId = student.id;

    let ids: string[] = Array.isArray(body.subjectIds) ? body.subjectIds : [];
    if (ids.length === 0) ids = (await prisma.subject.findMany({ select: { id: true } })).map((s) => s.id);
    for (const subjectId of ids) {
      await prisma.enrollment
        .upsert({
          where: { studentId_subjectId: { studentId: student.id, subjectId } },
          update: {},
          create: { studentId: student.id, subjectId, status: "active" },
        })
        .catch(() => {});
    }
  }

  const user = await prisma.user.create({
    data: { email, name, role, password: hashPassword(password), studentId },
  });

  await logActivity({
    userId: admin.id,
    studentId,
    name: admin.name,
    role: "admin",
    action: "admin.create_user",
    detail: `${role}: ${email}`,
    ip: clientIp(req),
  });

  return NextResponse.json({ ok: true, id: user.id, studentId });
}
