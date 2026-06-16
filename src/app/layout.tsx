import type { Metadata, Viewport } from "next";
import "./globals.css";
import Nav from "@/components/Nav";

export const metadata: Metadata = {
  title: "SPM AI — Learning Management System",
  description:
    "AI-powered SPM revision: categorized past-year, trial, state & mock papers with instant grading, an AI tutor and KBAT question generation.",
};

export const viewport: Viewport = {
  width: "device-width",
  initialScale: 1,
  themeColor: "#1f50e0",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>
        <Nav />
        <main className="mx-auto max-w-5xl px-4 pb-24 pt-6 sm:pb-10">{children}</main>
      </body>
    </html>
  );
}
