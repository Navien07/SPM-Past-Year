import type { Metadata, Viewport } from "next";
import { cookies } from "next/headers";
import "./globals.css";
import Nav from "@/components/Nav";
import ChatWidget from "@/components/ChatWidget";
import PwaRegister from "@/components/PwaRegister";
import { getCurrentUser } from "@/lib/auth";
import { LANG_COOKIE, normLang } from "@/lib/i18n";

// Resolve an absolute site URL for OG/Twitter tags. Tolerate values pasted
// without a protocol (e.g. "spm-past-year.vercel.app") so the build never
// crashes on `new URL(...)`.
function resolveSiteUrl(): string {
  const raw = (process.env.NEXT_PUBLIC_SITE_URL || process.env.VERCEL_URL || "spm-past-year.vercel.app").trim();
  const withProto = /^https?:\/\//i.test(raw) ? raw : `https://${raw}`;
  try {
    return new URL(withProto).origin;
  } catch {
    return "https://spm-past-year.vercel.app";
  }
}
const SITE_URL = resolveSiteUrl();

const TITLE = "SPM AI — Malaysia's first AI-powered SPM platform";
const DESCRIPTION =
  "Every past-year, trial & state paper — auto-graded with the SPM marking scheme, explained by an AI tutor, and turned into a plan made for you. Free for the first 200 Malaysian students.";

export const metadata: Metadata = {
  metadataBase: new URL(SITE_URL),
  title: TITLE,
  description: DESCRIPTION,
  manifest: "/manifest.webmanifest",
  applicationName: "SPM AI",
  appleWebApp: { capable: true, statusBarStyle: "default", title: "SPM AI" },
  icons: {
    icon: [
      { url: "/favicon.svg", type: "image/svg+xml" },
      { url: "/icon-192.png", type: "image/png", sizes: "192x192" },
    ],
    apple: [{ url: "/apple-icon.png", sizes: "180x180" }],
  },
  openGraph: {
    type: "website",
    siteName: "SPM AI",
    locale: "ms_MY",
    title: TITLE,
    description: DESCRIPTION,
    url: "/",
    images: [{ url: "/og-image.png", width: 1200, height: 630, alt: "SPM AI — Skor A+ dengan cikgu AI" }],
  },
  twitter: {
    card: "summary_large_image",
    title: TITLE,
    description: DESCRIPTION,
    images: ["/og-image.png"],
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
