"use client";

import { useState } from "react";
import { useLang } from "@/lib/useLang";
import { t } from "@/lib/i18n";

// Bookmark toggle + read-aloud for a question (used on the question page).
export default function QuestionTools({
  questionId,
  text,
  initialBookmarked,
}: {
  questionId: string;
  text: string;
  initialBookmarked: boolean;
}) {
  const lang = useLang();
  const [bookmarked, setBookmarked] = useState(initialBookmarked);
  const [busy, setBusy] = useState(false);
  const [speaking, setSpeaking] = useState(false);

  async function toggleBookmark() {
    setBusy(true);
    try {
      const res = await fetch("/api/bookmark", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ questionId }),
      });
      const data = await res.json();
      if (res.ok) setBookmarked(data.bookmarked);
    } finally {
      setBusy(false);
    }
  }

  function readAloud() {
    if (typeof window === "undefined" || !window.speechSynthesis) return;
    if (speaking) {
      window.speechSynthesis.cancel();
      setSpeaking(false);
      return;
    }
    const u = new SpeechSynthesisUtterance(text);
    // Prefer a Malay voice if available (content is often BM).
    const voices = window.speechSynthesis.getVoices();
    const ms = voices.find((v) => /ms|malay/i.test(v.lang) || /malay/i.test(v.name));
    if (ms) u.lang = ms.lang, (u.voice = ms);
    u.onend = () => setSpeaking(false);
    setSpeaking(true);
    window.speechSynthesis.speak(u);
  }

  return (
    <div className="flex flex-wrap gap-2">
      <button onClick={toggleBookmark} disabled={busy} className="btn-ghost">
        {bookmarked ? `★ ${t(lang, "qt.bookmarked")}` : `☆ ${t(lang, "qt.bookmark")}`}
      </button>
      <button onClick={readAloud} className="btn-ghost">
        {speaking ? `■ ${t(lang, "qt.stop")}` : `🔊 ${t(lang, "qt.read")}`}
      </button>
    </div>
  );
}
