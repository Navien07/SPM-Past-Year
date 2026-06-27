"use client";

import { useState } from "react";
import { LANG_COOKIE, type Lang } from "@/lib/i18n";

// Flips the UI language (BM ⇄ English). Writes the cookie then does a full
// reload, that re-renders Server Components AND re-mounts client components
// (which read the language on mount), so the whole UI switches at once.
export default function LangToggle({ lang }: { lang: Lang }) {
  const [busy, setBusy] = useState(false);
  const next: Lang = lang === "bm" ? "en" : "bm";

  function toggle() {
    setBusy(true);
    // 1 year, root scope.
    document.cookie = `${LANG_COOKIE}=${next}; path=/; max-age=${60 * 60 * 24 * 365}; samesite=lax`;
    window.location.reload();
  }

  return (
    <button
      onClick={toggle}
      disabled={busy}
      title={next === "bm" ? "Tukar ke Bahasa Melayu" : "Switch to English"}
      className="cursor-pointer rounded-lg border border-slate-200 px-2 py-1.5 text-xs font-bold text-slate-600 hover:bg-slate-100"
    >
      {lang === "bm" ? "EN" : "BM"}
    </button>
  );
}

