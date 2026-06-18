import webpush from "web-push";
import { prisma } from "./db";

// Web Push (PWA notifications). Configured from VAPID env vars; no-ops cleanly
// when they aren't set so the rest of the app keeps working.
let configured = false;
export function pushEnabled(): boolean {
  const pub = process.env.VAPID_PUBLIC_KEY;
  const priv = process.env.VAPID_PRIVATE_KEY;
  if (!pub || !priv) return false;
  if (!configured) {
    webpush.setVapidDetails(process.env.VAPID_SUBJECT || "mailto:hello@spm-ai.app", pub, priv);
    configured = true;
  }
  return true;
}

export interface PushPayload {
  title: string;
  body: string;
  url?: string;
}

type SubRow = { id: string; endpoint: string; p256dh: string; auth: string };

// Send one notification; deletes the subscription if it's gone (410/404).
async function sendOne(sub: SubRow, payload: PushPayload): Promise<boolean> {
  try {
    await webpush.sendNotification(
      { endpoint: sub.endpoint, keys: { p256dh: sub.p256dh, auth: sub.auth } },
      JSON.stringify(payload),
    );
    return true;
  } catch (e: unknown) {
    const status = (e as { statusCode?: number })?.statusCode;
    if (status === 404 || status === 410) {
      await prisma.pushSubscription.delete({ where: { id: sub.id } }).catch(() => {});
    }
    return false;
  }
}

// Broadcast to all subscriptions (or a student's). Returns counts.
export async function sendPushToAll(payload: PushPayload, studentId?: string) {
  if (!pushEnabled()) return { sent: 0, failed: 0, enabled: false };
  const subs = await prisma.pushSubscription.findMany({
    where: studentId ? { studentId } : undefined,
    select: { id: true, endpoint: true, p256dh: true, auth: true },
  });
  let sent = 0;
  let failed = 0;
  for (const s of subs) {
    (await sendOne(s, payload)) ? sent++ : failed++;
  }
  return { sent, failed, enabled: true };
}
