import { NextRequest, NextResponse } from "next/server";
import { prisma } from "@/lib/db";
import { authorizeImport } from "@/lib/importAuth";
import { logActivity, clientIp } from "@/lib/activity";

export const maxDuration = 30;

// Admin/teacher grants or changes a student's access:
//   sponsored → free unlimited (underprivileged students)
//   pilot     → free unlimited (pilot cohort)
//   paid      → comp N months of paid access
//   trial     → reset to a fresh 7-day trial
//   expired   → revoke (set trial/paid to the past)
export async function POST(req: NextRequest) {
  const actor = await authorizeImport(req);
  if (!actor || actor.role === "import") return NextResponse.json({ error: "Forbidden" }, { status: 403 });

  const { studentId, accessType, months } = await req.json().catch(() => ({}));
  if (!studentId || !["sponsored", "pilot", "paid", "trial", "expired"].includes(accessType)) {
    return NextResponse.json({ error: "studentId and a valid accessType are required" }, { status: 400 });
  }

  const now = Date.now();
  const data: Record<string, unknown> = { accessType };
  if (accessType === "sponsored" || accessType === "pilot") {
    data.accessUntil = null;
    data.trialEndsAt = null;
  } else if (accessType === "paid") {
    const m = Math.max(1, Math.min(36, Number(months) || 12));
    data.accessUntil = new Date(now + m * 31 * 86400000);
    data.plan = m >= 12 ? "annual" : "monthly";
  } else if (accessType === "trial") {
    data.trialEndsAt = new Date(now + 7 * 86400000);
    data.accessUntil = null;
  } else {
    // expired: revoke everything
    data.accessUntil = new Date(now - 86400000);
    data.trialEndsAt = new Date(now - 86400000);
  }

  await prisma.student.update({ where: { id: studentId }, data });
  await logActivity({
    userId: actor.id, name: actor.name, role: actor.role,
    action: "admin.grant_access",
    detail: `${studentId} → ${accessType}${accessType === "paid" ? ` (${months || 12}mo)` : ""}`,
    ip: clientIp(req),
  });
  return NextResponse.json({ ok: true });
}
