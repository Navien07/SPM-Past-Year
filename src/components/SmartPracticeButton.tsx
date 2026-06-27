"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import Icon from "./Icon";

// Adaptive practice: asks the server for the next best question (due review →
// weakest topic → new) and navigates to it.
export default function SmartPracticeButton({ className = "btn-primary", label = "Smart practice" }: { className?: string; label?: string }) {
  const router = useRouter();
  const [loading, setLoading] = useState(false);
  const [msg, setMsg] = useState<string | null>(null);

  async function go() {
    setLoading(true);
    setMsg(null);
    try {
      const res = await fetch("/api/next");
      const data = await res.json();
      if (data.questionId) {
        router.push(`/practice/${data.questionId}`);
      } else {
        setMsg("You've attempted everything available, generate fresh AI questions!");
      }
    } finally {
      setLoading(false);
    }
  }

  return (
    <>
      <button onClick={go} disabled={loading} className={`${className} inline-flex items-center gap-1.5`}>
        {!loading && <Icon name="arrow" className="h-4 w-4" />}
        {loading ? "Finding…" : label}
      </button>
      {msg && <p className="mt-1 text-xs text-slate-500">{msg}</p>}
    </>
  );
}
