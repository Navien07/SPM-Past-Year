// SPM AI service worker — installable PWA + resilient offline shell.
// Strategy: network-first for navigations (always prefer fresh content; fall
// back to cache/offline page when the network is down), cache-first for static
// assets. Intentionally conservative — never caches API responses so grading,
// auth and the AI tutor are always live.

const CACHE = "spm-ai-v1";
const PRECACHE = ["/offline", "/icon.svg", "/favicon.svg", "/manifest.webmanifest"];

self.addEventListener("install", (event) => {
  event.waitUntil(
    caches.open(CACHE).then((c) => c.addAll(PRECACHE)).catch(() => {}),
  );
  self.skipWaiting();
});

self.addEventListener("activate", (event) => {
  event.waitUntil(
    caches.keys().then((keys) =>
      Promise.all(keys.filter((k) => k !== CACHE).map((k) => caches.delete(k))),
    ),
  );
  self.clients.claim();
});

self.addEventListener("fetch", (event) => {
  const { request } = event;
  if (request.method !== "GET") return;
  const url = new URL(request.url);
  if (url.origin !== self.location.origin) return;
  // Never intercept API / auth traffic — always go to the network.
  if (url.pathname.startsWith("/api/")) return;

  // Page navigations: network-first, fall back to cache then offline page.
  if (request.mode === "navigate") {
    event.respondWith(
      fetch(request)
        .then((res) => {
          const copy = res.clone();
          caches.open(CACHE).then((c) => c.put(request, copy)).catch(() => {});
          return res;
        })
        .catch(() => caches.match(request).then((m) => m || caches.match("/offline"))),
    );
    return;
  }

  // Static assets (_next, icons, css, js): cache-first.
  if (/\/_next\/|\.(?:js|css|svg|png|jpg|jpeg|webp|woff2?)$/.test(url.pathname)) {
    event.respondWith(
      caches.match(request).then(
        (cached) =>
          cached ||
          fetch(request).then((res) => {
            const copy = res.clone();
            caches.open(CACHE).then((c) => c.put(request, copy)).catch(() => {});
            return res;
          }),
      ),
    );
  }
});

// Daily study reminder (shown when the app/SW is active and a notification is
// posted by the page). Clicking it focuses/opens the app.
self.addEventListener("notificationclick", (event) => {
  event.notification.close();
  event.waitUntil(
    self.clients.matchAll({ type: "window" }).then((list) => {
      for (const c of list) if ("focus" in c) return c.focus();
      return self.clients.openWindow("/");
    }),
  );
});
