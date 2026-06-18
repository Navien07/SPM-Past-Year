import { NextRequest, NextResponse } from "next/server";
import { prisma } from "@/lib/db";
import { rateLimit } from "@/lib/ratelimit";
import { logActivity, clientIp } from "@/lib/activity";

// Public: join the waitlist (used when the free pilot is full, or from the
// landing page). Best-effort; never leaks whether an email already exists.
export async function POST(req: NextRequest) {
  const ip = clientIp(req);
  if (!rateLimit(`waitlist:${ip}`, 15, 60 * 60 * 1000)) {
    return NextResponse.json({ error: "Too many requests. Please try again later." }, { status: 429 });
  }

  const { name, email, whatsapp, school, state, note } = await req.json();
  const cleanEmail = String(email || "").toLowerCase().trim();
  if (!name || !cleanEmail) {
    return NextResponse.json({ error: "Name and email are required." }, { status: 400 });
  }
  if (!/^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(cleanEmail)) {
    return NextResponse.json({ error: "Please enter a valid email address." }, { status: 400 });
  }

  try {
    await prisma.waitlist.upsert({
      where: { email: cleanEmail },
      update: {
        name: String(name).trim().slice(0, 120),
        whatsapp: whatsapp ? String(whatsapp).replace(/[\s-]/g, "").slice(0, 20) : null,
        school: school ? String(school).trim().slice(0, 120) : null,
        state: state ? String(state).trim().slice(0, 60) : null,
        note: note ? String(note).trim().slice(0, 300) : null,
      },
      create: {
        name: String(name).trim().slice(0, 120),
        email: cleanEmail,
        whatsapp: whatsapp ? String(whatsapp).replace(/[\s-]/g, "").slice(0, 20) : null,
        school: school ? String(school).trim().slice(0, 120) : null,
        state: state ? String(state).trim().slice(0, 60) : null,
        note: note ? String(note).trim().slice(0, 300) : null,
      },
    });
  } catch {
    return NextResponse.json({ error: "Couldn't save your spot. Please try again." }, { status: 500 });
  }

  await logActivity({ name: String(name).trim(), role: "guest", action: "waitlist.join", detail: cleanEmail, path: "/", ip });

  let position = 0;
  try {
    position = await prisma.waitlist.count();
  } catch {
    /* ignore */
  }

  return NextResponse.json({ ok: true, position });
}
