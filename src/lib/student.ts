import { redirect } from "next/navigation";
import { getCurrentUser } from "./auth";

// API helper: returns the logged-in student's profile, or null (no redirect).
export async function getSessionStudent() {
  const user = await getCurrentUser();
  if (!user || user.role !== "student") return null;
  return user.student;
}

// Student pages: require a logged-in student and return their Student profile.
// Staff (admin/moderator) get redirected to their own dashboards.
export async function requireStudent() {
  const user = await getCurrentUser();
  if (!user) redirect("/login");
  if (user.role !== "student" || !user.student) {
    redirect(user.role === "admin" ? "/admin" : user.role === "moderator" ? "/moderate" : "/login");
  }
  return user.student;
}
