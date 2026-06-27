"use client";

import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import LangToggle from "./LangToggle";
import Icon from "./Icon";
import { t, type Lang } from "@/lib/i18n";

type NavUser = { name: string; role: string } | null;

const STUDENT_LINKS = [
  { href: "/", key: "nav.home", icon: "home" },
  { href: "/practice", key: "nav.practice", icon: "practice" },
  { href: "/syllabus", key: "nav.syllabus", icon: "syllabus" },
  { href: "/papers", key: "nav.papers", icon: "papers" },
  { href: "/exam", key: "nav.exam", icon: "exam" },
  { href: "/review", key: "nav.review", icon: "review" },
  { href: "/analytics", key: "nav.progress", icon: "progress" },
];

const TEACHER_LINKS = [
  { href: "/teacher", key: "nav.overview", icon: "class" },
];

const ADMIN_LINKS = [
  { href: "/admin", key: "nav.overview", icon: "progress" },
  { href: "/admin/students", key: "nav.students", icon: "users" },
  { href: "/admin/class", key: "nav.class", icon: "class" },
  { href: "/admin/papers", key: "nav.papers", icon: "folder" },
  { href: "/admin/knowledge", key: "nav.brain", icon: "brain" },
  { href: "/moderate", key: "nav.review", icon: "check" },
  { href: "/admin/qa", key: "nav.qa", icon: "search" },
  { href: "/admin/activity", key: "nav.activity", icon: "activity" },
];

export default function Nav({ user, lang = "bm" }: { user: NavUser; lang?: Lang }) {
  const path = usePathname();
  const router = useRouter();
  const isActive = (href: string) => (href === "/" ? path === "/" : path.startsWith(href));

  const links =
    user?.role === "admin" ? ADMIN_LINKS
    : user?.role === "teacher" ? TEACHER_LINKS
    : user?.role === "student" ? STUDENT_LINKS
    : [];

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
          <Link href={user ? links[0]?.href ?? "/" : "/"} className="flex items-center gap-2">
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img src="/icon.svg" alt="SPM AI" className="h-8 w-8 rounded-lg" />
            <span className="font-bold tracking-tight">SPM<span className="text-accent-500">AI</span></span>
          </Link>

          <nav className="hidden items-center gap-1 sm:flex">
            {links.map((l) => (
              <Link key={l.href} href={l.href}
                className={`rounded-lg px-3 py-1.5 text-sm font-medium transition ${isActive(l.href) ? "bg-brand-50 text-brand-700" : "text-slate-600 hover:bg-slate-100"}`}>
                {t(lang, l.key)}
              </Link>
            ))}
          </nav>

          <div className="flex items-center gap-2">
            <LangToggle lang={lang} />
            {user ? (
              <>
                {user.role === "student" && (
                  <Link href="/help" className="hidden items-center gap-1 rounded-lg px-2 py-1.5 text-sm font-medium text-slate-600 hover:bg-slate-100 sm:inline-flex" title="Help Centre">
                    <Icon name="help" className="h-4 w-4" /> {t(lang, "nav.help")}
                  </Link>
                )}
                <span className={`badge ${roleColor} hidden sm:inline-flex`}>{user.role}</span>
                <span className="hidden text-sm text-slate-600 sm:inline">{user.name}</span>
                <button onClick={logout} className="rounded-lg border border-slate-200 px-3 py-1.5 text-sm font-medium text-slate-600 hover:bg-slate-50">
                  {t(lang, "nav.signout")}
                </button>
              </>
            ) : (
              <Link href="/login" className="btn-primary px-3 py-1.5">{t(lang, "nav.signin")}</Link>
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
                className={`flex flex-col items-center gap-1 py-2 text-[10px] font-medium transition-colors duration-150 ${isActive(l.href) ? "text-brand-700" : "text-slate-500"}`}>
                <Icon name={l.icon} className="h-[18px] w-[18px]" />
                {t(lang, l.key)}
              </Link>
            ))}
          </div>
        </nav>
      )}
    </>
  );
}
