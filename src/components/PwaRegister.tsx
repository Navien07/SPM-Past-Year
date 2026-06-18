"use client";

import { useEffect, useState } from "react";

// Registers the service worker, surfaces an "Install app" button when the
// browser offers it, and lets students turn on push notifications (study
// reminders + admin broadcasts). All best-effort.

interface BeforeInstallPromptEvent extends Event {
  prompt: () => Promise<void>;
  userChoice: Promise<{ outcome: "accepted" | "dismissed" }>;
}

const VAPID_PUBLIC = process.env.NEXT_PUBLIC_VAPID_PUBLIC_KEY || "";

function urlBase64ToUint8Array(base64: string): Uint8Array {
  const padding = "=".repeat((4 - (base64.length % 4)) % 4);
  const b64 = (base64 + padding).replace(/-/g, "+").replace(/_/g, "/");
  const raw = atob(b64);
  return Uint8Array.from([...raw].map((c) => c.charCodeAt(0)));
}

export default function PwaRegister() {
  const [deferred, setDeferred] = useState<BeforeInstallPromptEvent | null>(null);
  const [installed, setInstalled] = useState(false);
  const [reg, setReg] = useState<ServiceWorkerRegistration | null>(null);

  useEffect(() => {
    if ("serviceWorker" in navigator) {
      navigator.serviceWorker.register("/sw.js").then(setReg).catch(() => {});
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
    try {
      if (!("Notification" in window) || !("serviceWorker" in navigator) || !("PushManager" in window)) {
        alert("Notifications aren't supported in this browser.");
        return;
      }
      const perm = await Notification.requestPermission();
      if (perm !== "granted") return;
      const registration = reg || (await navigator.serviceWorker.ready);

      if (VAPID_PUBLIC) {
        // Real Web Push subscription (works even when the app is closed).
        const existing = await registration.pushManager.getSubscription();
        const sub =
          existing ||
          (await registration.pushManager.subscribe({
            userVisibleOnly: true,
            applicationServerKey: urlBase64ToUint8Array(VAPID_PUBLIC) as BufferSource,
          }));
        await fetch("/api/push/subscribe", {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ subscription: sub.toJSON(), userAgent: navigator.userAgent }),
        });
      }
      registration.showNotification("SPM AI", { body: "✅ Peringatan dihidupkan. Jumpa lagi!", icon: "/icon-192.png" });
    } catch {
      /* ignore */
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
        <button onClick={install} className="btn-primary cursor-pointer px-3 py-1.5 text-xs">Install</button>
        <button onClick={enableReminders} className="cursor-pointer text-[11px] text-slate-500 hover:underline">Notifications</button>
      </div>
    </div>
  );
}
