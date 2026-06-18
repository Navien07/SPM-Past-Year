"use client";

import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";

type NavUser = { name: string; role: string } | null;

const STUDENT_LINKS = [
  { href: "/", label: "Home", icon: "🏠" },
  { href: "/practice", label: "Practice", icon: "📝" },
  { href: "/review", label: "Review", icon: "🔁" },
  { href: "/generate", label: "Generate", icon: "✨" },
  { href: "/tutor", label: "Tutor", icon: "🧭" },
  { href: "/analytics", label: "Progress", icon: "📊" },
];

const ADMIN_LINKS = [
  { href: "/admin", label: "Overview", icon: "📈" },
  { href: "/admin/students", label: "Students", icon: "👥" },
  { href: "/admin/papers", label: "Papers", icon: "🗂️" },
  { href: "/admin/knowledge", label: "Brain", icon: "🧠" },
  { href: "/moderate", label: "Review", icon: "✅" },
  { href: "/admin/activity", label: "Activity", icon: "🧾" },
];

export default function Nav({ user }: { user: NavUser }) {
  const path = usePathname();
  const router = useRouter();
  const isActive = (href: string) => (href === "/" ? path === "/" : path.startsWith(href));

  const links =
    user?.role === "admin" ? ADMIN_LINKS : user?.role === "student" ? STUDENT_LINKS : [];

  async function logout() {
    await fetch("/api/auth/logout", { method: "POST" });
    router.push("/login");
    router.refresh();
  }

  const roleColor =
    user?.role === "admin" ? "bg-rose-100 text-rose-700" : "bg-emerald-100 text-emerald-700";

  return (
    <>
      <header className="sticky top-0 z-30 border-b border-slate-200 bg-white/90 backdrop-blur">
        <div className="mx-auto flex max-w-6xl items-center justify-between px-4 py-3">
          <Link href={user ? links[0]?.href ?? "/" : "/login"} className="flex items-center gap-2">
            <span className="grid h-8 w-8 place-items-center rounded-lg bg-brand-600 text-sm font-bold text-white">SP</span>
            <span className="font-bold tracking-tight">SPM<span className="text-brand-600">AI</span></span>
          </Link>

          <nav className="hidden items-center gap-1 sm:flex">
            {links.map((l) => (
              <Link key={l.href} href={l.href}
                className={`rounded-lg px-3 py-1.5 text-sm font-medium transition ${isActive(l.href) ? "bg-brand-50 text-brand-700" : "text-slate-600 hover:bg-slate-100"}`}>
                {l.label}
              </Link>
            ))}
          </nav>

          <div className="flex items-center gap-2">
            {user ? (
              <>
                <span className={`badge ${roleColor} hidden sm:inline-flex`}>{user.role}</span>
                <span className="hidden text-sm text-slate-600 sm:inline">{user.name}</span>
                <button onClick={logout} className="rounded-lg border border-slate-200 px-3 py-1.5 text-sm font-medium text-slate-600 hover:bg-slate-50">
                  Sign out
                </button>
              </>
            ) : (
              <Link href="/login" className="btn-primary px-3 py-1.5">Sign in</Link>
            )}
          </div>
        </div>
      </header>

      {/* Mobile bottom tabs (only when there are role links) */}
      {links.length > 0 && (
        <nav className="fixed inset-x-0 bottom-0 z-30 border-t border-slate-200 bg-white sm:hidden">
          <div className="mx-auto grid max-w-6xl" style={{ gridTemplateColumns: `repeat(${links.length}, minmax(0, 1fr))` }}>
            {links.map((l) => (
              <Link key={l.href} href={l.href}
                className={`flex flex-col items-center gap-0.5 py-2 text-[10px] font-medium ${isActive(l.href) ? "text-brand-700" : "text-slate-500"}`}>
                <span className="text-base leading-none">{l.icon}</span>
                {l.label}
              </Link>
            ))}
          </div>
        </nav>
      )}
    </>
  );
}
