"use client";

import { useRouter } from "next/navigation";
import { celebrate } from "./Confetti";

// CTA that pops confetti, then navigates (or smooth-scrolls to a #section).
export default function CelebrateLink({
  href, className = "", children,
}: { href: string; className?: string; children: React.ReactNode }) {
  const router = useRouter();
  function go(e: React.MouseEvent) {
    e.preventDefault();
    celebrate(1.3);
    if (href.startsWith("#")) {
      document.querySelector(href)?.scrollIntoView({ behavior: "smooth" });
    } else {
      setTimeout(() => router.push(href), 260);
    }
  }
  return <a href={href} onClick={go} className={className}>{children}</a>;
}
