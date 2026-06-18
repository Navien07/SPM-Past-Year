"use client";

import { useEffect, useState } from "react";

// Registers the service worker, surfaces an "Install app" button when the
// browser offers it, and lets students opt in to a daily study reminder.
// All best-effort: silently no-ops where the platform doesn't support it.

interface BeforeInstallPromptEvent extends Event {
  prompt: () => Promise<void>;
  userChoice: Promise<{ outcome: "accepted" | "dismissed" }>;
}

const REMINDER_KEY = "spm_reminder_optin";

export default function PwaRegister() {
  const [deferred, setDeferred] = useState<BeforeInstallPromptEvent | null>(null);
  const [installed, setInstalled] = useState(false);

  useEffect(() => {
    if ("serviceWorker" in navigator) {
      navigator.serviceWorker.register("/sw.js").catch(() => {});
    }
    const onPrompt = (e: Event) => {
      e.preventDefault();
      setDeferred(e as BeforeInstallPromptEvent);
    };
    const onInstalled = () => {
      setInstalled(true);
      setDeferred(null);
    };
    window.addEventListener("beforeinstallprompt", onPrompt);
    window.addEventListener("appinstalled", onInstalled);

    // If the student opted into reminders, fire one per day on open.
    try {
      if (localStorage.getItem(REMINDER_KEY) === "1" && "Notification" in window && Notification.permission === "granted") {
        const last = localStorage.getItem("spm_reminder_last");
        const today = new Date().toDateString();
        if (last !== today) {
          new Notification("SPM AI", { body: "📚 Masa untuk berlatih hari ini! Teruskan streak anda.", icon: "/icon.svg" });
          localStorage.setItem("spm_reminder_last", today);
        }
      }
    } catch {
      /* ignore */
    }

    return () => {
      window.removeEventListener("beforeinstallprompt", onPrompt);
      window.removeEventListener("appinstalled", onInstalled);
    };
  }, []);

  async function install() {
    if (!deferred) return;
    await deferred.prompt();
    await deferred.userChoice;
    setDeferred(null);
  }

  async function enableReminders() {
    if (!("Notification" in window)) return;
    const perm = await Notification.requestPermission();
    if (perm === "granted") {
      localStorage.setItem(REMINDER_KEY, "1");
      new Notification("SPM AI", { body: "✅ Peringatan harian dihidupkan. Jumpa esok!", icon: "/icon.svg" });
    }
  }

  if (installed || !deferred) return null;

  return (
    <div className="fixed inset-x-3 bottom-3 z-30 mx-auto flex max-w-sm items-center gap-3 rounded-2xl border border-slate-200 bg-white p-3 shadow-lg sm:left-4 sm:right-auto">
      {/* eslint-disable-next-line @next/next/no-img-element */}
      <img src="/icon.svg" alt="SPM AI" className="h-10 w-10 rounded-xl" />
      <div className="min-w-0 flex-1">
        <p className="text-sm font-semibold">Install SPM AI</p>
        <p className="text-xs text-slate-500">Add to your home screen — practise offline-ready, like an app.</p>
      </div>
      <div className="flex flex-col gap-1">
        <button onClick={install} className="btn-primary px-3 py-1.5 text-xs">Install</button>
        <button onClick={enableReminders} className="text-[11px] text-slate-500 hover:underline">Daily reminder</button>
      </div>
    </div>
  );
}
