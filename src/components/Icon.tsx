import React from "react";

// Lightweight Lucide-style SVG icon set (24x24, currentColor stroke). Replaces
// emoji icons across the app for a consistent, premium look.
type P = Record<string, never>;
const S = { fill: "none", stroke: "currentColor", strokeWidth: 1.8, strokeLinecap: "round" as const, strokeLinejoin: "round" as const };

const PATHS: Record<string, React.ReactNode> = {
  home: <><path d="M3 10.5 12 3l9 7.5" /><path d="M5 9.5V21h14V9.5" /></>,
  practice: <><path d="M12 20h9" /><path d="M16.5 3.5a2.1 2.1 0 0 1 3 3L7 19l-4 1 1-4Z" /></>,
  papers: <><path d="M14 3H7a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2V8Z" /><path d="M14 3v5h5" /><path d="M9 13h6M9 17h6" /></>,
  exam: <><circle cx="12" cy="13" r="8" /><path d="M12 13V9" /><path d="M9 2h6" /></>,
  review: <><path d="M3 12a9 9 0 0 1 15-6.7L21 8" /><path d="M21 3v5h-5" /><path d="M21 12a9 9 0 0 1-15 6.7L3 16" /><path d="M3 21v-5h5" /></>,
  tutor: <><circle cx="12" cy="12" r="9" /><polygon points="15.5 8.5 13.5 13.5 8.5 15.5 10.5 10.5" /></>,
  progress: <><path d="M3 3v18h18" /><path d="M7 15l3-3 3 2 4-5" /></>,
  syllabus: <><path d="M3 5a2 2 0 0 1 2-2h6v16H5a2 2 0 0 0-2 2Z" /><path d="M21 5a2 2 0 0 0-2-2h-6v16h6a2 2 0 0 1 2 2Z" /></>,
  brain: <><path d="M8 4a3 3 0 0 0-3 3 3 3 0 0 0-1 5 3 3 0 0 0 2 4 3 3 0 0 0 6 0V5a3 3 0 0 0-3-3Z" /><path d="M16 4a3 3 0 0 1 3 3 3 3 0 0 1 1 5 3 3 0 0 1-2 4 3 3 0 0 1-6 0" /></>,
  users: <><circle cx="9" cy="8" r="3.2" /><path d="M3.5 20a5.5 5.5 0 0 1 11 0" /><path d="M16 5.5a3 3 0 0 1 0 5.8" /><path d="M17 14.5a5.5 5.5 0 0 1 3.5 5.5" /></>,
  class: <><path d="M3 4h18v12H3z" /><path d="M12 16v4M8 20h8" /></>,
  folder: <><path d="M3 7a2 2 0 0 1 2-2h4l2 2h8a2 2 0 0 1 2 2v8a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2Z" /></>,
  activity: <><path d="M6 2h9l5 5v15H6Z" /><path d="M14 2v6h6" /><path d="M9 13h6M9 17h4" /></>,
  help: <><circle cx="12" cy="12" r="9" /><path d="M9.5 9.5a2.5 2.5 0 1 1 3.5 2.3c-.8.4-1 .8-1 1.7" /><path d="M12 17h.01" /></>,
  generate: <><path d="M12 3v4M12 17v4M3 12h4M17 12h4" /><path d="M12 8a4 4 0 0 0 4 4 4 4 0 0 0-4 4 4 4 0 0 0-4-4 4 4 0 0 0 4-4Z" /></>,
  mock: <><path d="M9 3h6" /><path d="M10 3v6l-5 9a2 2 0 0 0 2 3h10a2 2 0 0 0 2-3l-5-9V3" /><path d="M7.5 15h9" /></>,
  assignments: <><rect x="6" y="4" width="12" height="17" rx="2" /><path d="M9 4V3h6v1" /><path d="M9 10h6M9 14h4" /></>,
  check: <path d="M20 6 9 17l-5-5" />,
  arrow: <path d="M5 12h14M13 6l6 6-6 6" />,
  search: <><circle cx="11" cy="11" r="7" /><path d="m21 21-4.3-4.3" /></>,
  signout: <><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4" /><path d="M16 17l5-5-5-5" /><path d="M21 12H9" /></>,
  bolt: <path d="M13 2 3 14h7l-1 8 10-12h-7l1-8z" />,
  chat: <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z" />,
  flame: <path d="M12 3c1.5 3 4 4.5 4 8a4 4 0 0 1-8 0c0-1.2.5-2.2 1.2-3C9 9.5 10.5 7 12 3Z" />,
  bookmark: <path d="M6 3h12v18l-6-4-6 4Z" />,
  upload: <><path d="M12 16V4" /><path d="M7 9l5-5 5 5" /><path d="M5 20h14" /></>,
};

export default function Icon({ name, className = "h-5 w-5" }: { name: string; className?: string }) {
  const node = PATHS[name] ?? PATHS.help;
  return (
    <svg viewBox="0 0 24 24" className={className} aria-hidden="true" {...(S as P)}>
      {node}
    </svg>
  );
}
