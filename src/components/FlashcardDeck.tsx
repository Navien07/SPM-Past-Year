"use client";

import { useMemo, useState } from "react";
import Icon from "./Icon";
import { celebrate } from "./Confetti";

export interface Flashcard {
  id: string;
  stem: string;
  options: { key: string; text: string }[];
  answer: string | null;
  markingScheme: string | null;
  marks: number;
  type: string;
  topic: string | null;
}

// A self-contained study deck: flip to reveal the answer, then mark "Got it"
// (advance) or "Review again" (requeues the card later in the session). No
// server round-trips, no new tables; pure in-session spaced repetition.
export default function FlashcardDeck({ cards }: { cards: Flashcard[] }) {
  const shuffled = useMemo(() => cards, [cards]);
  const [queue, setQueue] = useState<number[]>(() => shuffled.map((_, i) => i));
  const [flipped, setFlipped] = useState(false);
  const [known, setKnown] = useState(0);
  const [seen, setSeen] = useState(0);

  if (queue.length === 0) {
    return (
      <div className="card p-8 text-center">
        <div className="mx-auto grid h-14 w-14 place-items-center rounded-2xl bg-emerald-50 text-emerald-600">
          <Icon name="check" className="h-7 w-7" />
        </div>
        <h2 className="font-display mt-3 text-xl font-bold">Deck complete</h2>
        <p className="mt-1 text-sm text-slate-600">
          You knew <strong>{known}</strong> of <strong>{seen}</strong> cards. Come back tomorrow to keep it fresh.
        </p>
        <button
          onClick={() => {
            setQueue(shuffled.map((_, i) => i));
            setKnown(0);
            setSeen(0);
            setFlipped(false);
          }}
          className="btn-primary mt-4 inline-flex items-center gap-1.5"
        >
          <Icon name="repeat" className="h-4 w-4" /> Restart deck
        </button>
      </div>
    );
  }

  const idx = queue[0];
  const card = shuffled[idx];
  const total = shuffled.length;
  const done = total - queue.length;
  const progress = Math.round((done / total) * 100);

  function next(gotIt: boolean) {
    setSeen((s) => s + 1);
    if (gotIt) setKnown((k) => k + 1);
    setQueue((q) => {
      const [first, ...rest] = q;
      const remaining = gotIt ? rest : [...rest, first]; // requeue if not known
      if (remaining.length === 0) celebrate(2);
      return remaining;
    });
    setFlipped(false);
  }

  return (
    <div className="space-y-4">
      <div className="flex items-center gap-3">
        <div className="h-2 flex-1 overflow-hidden rounded-full bg-slate-100">
          <div className="h-full rounded-full bg-brand-500 transition-all duration-300" style={{ width: `${progress}%` }} />
        </div>
        <span className="text-xs font-semibold text-slate-500">{done}/{total}</span>
      </div>

      <button
        onClick={() => setFlipped((f) => !f)}
        className="relative block min-h-[18rem] w-full cursor-pointer text-left [perspective:1600px]"
        aria-label={flipped ? "Show question" : "Show answer"}
      >
        <div
          className="relative h-full min-h-[18rem] w-full transition-transform duration-500 [transform-style:preserve-3d]"
          style={{ transform: flipped ? "rotateY(180deg)" : "rotateY(0deg)" }}
        >
          {/* Front: the question */}
          <div className="absolute inset-0 flex flex-col rounded-2xl border border-slate-200 bg-white p-6 shadow-sm [backface-visibility:hidden]">
            <div className="flex items-center justify-between text-xs">
              <span className="rounded-full bg-brand-50 px-2.5 py-1 font-semibold text-brand-700">{card.topic ?? "General"}</span>
              <span className="text-slate-400">{card.marks} {card.marks === 1 ? "mark" : "marks"}</span>
            </div>
            <p className="mt-4 flex-1 whitespace-pre-wrap text-base font-medium leading-relaxed text-slate-800">{card.stem}</p>
            {card.options.length > 0 && (
              <ul className="mt-3 space-y-1.5 text-sm text-slate-600">
                {card.options.map((o) => (
                  <li key={o.key}><span className="font-semibold text-slate-700">{o.key}.</span> {o.text}</li>
                ))}
              </ul>
            )}
            <p className="mt-4 text-center text-xs font-medium text-slate-400">Tap to reveal the answer</p>
          </div>

          {/* Back: the answer / marking scheme */}
          <div className="absolute inset-0 flex flex-col rounded-2xl border border-emerald-200 bg-emerald-50 p-6 shadow-sm [backface-visibility:hidden] [transform:rotateY(180deg)]">
            <span className="text-xs font-bold uppercase tracking-wide text-emerald-700">Answer</span>
            <div className="mt-3 flex-1 overflow-y-auto">
              {card.answer && <p className="whitespace-pre-wrap text-base font-semibold text-emerald-900">{card.answer}</p>}
              {card.markingScheme && (
                <p className="mt-3 whitespace-pre-wrap text-sm leading-relaxed text-emerald-800">{card.markingScheme}</p>
              )}
              {!card.answer && !card.markingScheme && (
                <p className="text-sm text-emerald-800">No model answer recorded for this question yet, try it in practice mode for AI grading.</p>
              )}
            </div>
            <p className="mt-4 text-center text-xs font-medium text-emerald-500">Tap to flip back</p>
          </div>
        </div>
      </button>

      <div className="grid grid-cols-2 gap-3">
        <button
          onClick={() => next(false)}
          className="inline-flex items-center justify-center gap-1.5 rounded-xl border border-slate-200 bg-white py-3 text-sm font-semibold text-slate-600 transition hover:bg-slate-50 cursor-pointer"
        >
          <Icon name="repeat" className="h-4 w-4" /> Review again
        </button>
        <button
          onClick={() => next(true)}
          className="inline-flex items-center justify-center gap-1.5 rounded-xl bg-emerald-600 py-3 text-sm font-semibold text-white transition hover:bg-emerald-700 cursor-pointer"
        >
          <Icon name="check" className="h-4 w-4" /> Got it
        </button>
      </div>
    </div>
  );
}
