"use client";

import { useEffect, useRef, useState } from "react";
import Icon from "./Icon";

// A scratch/working pad: students sketch diagrams or write formulas by hand
// (mouse, stylus or finger) instead of typing everything. They can clear,
// undo, switch pen colour/eraser, and send the working to Cikgu AI to discuss.
const COLORS = ["#0f172a", "#2563eb", "#dc2626", "#16a34a"];

export default function WorkingPad() {
  const [open, setOpen] = useState(false);
  const [color, setColor] = useState(COLORS[1]);
  const [erasing, setErasing] = useState(false);
  const canvasRef = useRef<HTMLCanvasElement>(null);
  const drawing = useRef(false);
  const last = useRef<{ x: number; y: number } | null>(null);
  const undoStack = useRef<string[]>([]);

  // Size the canvas to its container at device-pixel resolution.
  useEffect(() => {
    if (!open) return;
    const canvas = canvasRef.current;
    if (!canvas) return;
    const ctx = canvas.getContext("2d");
    if (!ctx) return;
    const dpr = window.devicePixelRatio || 1;
    const rect = canvas.getBoundingClientRect();
    const prev = canvas.toDataURL();
    canvas.width = rect.width * dpr;
    canvas.height = 320 * dpr;
    ctx.scale(dpr, dpr);
    ctx.lineCap = "round";
    ctx.lineJoin = "round";
    // Repaint white background (so exported image isn't transparent).
    ctx.fillStyle = "#ffffff";
    ctx.fillRect(0, 0, canvas.width, canvas.height);
    if (undoStack.current.length) {
      const img = new Image();
      img.onload = () => ctx.drawImage(img, 0, 0, rect.width, 320);
      img.src = prev;
    }
  }, [open]);

  function pos(e: React.PointerEvent) {
    const r = canvasRef.current!.getBoundingClientRect();
    return { x: e.clientX - r.left, y: e.clientY - r.top };
  }

  function start(e: React.PointerEvent) {
    e.preventDefault();
    const canvas = canvasRef.current!;
    undoStack.current.push(canvas.toDataURL());
    if (undoStack.current.length > 25) undoStack.current.shift();
    drawing.current = true;
    last.current = pos(e);
    canvas.setPointerCapture(e.pointerId);
  }
  function move(e: React.PointerEvent) {
    if (!drawing.current) return;
    const ctx = canvasRef.current!.getContext("2d")!;
    const p = pos(e);
    ctx.strokeStyle = erasing ? "#ffffff" : color;
    ctx.lineWidth = erasing ? 18 : 2.5;
    ctx.beginPath();
    ctx.moveTo(last.current!.x, last.current!.y);
    ctx.lineTo(p.x, p.y);
    ctx.stroke();
    last.current = p;
  }
  function end() {
    drawing.current = false;
    last.current = null;
  }

  function undo() {
    const canvas = canvasRef.current;
    const prev = undoStack.current.pop();
    if (!canvas || !prev) return;
    const ctx = canvas.getContext("2d")!;
    const rect = canvas.getBoundingClientRect();
    const img = new Image();
    img.onload = () => { ctx.clearRect(0, 0, canvas.width, canvas.height); ctx.fillStyle = "#fff"; ctx.fillRect(0, 0, canvas.width, canvas.height); ctx.drawImage(img, 0, 0, rect.width, 320); };
    img.src = prev;
  }
  function clear() {
    const canvas = canvasRef.current;
    if (!canvas) return;
    undoStack.current.push(canvas.toDataURL());
    const ctx = canvas.getContext("2d")!;
    ctx.fillStyle = "#fff";
    ctx.fillRect(0, 0, canvas.width, canvas.height);
  }
  function askAi() {
    const dataUrl = canvasRef.current?.toDataURL("image/png");
    if (!dataUrl) return;
    window.dispatchEvent(new CustomEvent("open-cikgu-chat", {
      detail: { prompt: "Here's my working, please check it and tell me if I'm on the right track.", image: dataUrl },
    }));
  }

  return (
    <div className="card p-4">
      <button onClick={() => setOpen((o) => !o)} className="flex w-full items-center justify-between text-sm font-semibold text-slate-700">
        <span className="inline-flex items-center gap-1.5"><Icon name="practice" className="h-4 w-4" /> Working pad (draw / write formulas)</span>
        <Icon name="arrow" className={`h-4 w-4 text-slate-400 transition-transform ${open ? "rotate-90" : ""}`} />
      </button>

      {open && (
        <div className="mt-3">
          <div className="mb-2 flex flex-wrap items-center gap-2">
            {COLORS.map((c) => (
              <button
                key={c}
                onClick={() => { setColor(c); setErasing(false); }}
                aria-label={`Pen ${c}`}
                className={`h-6 w-6 rounded-full border-2 ${color === c && !erasing ? "border-slate-700" : "border-white"} cursor-pointer`}
                style={{ backgroundColor: c }}
              />
            ))}
            <button onClick={() => setErasing((e) => !e)} className={`rounded-lg border px-2.5 py-1 text-xs font-medium cursor-pointer ${erasing ? "border-brand-400 bg-brand-50 text-brand-700" : "border-slate-200 text-slate-600"}`}>Eraser</button>
            <button onClick={undo} className="rounded-lg border border-slate-200 px-2.5 py-1 text-xs font-medium text-slate-600 cursor-pointer">Undo</button>
            <button onClick={clear} className="rounded-lg border border-slate-200 px-2.5 py-1 text-xs font-medium text-slate-600 cursor-pointer">Clear</button>
            <button onClick={askAi} className="ml-auto inline-flex items-center gap-1.5 rounded-lg bg-brand-600 px-3 py-1 text-xs font-semibold text-white cursor-pointer">
              <Icon name="chat" className="h-3.5 w-3.5" /> Ask Cikgu AI
            </button>
          </div>
          <canvas
            ref={canvasRef}
            onPointerDown={start}
            onPointerMove={move}
            onPointerUp={end}
            onPointerLeave={end}
            className="h-[320px] w-full touch-none rounded-xl border border-slate-200 bg-white"
            style={{ touchAction: "none" }}
          />
          <p className="mt-1.5 text-xs text-slate-400">Sketch diagrams or write your steps by hand. This is your scratch space, type your final answer below to be graded.</p>
        </div>
      )}
    </div>
  );
}
