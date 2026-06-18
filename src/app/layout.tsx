import type { Metadata, Viewport } from "next";
import { cookies } from "next/headers";
import "./globals.css";
import Nav from "@/components/Nav";
import ChatWidget from "@/components/ChatWidget";
import PwaRegister from "@/components/PwaRegister";
import { getCurrentUser } from "@/lib/auth";
import { LANG_COOKIE, normLang } from "@/lib/i18n";

export const metadata: Metadata = {
  title: "SPM AI — Learning Management System",
  description:
    "AI-powered SPM platform: an admin dashboard with confidence-gated AI categorization & review, and a student portal with instant grading, an AI tutor and KBAT practice.",
  manifest: "/manifest.webmanifest",
  applicationName: "SPM AI",
  appleWebApp: { capable: true, statusBarStyle: "default", title: "SPM AI" },
  icons: {
    icon: [{ url: "/favicon.svg", type: "image/svg+xml" }],
    apple: [{ url: "/icon.svg" }],
  },
};

export const viewport: Viewport = {
  width: "device-width",
  initialScale: 1,
  themeColor: "#1f50e0",
};

export default async function RootLayout({ children }: { children: React.ReactNode }) {
  const user = await getCurrentUser();
  const navUser = user ? { name: user.name, role: user.role } : null;
  const lang = normLang((await cookies()).get(LANG_COOKIE)?.value);

  return (
    <html lang={lang === "bm" ? "ms" : "en"}>
      <body>
        <Nav user={navUser} lang={lang} />
        <main className="mx-auto max-w-6xl px-4 pb-24 pt-6 sm:pb-10">{children}</main>
        {/* Cikgu AI chat is for students. */}
        {user?.role === "student" && <ChatWidget />}
        <PwaRegister />
      </body>
    </html>
  );
}
