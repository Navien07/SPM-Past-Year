"use client";

import { useEffect, useRef, useState } from "react";

// Animated circular readiness gauge: the ring sweeps to `value` and the centre
// number counts up, once, when it scrolls into view. Respects reduced motion.
export default function ReadinessRing({
  value,
  grade,
  color,
  size = 168,
}: {
  value: number;
  grade: string;
  color: string;
  size?: number;
}) {
  const [shown, setShown] = useState(0);
  const ref = useRef<SVGSVGElement>(null);
  const stroke = 12;
  const r = (size - stroke) / 2;
  const c = 2 * Math.PI * r;

  useEffect(() => {
    const reduce = window.matchMedia?.("(prefers-reduced-motion: reduce)").matches;
    if (reduce) {
      setShown(value);
      return;
    }
    let raf = 0;
    let start = 0;
    const dur = 1100;
    const el = ref.current;
    let running = false;
    const step = (ts: number) => {
      if (!start) start = ts;
      const p = Math.min(1, (ts - start) / dur);
      const eased = 1 - Math.pow(1 - p, 3);
      setShown(Math.round(value * eased));
      if (p < 1) raf = requestAnimationFrame(step);
    };
    const io = new IntersectionObserver(
      (entries) => {
        if (entries[0].isIntersecting && !running) {
          running = true;
          raf = requestAnimationFrame(step);
        }
      },
      { threshold: 0.4 },
    );
    if (el) io.observe(el);
    return () => {
      cancelAnimationFrame(raf);
      io.disconnect();
    };
  }, [value]);

  const offset = c - (shown / 100) * c;

  return (
    <svg ref={ref} width={size} height={size} viewBox={`0 0 ${size} ${size}`} className="shrink-0">
      <circle cx={size / 2} cy={size / 2} r={r} fill="none" stroke="#e2e8f0" strokeWidth={stroke} />
      <circle
        cx={size / 2}
        cy={size / 2}
        r={r}
        fill="none"
        stroke={color}
        strokeWidth={stroke}
        strokeLinecap="round"
        strokeDasharray={c}
        strokeDashoffset={offset}
        transform={`rotate(-90 ${size / 2} ${size / 2})`}
        style={{ transition: "stroke-dashoffset 80ms linear" }}
      />
      <text x="50%" y="44%" textAnchor="middle" dominantBaseline="central" className="fill-slate-900 font-display" style={{ fontSize: size * 0.26, fontWeight: 800 }}>
        {grade}
      </text>
      <text x="50%" y="64%" textAnchor="middle" dominantBaseline="central" className="fill-slate-400" style={{ fontSize: size * 0.1, fontWeight: 600 }}>
        {shown}% ready
      </text>
    </svg>
  );
}
