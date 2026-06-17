import { requireUser } from "@/lib/auth";

export const dynamic = "force-dynamic";

// Review of AI categorization is handled by the admin.
export default async function ModerateLayout({ children }: { children: React.ReactNode }) {
  await requireUser(["admin"]);
  return <>{children}</>;
}
