"use client";

import { useEffect, useRef } from "react";

// Lightweight canvas confetti. Mounted once globally; fire from anywhere with:
//   window.dispatchEvent(new CustomEvent("spm-celebrate", { detail: { intensity } }))
// Respects prefers-reduced-motion (does nothing).
interface Particle { x: number; y: number; vx: number; vy: number; rot: number; vr: number; size: number; color: string; life: number }
const COLORS = ["#2D5BFF", "#27d3ac", "#FFD23F", "#FF5D73", "#7c3aed", "#16B981"];

export default function Confetti() {
  const ref = useRef<HTMLCanvasElement>(null);

  useEffect(() => {
    const canvas = ref.current;
    if (!canvas) return;
    if (window.matchMedia?.("(prefers-reduced-motion: reduce)").matches) return;
    const ctx = canvas.getContext("2d");
    if (!ctx) return;

    let particles: Particle[] = [];
    let raf = 0;

    function resize() {
      canvas!.width = window.innerWidth;
      canvas!.height = window.innerHeight;
    }
    resize();
    window.addEventListener("resize", resize);

    function burst(intensity = 1) {
      const n = Math.round(90 * intensity);
      const cx = window.innerWidth / 2;
      for (let i = 0; i < n; i++) {
        const angle = (Math.PI * 2 * i) / n + Math.random();
        const speed = 6 + Math.random() * 9;
        particles.push({
          x: cx + (Math.random() - 0.5) * 120,
          y: window.innerHeight * 0.32,
          vx: Math.cos(angle) * speed * (0.5 + Math.random()),
          vy: Math.sin(angle) * speed - 4,
          rot: Math.random() * Math.PI,
          vr: (Math.random() - 0.5) * 0.4,
          size: 6 + Math.random() * 6,
          color: COLORS[(Math.random() * COLORS.length) | 0],
          life: 1,
        });
      }
      if (!raf) raf = requestAnimationFrame(tick);
    }

    function tick() {
      ctx!.clearRect(0, 0, canvas!.width, canvas!.height);
      particles.forEach((p) => {
        p.vy += 0.25; // gravity
        p.vx *= 0.99;
        p.x += p.vx;
        p.y += p.vy;
        p.rot += p.vr;
        p.life -= 0.012;
        ctx!.save();
        ctx!.globalAlpha = Math.max(0, p.life);
        ctx!.translate(p.x, p.y);
        ctx!.rotate(p.rot);
        ctx!.fillStyle = p.color;
        ctx!.fillRect(-p.size / 2, -p.size / 2, p.size, p.size * 0.6);
        ctx!.restore();
      });
      particles = particles.filter((p) => p.life > 0 && p.y < canvas!.height + 40);
      if (particles.length > 0) raf = requestAnimationFrame(tick);
      else { raf = 0; ctx!.clearRect(0, 0, canvas!.width, canvas!.height); }
    }

    const onCelebrate = (e: Event) => burst((e as CustomEvent).detail?.intensity ?? 1);
    window.addEventListener("spm-celebrate", onCelebrate);
    return () => {
      window.removeEventListener("resize", resize);
      window.removeEventListener("spm-celebrate", onCelebrate);
      if (raf) cancelAnimationFrame(raf);
    };
  }, []);

  return <canvas ref={ref} className="pointer-events-none fixed inset-0 z-[60]" aria-hidden="true" />;
}

// Helper for callers.
export function celebrate(intensity = 1) {
  if (typeof window !== "undefined") window.dispatchEvent(new CustomEvent("spm-celebrate", { detail: { intensity } }));
}
