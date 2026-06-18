// Lightweight in-memory rate limiter for auth endpoints. Note: on serverless
// this is per-instance (soft limit) — good enough for a pilot; swap for a
// Redis/Upstash or DB-backed limiter for hard guarantees at large scale.
const buckets = new Map<string, { count: number; reset: number }>();

export function rateLimit(key: string, max: number, windowMs: number): boolean {
  const now = Date.now();
  const b = buckets.get(key);
  if (!b || now > b.reset) {
    buckets.set(key, { count: 1, reset: now + windowMs });
    return true; // allowed
  }
  if (b.count >= max) return false; // blocked
  b.count++;
  return true;
}

// Occasionally clear stale buckets to bound memory.
setInterval(() => {
  const now = Date.now();
  for (const [k, v] of buckets) if (now > v.reset) buckets.delete(k);
}, 10 * 60 * 1000).unref?.();
