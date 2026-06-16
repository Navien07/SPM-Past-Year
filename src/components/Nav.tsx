"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";

const LINKS = [
  { href: "/", label: "Home", icon: "🏠" },
  { href: "/practice", label: "Practice", icon: "📝" },
  { href: "/generate", label: "Generate", icon: "✨" },
  { href: "/tutor", label: "Tutor", icon: "🧭" },
  { href: "/analytics", label: "Progress", icon: "📊" },
  { href: "/admin", label: "Admin", icon: "🗂️" },
];

export default function Nav() {
  const path = usePathname();
  const isActive = (href: string) => (href === "/" ? path === "/" : path.startsWith(href));

  return (
    <>
      {/* Top bar (all sizes) */}
      <header className="sticky top-0 z-30 border-b border-slate-200 bg-white/90 backdrop-blur">
        <div className="mx-auto flex max-w-5xl items-center justify-between px-4 py-3">
          <Link href="/" className="flex items-center gap-2">
            <span className="grid h-8 w-8 place-items-center rounded-lg bg-brand-600 text-sm font-bold text-white">
              SP
            </span>
            <span className="font-bold tracking-tight">
              SPM<span className="text-brand-600">AI</span>
            </span>
          </Link>
          {/* Desktop links */}
          <nav className="hidden items-center gap-1 sm:flex">
            {LINKS.map((l) => (
              <Link
                key={l.href}
                href={l.href}
                className={`rounded-lg px-3 py-1.5 text-sm font-medium transition ${
                  isActive(l.href)
                    ? "bg-brand-50 text-brand-700"
                    : "text-slate-600 hover:bg-slate-100"
                }`}
              >
                {l.label}
              </Link>
            ))}
          </nav>
        </div>
      </header>

      {/* Bottom tab bar (mobile) */}
      <nav className="fixed inset-x-0 bottom-0 z-30 border-t border-slate-200 bg-white sm:hidden">
        <div className="mx-auto grid max-w-5xl grid-cols-6">
          {LINKS.map((l) => (
            <Link
              key={l.href}
              href={l.href}
              className={`flex flex-col items-center gap-0.5 py-2 text-[10px] font-medium ${
                isActive(l.href) ? "text-brand-700" : "text-slate-500"
              }`}
            >
              <span className="text-base leading-none">{l.icon}</span>
              {l.label}
            </Link>
          ))}
        </div>
      </nav>
    </>
  );
}
