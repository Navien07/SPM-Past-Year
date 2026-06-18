import { NextRequest, NextResponse } from "next/server";
import { prisma } from "@/lib/db";
import { getSessionStudent } from "@/lib/student";

// Save (or refresh) a browser's Web Push subscription.
export async function POST(req: NextRequest) {
  const student = await getSessionStudent();
  const { subscription, userAgent } = await req.json();
  const endpoint = subscription?.endpoint;
  const p256dh = subscription?.keys?.p256dh;
  const auth = subscription?.keys?.auth;
  if (!endpoint || !p256dh || !auth) {
    return NextResponse.json({ error: "Invalid subscription" }, { status: 400 });
  }
  await prisma.pushSubscription.upsert({
    where: { endpoint },
    update: { p256dh, auth, studentId: student?.id ?? null, userAgent: userAgent ? String(userAgent).slice(0, 200) : null },
    create: { endpoint, p256dh, auth, studentId: student?.id ?? null, userAgent: userAgent ? String(userAgent).slice(0, 200) : null },
  });
  return NextResponse.json({ ok: true });
}

export async function DELETE(req: NextRequest) {
  const { endpoint } = await req.json();
  if (endpoint) await prisma.pushSubscription.deleteMany({ where: { endpoint } });
  return NextResponse.json({ ok: true });
}
