"use client";

import { useEffect, useRef, useState } from "react";
import { usePathname } from "next/navigation";
import MicButton from "./MicButton";
import FormattedText from "./FormattedText";
import Icon from "./Icon";

interface Attachment {
  dataUrl: string; // data:image/...;base64,XXXX
  name: string;
}
interface Message {
  role: "user" | "assistant";
  text: string;
  images?: Attachment[];
  byAi?: boolean;
}

// Other pages can open the chat with a preset prompt:
//   window.dispatchEvent(new CustomEvent("open-cikgu-chat", { detail: { prompt } }))
const OPEN_EVENT = "open-cikgu-chat";

export default function ChatWidget() {
  const pathname = usePathname();
  const [open, setOpen] = useState(false);
  const [messages, setMessages] = useState<Message[]>([]);
  const [input, setInput] = useState("");
  const [pending, setPending] = useState<Attachment[]>([]);
  const [loading, setLoading] = useState(false);
  const [capturing, setCapturing] = useState(false);
  const scrollRef = useRef<HTMLDivElement>(null);
  const fileRef = useRef<HTMLInputElement>(null);

  // Derive question context from the URL (/practice/[id]).
  const questionId = (() => {
    const m = pathname?.match(/^\/practice\/([^/]+)$/);
    return m ? m[1] : undefined;
  })();

  useEffect(() => {
    function onOpen(e: Event) {
      const detail = (e as CustomEvent).detail as { prompt?: string } | undefined;
      setOpen(true);
      if (detail?.prompt) setInput(detail.prompt);
    }
    window.addEventListener(OPEN_EVENT, onOpen);
    return () => window.removeEventListener(OPEN_EVENT, onOpen);
  }, []);

  useEffect(() => {
    scrollRef.current?.scrollTo({ top: scrollRef.current.scrollHeight, behavior: "smooth" });
  }, [messages, loading, open]);

  async function downscale(dataUrl: string, maxW = 1600): Promise<string> {
    return new Promise((resolve) => {
      const img = new Image();
      img.onload = () => {
        const scale = Math.min(1, maxW / img.width);
        const canvas = document.createElement("canvas");
        canvas.width = Math.round(img.width * scale);
        canvas.height = Math.round(img.height * scale);
        const ctx = canvas.getContext("2d");
        if (!ctx) return resolve(dataUrl);
        ctx.drawImage(img, 0, 0, canvas.width, canvas.height);
        resolve(canvas.toDataURL("image/jpeg", 0.92));
      };
      img.onerror = () => resolve(dataUrl);
      img.src = dataUrl;
    });
  }

  // Screenshot tool: capture the screen/tab via the browser, attach as a snippet.
  async function captureScreenshot() {
    setCapturing(true);
    try {
      const md = navigator.mediaDevices as MediaDevices & {
        getDisplayMedia?: (c?: Record<string, unknown>) => Promise<MediaStream>;
      };
      if (!md?.getDisplayMedia) {
        alert("Screen capture isn't supported in this browser. Use the attach button to add an image instead.");
        return;
      }
      // preferCurrentTab makes Chrome auto-select this tab (so it grabs the app
      // the student is looking at); selfBrowserSurface keeps our own tab in the
      // list for browsers that ignore preferCurrentTab.
      const stream = await md.getDisplayMedia({
        video: { displaySurface: "browser" },
        preferCurrentTab: true,
        selfBrowserSurface: "include",
        surfaceSwitching: "exclude",
        audio: false,
      });
      const video = document.createElement("video");
      video.srcObject = stream;
      await video.play();
      await new Promise((r) => setTimeout(r, 250)); // let a frame render
      const canvas = document.createElement("canvas");
      canvas.width = video.videoWidth;
      canvas.height = video.videoHeight;
      canvas.getContext("2d")?.drawImage(video, 0, 0);
      stream.getTracks().forEach((t) => t.stop());
      const dataUrl = await downscale(canvas.toDataURL("image/png"));
      setPending((p) => [...p, { dataUrl, name: "screenshot.jpg" }]);
      setOpen(true);
    } catch {
      /* user cancelled the picker */
    } finally {
      setCapturing(false);
    }
  }

  async function onPickFiles(e: React.ChangeEvent<HTMLInputElement>) {
    const files = Array.from(e.target.files ?? []);
    for (const f of files) {
      const dataUrl = await new Promise<string>((resolve) => {
        const reader = new FileReader();
        reader.onload = () => resolve(String(reader.result));
        reader.readAsDataURL(f);
      });
      const scaled = await downscale(dataUrl);
      setPending((p) => [...p, { dataUrl: scaled, name: f.name }]);
    }
    if (fileRef.current) fileRef.current.value = "";
  }

  function toImagePayload(att: Attachment) {
    const [meta, b64] = att.dataUrl.split(",");
    const mediaType = meta.match(/data:(.*?);/)?.[1] ?? "image/jpeg";
    return { mediaType, dataBase64: b64 };
  }

  async function send() {
    if (!input.trim() && pending.length === 0) return;
    const userMsg: Message = { role: "user", text: input.trim(), images: pending };
    const next = [...messages, userMsg];
    setMessages(next);
    setInput("");
    setPending([]);
    setLoading(true);

    try {
      const res = await fetch("/api/chat", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          questionId,
          pathHint: pathname,
          history: next.map((m) => ({
            role: m.role,
            text: m.text,
            images: (m.images ?? []).map(toImagePayload),
          })),
        }),
      });
      const data = await res.json();
      setMessages((prev) => [
        ...prev,
        { role: "assistant", text: data.reply ?? data.error ?? "(no reply)", byAi: data.byAi },
      ]);
    } catch {
      setMessages((prev) => [
        ...prev,
        { role: "assistant", text: "Network error, please try again." },
      ]);
    } finally {
      setLoading(false);
    }
  }

  return (
    <>
      {/* Launcher */}
      <button
        onClick={() => setOpen((o) => !o)}
        aria-label="Open Cikgu AI chat"
        className="fixed bottom-20 right-4 z-40 grid h-14 w-14 place-items-center rounded-full bg-gradient-to-br from-brand-600 to-accent-500 text-white shadow-lg transition hover:opacity-90 sm:bottom-6"
      >
        <Icon name={open ? "close" : "chat"} className="h-6 w-6" />
      </button>

      {open && (
        <div className="fixed bottom-36 right-4 z-40 flex h-[70vh] max-h-[560px] w-[min(92vw,400px)] flex-col overflow-hidden rounded-2xl border border-slate-200 bg-white shadow-2xl sm:bottom-24">
          {/* Header */}
          <div className="flex items-center justify-between bg-gradient-to-r from-brand-600 to-accent-600 px-4 py-3 text-white">
            <div className="flex items-center gap-2">
              <span className="grid h-8 w-8 place-items-center rounded-full bg-white/20"><Icon name="teacher" className="h-5 w-5" /></span>
              <div className="leading-tight">
                <div className="flex items-center gap-1.5 text-sm font-bold">Cikgu AI <span className="inline-block h-1.5 w-1.5 rounded-full bg-accent-300" /></div>
                <div className="text-[11px] text-white/80">
                  {questionId ? "Discussing this question" : "Ask me anything about SPM"}
                </div>
              </div>
            </div>
            <button onClick={() => setOpen(false)} aria-label="Close" className="text-white/80 hover:text-white">
              <Icon name="close" className="h-5 w-5" />
            </button>
          </div>

          {/* Messages */}
          <div ref={scrollRef} className="flex-1 space-y-3 overflow-y-auto bg-slate-50 p-3">
            {messages.length === 0 && (
              <div className="space-y-3 text-sm text-slate-500">
                <p>Hi! I&apos;m <strong>Cikgu AI</strong>. I can explain topics, walk through a question, show how to score full marks, or read a screenshot you&apos;re stuck on.</p>
                <p className="text-xs">Tap the camera to grab a screenshot, or the clip to attach an image, I&apos;ll read it and help.</p>
                <div className="flex flex-wrap gap-2">
                  {[
                    "Explain this topic simply",
                    "How do I score full marks?",
                    "Give me a hint, not the answer",
                    "Make me a practice question",
                    "What am I weak in?",
                  ].map((s) => (
                    <button
                      key={s}
                      onClick={() => setInput(s)}
                      className="rounded-full border border-slate-200 bg-white px-3 py-1 text-xs font-medium text-slate-600 hover:bg-slate-50"
                    >
                      {s}
                    </button>
                  ))}
                </div>
              </div>
            )}
            {messages.map((m, i) => (
              <div key={i} className={`flex ${m.role === "user" ? "justify-end" : "justify-start"}`}>
                <div
                  className={`max-w-[85%] rounded-2xl px-3 py-2 text-sm ${
                    m.role === "user" ? "bg-brand-600 text-white" : "border border-slate-200 bg-white text-slate-800"
                  }`}
                >
                  {m.images && m.images.length > 0 && (
                    <div className="mb-2 flex flex-wrap gap-2">
                      {m.images.map((img, j) => (
                        // eslint-disable-next-line @next/next/no-img-element
                        <img key={j} src={img.dataUrl} alt={img.name} className="h-24 rounded-lg border border-white/30 object-cover" />
                      ))}
                    </div>
                  )}
                  {m.role === "assistant"
                    ? <FormattedText text={m.text} className="text-sm leading-relaxed" />
                    : <p className="whitespace-pre-wrap">{m.text}</p>}
                  {m.role === "assistant" && m.byAi === false && (
                    <p className="mt-1 text-[10px] text-slate-400">offline mode</p>
                  )}
                </div>
              </div>
            ))}
            {loading && (
              <div className="flex justify-start">
                <div className="rounded-2xl border border-slate-200 bg-white px-3 py-2 text-sm text-slate-400">
                  Cikgu AI is thinking…
                </div>
              </div>
            )}
          </div>

          {/* Pending attachments */}
          {pending.length > 0 && (
            <div className="flex flex-wrap gap-2 border-t border-slate-100 bg-white p-2">
              {pending.map((att, i) => (
                <div key={i} className="relative">
                  {/* eslint-disable-next-line @next/next/no-img-element */}
                  <img src={att.dataUrl} alt={att.name} className="h-14 w-14 rounded-lg border border-slate-200 object-cover" />
                  <button
                    onClick={() => setPending((p) => p.filter((_, j) => j !== i))}
                    className="absolute -right-1 -top-1 grid h-5 w-5 place-items-center rounded-full bg-slate-800 text-white"
                    aria-label="Remove attachment"
                  >
                    <Icon name="close" className="h-3 w-3" />
                  </button>
                </div>
              ))}
            </div>
          )}

          {/* Composer */}
          <div className="border-t border-slate-200 bg-white p-2">
            <div className="flex items-end gap-1">
              <button
                onClick={captureScreenshot}
                disabled={capturing}
                title="Capture a screenshot"
                aria-label="Capture a screenshot"
                className="grid h-10 w-10 shrink-0 place-items-center rounded-xl text-slate-500 hover:bg-slate-100"
              >
                <Icon name="camera" className="h-5 w-5" />
              </button>
              <button
                onClick={() => fileRef.current?.click()}
                title="Attach an image"
                aria-label="Attach an image"
                className="grid h-10 w-10 shrink-0 place-items-center rounded-xl text-slate-500 hover:bg-slate-100"
              >
                <Icon name="paperclip" className="h-5 w-5" />
              </button>
              <input ref={fileRef} type="file" accept="image/*" multiple hidden onChange={onPickFiles} />
              <MicButton
                onText={(text) => setInput((v) => (v ? `${v} ${text}` : text))}
                title="Speak your question"
                className="h-10 w-10 shrink-0"
              />
              <textarea
                value={input}
                onChange={(e) => setInput(e.target.value)}
                onKeyDown={(e) => {
                  if (e.key === "Enter" && !e.shiftKey) {
                    e.preventDefault();
                    send();
                  }
                }}
                rows={1}
                placeholder="Ask Cikgu AI…"
                className="max-h-28 flex-1 resize-none rounded-xl border border-slate-300 px-3 py-2 text-sm outline-none focus:border-brand-500"
              />
              <button
                onClick={send}
                disabled={loading || (!input.trim() && pending.length === 0)}
                aria-label="Send message"
                className="grid h-10 w-10 shrink-0 place-items-center rounded-xl bg-brand-600 text-white disabled:opacity-40"
              >
                <Icon name="send" className="h-5 w-5" />
              </button>
            </div>
          </div>
        </div>
      )}
    </>
  );
}
