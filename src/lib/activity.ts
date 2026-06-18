import { prisma } from "./db";

// Trace logging — best-effort; never throws/blocks the request.
export async function logActivity(opts: {
  userId?: string | null;
  studentId?: string | null;
  name?: string | null;
  role?: string | null;
  action: string;
  detail?: string;
  path?: string;
  ip?: string | null;
}): Promise<void> {
  try {
    await prisma.activityLog.create({
      data: {
        userId: opts.userId ?? null,
        studentId: opts.studentId ?? null,
        name: opts.name ?? null,
        role: opts.role ?? null,
        action: opts.action,
        detail: opts.detail ? opts.detail.slice(0, 500) : null,
        path: opts.path ?? null,
        ip: opts.ip ?? null,
      },
    });
  } catch {
    /* logging must never break the app */
  }
}

export function clientIp(req: Request): string | null {
  const xf = req.headers.get("x-forwarded-for");
  if (xf) return xf.split(",")[0].trim();
  return req.headers.get("x-real-ip");
}
