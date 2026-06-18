import { NextRequest, NextResponse } from "next/server";
import { getCurrentUser } from "@/lib/auth";
import { sendPushToAll } from "@/lib/push";
import { logActivity, clientIp } from "@/lib/activity";

export const maxDuration = 60;

// Admin broadcast: push a notification to every subscribed device.
export async function POST(req: NextRequest) {
  const admin = await getCurrentUser();
  if (!admin || admin.role !== "admin") return NextResponse.json({ error: "Forbidden" }, { status: 403 });

  const { title, body, url } = await req.json();
  if (!title || !body) return NextResponse.json({ error: "Title and body are required." }, { status: 400 });

  const result = await sendPushToAll({
    title: String(title).slice(0, 80),
    body: String(body).slice(0, 240),
    url: url ? String(url).slice(0, 300) : "/",
  });

  if (!result.enabled) {
    return NextResponse.json({ error: "Push isn't configured. Set VAPID_PUBLIC_KEY / VAPID_PRIVATE_KEY." }, { status: 503 });
  }

  await logActivity({ userId: admin.id, name: admin.name, role: "admin", action: "push.broadcast", detail: `${result.sent} sent, ${result.failed} failed`, ip: clientIp(req) });
  return NextResponse.json(result);
}
