import { requireUser } from "@/lib/auth";

export const dynamic = "force-dynamic";

// Gates every /admin/* route to admins.
export default async function AdminLayout({ children }: { children: React.ReactNode }) {
  await requireUser(["admin"]);
  return <>{children}</>;
}
