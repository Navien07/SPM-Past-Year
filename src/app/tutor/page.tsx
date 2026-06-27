"use client";

import { useEffect, useState } from "react";
import type { TutorRecommendation } from "@/lib/types";
import AILoader from "@/components/AILoader";
import { useLang } from "@/lib/useLang";
import { t } from "@/lib/i18n";

interface PerTopic {
  subject: string;
  topic: string;
  attempts: number;
  avgPercent: number;
}

export default function TutorPage() {
  const lang = useLang();
  const [loading, setLoading] = useState(true);
  const [rec, setRec] = useState<TutorRecommendation | null>(null);
  const [perTopic, setPerTopic] = useState<PerTopic[]>([]);
  const [byAi, setByAi] = useState(false);

  async function load() {
    setLoading(true);
    const res = await fetch("/api/tutor");
    const data = await res.json();
    setRec(data.recommendation);
    setPerTopic(data.perTopic ?? []);
    setByAi(data.byAi);
    setLoading(false);
  }

  useEffect(() => {
    load();
  }, []);

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
 <h1 className="text-2xl font-bold">{t(lang, "tutor.title")}</h1>
          <p className="text-sm text-slate-500">{t(lang, "tutor.subtitle")}</p>
        </div>
        <button onClick={load} className="btn-ghost" disabled={loading}>
          {loading ? "…" : t(lang, "common.refresh")}
        </button>
      </div>

      {loading && <AILoader />}

      {!loading && rec && (
        <>
          <div className="card p-5">
            <div className="mb-2">
              <span className={`badge ${byAi ? "bg-accent-100 text-accent-700" : "bg-slate-200 text-slate-600"}`}>
                {byAi ? t(lang, "tutor.poweredBy") : t(lang, "tutor.offline")}
              </span>
            </div>
            <p className="text-slate-700">{rec.overview}</p>
            {rec.motivational && (
              <p className="mt-3 rounded-xl bg-brand-50 p-3 text-sm font-medium text-brand-800">💪 {rec.motivational}</p>
            )}
          </div>

          {rec.weakSubjects?.length > 0 && (
            <section>
 <h2 className="mb-2 text-sm font-bold uppercase tracking-wide text-slate-500">{t(lang, "tutor.focusSubjects")}</h2>
              <div className="grid gap-3 sm:grid-cols-2">
                {rec.weakSubjects.map((w, i) => (
                  <div key={i} className="card p-4">
                    <div className="flex items-center justify-between">
                      <h3 className="font-semibold">{w.subject}</h3>
                      <span className="badge bg-amber-100 text-amber-800">{t(lang, "tutor.priority")} {w.priority}</span>
                    </div>
                    <p className="mt-1 text-sm text-slate-500">{w.reason}</p>
                  </div>
                ))}
              </div>
            </section>
          )}

          {rec.weakTopics?.length > 0 && (
            <section>
 <h2 className="mb-2 text-sm font-bold uppercase tracking-wide text-slate-500">{t(lang, "tutor.topicsToRevise")}</h2>
              <div className="space-y-2">
                {rec.weakTopics.map((t, i) => (
                  <div key={i} className="card p-3">
                    <div className="text-sm font-semibold">
                      {t.subject} · {t.topic}
                    </div>
                    <p className="text-sm text-slate-500">{t.reason}</p>
                  </div>
                ))}
              </div>
            </section>
          )}

          {rec.focusPlan?.length > 0 && (
            <section>
 <h2 className="mb-2 text-sm font-bold uppercase tracking-wide text-slate-500">{t(lang, "tutor.focusPlan")}</h2>
              <ol className="space-y-2">
                {rec.focusPlan.map((p, i) => (
                  <li key={i} className="card flex gap-3 p-4">
                    <span className="grid h-7 w-7 shrink-0 place-items-center rounded-full bg-brand-600 text-sm font-bold text-white">
                      {i + 1}
                    </span>
                    <div>
                      <div className="font-semibold">{p.step}</div>
                      <p className="text-sm text-slate-500">{p.detail}</p>
                    </div>
                  </li>
                ))}
              </ol>
            </section>
          )}

          {perTopic.length > 0 && (
            <section>
 <h2 className="mb-2 text-sm font-bold uppercase tracking-wide text-slate-500">{t(lang, "tutor.perTopic")}</h2>
              <div className="card divide-y divide-slate-100">
                {perTopic.map((p, i) => (
                  <div key={i} className="flex items-center gap-3 p-3">
                    <div className="flex-1 text-sm">
                      <span className="font-medium">{p.subject}</span> · {p.topic}
                      <span className="ml-2 text-xs text-slate-400">{p.attempts} {t(lang, "tutor.attempts")}</span>
                    </div>
                    <div className="h-2 w-28 overflow-hidden rounded-full bg-slate-100">
                      <div
                        className={`h-full ${p.avgPercent >= 50 ? "bg-emerald-500" : "bg-amber-500"}`}
                        style={{ width: `${p.avgPercent}%` }}
                      />
                    </div>
                    <span className="w-10 text-right text-sm font-semibold">{p.avgPercent}%</span>
                  </div>
                ))}
              </div>
            </section>
          )}
        </>
      )}
    </div>
  );
}
