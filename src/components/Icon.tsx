import React from "react";

// Lightweight Lucide-style SVG icon set (24x24, currentColor stroke). Replaces
// emoji icons across the app for a consistent, premium look.
const S: React.SVGProps<SVGSVGElement> = {
  fill: "none", stroke: "currentColor", strokeWidth: 1.8, strokeLinecap: "round", strokeLinejoin: "round",
};

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
  close: <path d="M18 6 6 18M6 6l12 12" />,
  send: <><path d="M22 2 11 13" /><path d="M22 2 15 22l-4-9-9-4Z" /></>,
  paperclip: <path d="M21 12.5 12.5 21a5 5 0 0 1-7-7l8.5-8.5a3.5 3.5 0 0 1 5 5L10.5 18a2 2 0 0 1-3-3l7.5-7.5" />,
  camera: <><path d="M3 8a2 2 0 0 1 2-2h2l1.5-2h7L17 6h2a2 2 0 0 1 2 2v10a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2Z" /><circle cx="12" cy="13" r="3.5" /></>,
  sparkles: <><path d="M12 3l1.8 5.2L19 10l-5.2 1.8L12 17l-1.8-5.2L5 10l5.2-1.8Z" /><path d="M19 16l.8 2.2L22 19l-2.2.8L19 22l-.8-2.2L16 19l2.2-.8Z" /></>,
  trash: <><path d="M4 7h16" /><path d="M9 7V5a1 1 0 0 1 1-1h4a1 1 0 0 1 1 1v2" /><path d="M6 7l1 13a1 1 0 0 0 1 1h8a1 1 0 0 0 1-1l1-13" /><path d="M10 11v6M14 11v6" /></>,
  bell: <><path d="M6 9a6 6 0 0 1 12 0c0 5 2 6 2 6H4s2-1 2-6Z" /><path d="M10 20a2 2 0 0 0 4 0" /></>,
  lock: <><rect x="4" y="11" width="16" height="9" rx="2" /><path d="M8 11V8a4 4 0 0 1 8 0v3" /></>,
  alert: <><path d="M10.3 4 2.6 18a2 2 0 0 0 1.7 3h15.4a2 2 0 0 0 1.7-3L13.7 4a2 2 0 0 0-3.4 0Z" /><path d="M12 9v4M12 17h.01" /></>,
  doc: <><path d="M14 3H7a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2V8Z" /><path d="M14 3v5h5" /></>,
  clock: <><circle cx="12" cy="12" r="9" /><path d="M12 7v5l3 2" /></>,
  book: <><path d="M4 5a2 2 0 0 1 2-2h13v16H6a2 2 0 0 0-2 2Z" /><path d="M19 17H6a2 2 0 0 0-2 2" /></>,
  download: <><path d="M12 4v12" /><path d="M7 11l5 5 5-5" /><path d="M5 20h14" /></>,
  user: <><circle cx="12" cy="8" r="3.5" /><path d="M4.5 20a7.5 7.5 0 0 1 15 0" /></>,
  teacher: <><circle cx="12" cy="7" r="3" /><path d="M5 21v-1a7 7 0 0 1 14 0v1" /><path d="M9 11l3 2 3-2" /></>,
  strength: <><path d="M5 9v6M19 9v6M5 12h14" /><path d="M3 10v4M21 10v4" /></>,
  star: <path d="m12 3 2.6 5.6 6 .6-4.5 4 1.3 6L12 16.9 6.6 19.2l1.3-6-4.5-4 6-.6Z" />,
  volume: <><path d="M11 5 6 9H3v6h3l5 4Z" /><path d="M16 9a4 4 0 0 1 0 6" /><path d="M18.5 7a7 7 0 0 1 0 10" /></>,
  wifioff: <><path d="M2 2l20 20" /><path d="M8.5 16.5a5 5 0 0 1 7 0" /><path d="M5 12.9a10 10 0 0 1 3.5-2.3M19 12.9a10 10 0 0 0-7-2.9" /><path d="M2 8.8a16 16 0 0 1 5-3M22 8.8a16 16 0 0 0-6-3.5" /><path d="M12 20h.01" /></>,
  map: <><path d="M9 4 3 6v14l6-2 6 2 6-2V4l-6 2Z" /><path d="M9 4v14M15 6v14" /></>,
  package: <><path d="M21 8 12 3 3 8v8l9 5 9-5Z" /><path d="m3 8 9 5 9-5M12 13v8" /></>,
  repeat: <><path d="M17 2l4 4-4 4" /><path d="M3 11V9a4 4 0 0 1 4-4h14" /><path d="M7 22l-4-4 4-4" /><path d="M21 13v2a4 4 0 0 1-4 4H3" /></>,
  compass: <><circle cx="12" cy="12" r="9" /><polygon points="16 8 13.5 13.5 8 16 10.5 10.5" /></>,
  mail: <><rect x="3" y="5" width="18" height="14" rx="2" /><path d="m3 7 9 6 9-6" /></>,
  plus: <path d="M12 5v14M5 12h14" />,
  eye: <><path d="M2 12s4-7 10-7 10 7 10 7-4 7-10 7-10-7-10-7Z" /><circle cx="12" cy="12" r="3" /></>,
  shield: <><path d="M12 3 5 6v6c0 4 3 7 7 9 4-2 7-5 7-9V6Z" /></>,
  x: <path d="M18 6 6 18M6 6l12 12" />,
};

export default function Icon({ name, className = "h-5 w-5" }: { name: string; className?: string }) {
  const node = PATHS[name] ?? PATHS.help;
  return (
    <svg viewBox="0 0 24 24" className={className} aria-hidden="true" {...S}>
      {node}
    </svg>
  );
}
