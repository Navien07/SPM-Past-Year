"use client";

import { useLang } from "@/lib/useLang";
import { t } from "@/lib/i18n";

// Opens the global Cikgu AI chat with a preset prompt. The chat widget reads
// the question id from the URL (/practice/[id]) for full context.
export default function ExplainButton({ label }: { label?: string }) {
  const lang = useLang();
  return (
    <button
      onClick={() =>
        window.dispatchEvent(
          new CustomEvent("open-cikgu-chat", {
            detail: { prompt: "Explain this question to me and how to score full marks." },
          }),
        )
      }
      className="btn-ghost"
    >
      🧑‍🏫 {label ?? t(lang, "explain.label")}
    </button>
  );
}
