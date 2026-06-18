import { NextResponse } from "next/server";
import { clearSession, getCurrentUser } from "@/lib/auth";
import { logActivity } from "@/lib/activity";

export async function POST() {
  const user = await getCurrentUser();
  if (user) await logActivity({ userId: user.id, studentId: user.studentId, name: user.name, role: user.role, action: "logout" });
  await clearSession();
  return NextResponse.json({ ok: true });
}
