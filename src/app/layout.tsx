import type { Metadata, Viewport } from "next";
import "./globals.css";
import Nav from "@/components/Nav";
import ChatWidget from "@/components/ChatWidget";
import { getCurrentUser } from "@/lib/auth";

export const metadata: Metadata = {
  title: "SPM AI — Learning Management System",
  description:
    "AI-powered SPM platform: admin & moderator dashboards, AI categorization with human moderation, and a student portal with instant grading, an AI tutor and KBAT practice.",
};

export const viewport: Viewport = {
  width: "device-width",
  initialScale: 1,
  themeColor: "#1f50e0",
};

export default async function RootLayout({ children }: { children: React.ReactNode }) {
  const user = await getCurrentUser();
  const navUser = user ? { name: user.name, role: user.role } : null;

  return (
    <html lang="en">
      <body>
        <Nav user={navUser} />
        <main className="mx-auto max-w-6xl px-4 pb-24 pt-6 sm:pb-10">{children}</main>
        {/* Cikgu AI chat is for students. */}
        {user?.role === "student" && <ChatWidget />}
      </body>
    </html>
  );
}
