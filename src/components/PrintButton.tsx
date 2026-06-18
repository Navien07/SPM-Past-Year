"use client";

// Triggers the browser's print dialog → "Save as PDF". Zero-dependency, works
// on every device. The print stylesheet (globals.css @media print) hides nav.
export default function PrintButton({ label = "Download / Print PDF" }: { label?: string }) {
  return (
    <button onClick={() => window.print()} className="btn-primary no-print cursor-pointer">
      <svg viewBox="0 0 24 24" className="h-5 w-5" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" aria-hidden="true">
        <path d="M6 9V2h12v7M6 18H4a2 2 0 0 1-2-2v-5a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v5a2 2 0 0 1-2 2h-2" />
        <path d="M6 14h12v8H6z" />
      </svg>
      {label}
    </button>
  );
}
