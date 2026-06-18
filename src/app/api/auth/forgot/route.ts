import { NextRequest, NextResponse } from "next/server";
import { randomBytes } from "crypto";
import { prisma } from "@/lib/db";
import { sendEmail, emailEnabled } from "@/lib/email";
import { rateLimit } from "@/lib/ratelimit";
import { logActivity, clientIp } from "@/lib/activity";

// Forgot password: create a one-time reset token and email a reset link.
// Always responds generically (no account enumeration).
export async function POST(req: NextRequest) {
  const ip = clientIp(req);
  if (!rateLimit(`forgot:${ip}`, 8, 60 * 60 * 1000)) {
    return NextResponse.json({ error: "Too many requests. Please try again later." }, { status: 429 });
  }
  const { email } = await req.json();
  const cleanEmail = String(email || "").toLowerCase().trim();
  const generic = { ok: true, message: "If that email is registered, we've sent a reset link." };

  const user = await prisma.user.findUnique({ where: { email: cleanEmail } });
  if (user) {
    const token = randomBytes(32).toString("hex");
    await prisma.passwordReset.create({
      data: { userId: user.id, token, expiresAt: new Date(Date.now() + 60 * 60 * 1000) },
    });
    const origin = req.headers.get("origin") || new URL(req.url).origin;
    const link = `${origin}/reset?token=${token}`;
    await logActivity({ userId: user.id, name: user.name, role: user.role, action: "password.forgot", ip });
    if (emailEnabled()) {
      await sendEmail(
        cleanEmail,
        "Reset your SPM AI password",
        `<p>Hi ${user.name},</p><p>Click the link below to reset your SPM AI password (valid 1 hour):</p>
         <p><a href="${link}">${link}</a></p><p>If you didn't request this, you can ignore this email.</p>`,
      );
    }
  }
  return NextResponse.json(generic);
}
