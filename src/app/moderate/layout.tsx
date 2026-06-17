import { requireUser } from "@/lib/auth";

export const dynamic = "force-dynamic";

// Moderators review AI categorization; admins can also access.
export default async function ModerateLayout({ children }: { children: React.ReactNode }) {
  await requireUser(["moderator", "admin"]);
  return <>{children}</>;
}
