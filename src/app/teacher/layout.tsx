import { requireUser } from "@/lib/auth";

export const dynamic = "force-dynamic";

// Gates /teacher/* to teachers (and admins).
export default async function TeacherLayout({ children }: { children: React.ReactNode }) {
  await requireUser(["admin", "teacher"]);
  return <>{children}</>;
}
