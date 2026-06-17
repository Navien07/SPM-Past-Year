import { cookies } from "next/headers";
import { redirect } from "next/navigation";
import { prisma } from "./db";

const COOKIE = "spm_uid";
const MAX_AGE = 60 * 60 * 24 * 7; // 7 days

export type Role = "admin" | "student";

export async function getCurrentUser() {
  const store = await cookies();
  const id = store.get(COOKIE)?.value;
  if (!id) return null;
  return prisma.user.findUnique({ where: { id }, include: { student: true } });
}

// Cookie writes must happen in a Route Handler or Server Action.
export async function setSession(userId: string) {
  const store = await cookies();
  store.set(COOKIE, userId, {
    httpOnly: true,
    sameSite: "lax",
    path: "/",
    maxAge: MAX_AGE,
    secure: process.env.NODE_ENV === "production",
  });
}

export async function clearSession() {
  const store = await cookies();
  store.delete(COOKIE);
}

export function roleHome(role: string): string {
  if (role === "admin") return "/admin";
  return "/";
}

// Guard a page: redirect to /login if not authenticated, or to the user's own
// home if their role isn't allowed.
export async function requireUser(roles?: Role[]) {
  const user = await getCurrentUser();
  if (!user) redirect("/login");
  if (roles && !roles.includes(user.role as Role)) redirect(roleHome(user.role));
  return user;
}
