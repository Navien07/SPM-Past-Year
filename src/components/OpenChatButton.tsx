"use client";

// Opens the global Cikgu AI chat, optionally with a preset prompt.
export default function OpenChatButton({
  prompt,
  label,
  className = "btn-primary",
}: {
  prompt?: string;
  label: string;
  className?: string;
}) {
  return (
    <button
      onClick={() => window.dispatchEvent(new CustomEvent("open-cikgu-chat", { detail: { prompt } }))}
      className={className}
    >
      {label}
    </button>
  );
}
