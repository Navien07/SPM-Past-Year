import Link from "next/link";
import { prisma } from "@/lib/db";
import { requireStudent } from "@/lib/student";
import { getLang } from "@/lib/lang-server";
import { t } from "@/lib/i18n";
import Icon from "@/components/Icon";
import FlashcardDeck, { type Flashcard } from "@/components/FlashcardDeck";

export const dynamic = "force-dynamic";
export const maxDuration = 60;

type SP = Promise<{ subject?: string }>;

function parseOptions(raw: string): { key: string; text: string }[] {
  try {
    const arr = JSON.parse(raw);
    return Array.isArray(arr) ? arr.filter((o) => o && o.key && o.text) : [];
  } catch {
    return [];
  }
}

export default async function FlashcardsPage({ searchParams }: { searchParams: SP }) {
  const student = await requireStudent();
  const sp = await searchParams;
  const lang = await getLang();

  // Subjects the student can study (those with approved questions).
  const subjects = await prisma.subject.findMany({
    orderBy: { name: "asc" },
    include: { _count: { select: { questions: { where: { status: "approved" } } } } },
  });
  const studyable = subjects.filter((s) => s._count.questions > 0);
  const subjectId = sp.subject || studyable[0]?.id;
  const subject = studyable.find((s) => s.id === subjectId);

  // Build a 30-card deck: prefer questions that carry a model answer or marking
  // scheme so the back of the card has something to learn from.
  const rows = subjectId
    ? await prisma.question.findMany({
        where: {
          subjectId,
          status: "approved",
          OR: [{ answer: { not: null } }, { markingScheme: { not: null } }],
        },
        orderBy: [{ isKbat: "desc" }, { year: "desc" }],
        take: 30,
        include: { topic: true },
      })
    : [];

  const cards: Flashcard[] = rows.map((q) => ({
    id: q.id,
    stem: q.stem,
    options: parseOptions(q.options),
    answer: q.answer,
    markingScheme: q.markingScheme,
    marks: q.marks,
    type: q.questionType,
    topic: q.topic?.title ?? null,
  }));

  return (
    <div className="space-y-5">
      <div>
        <h1 className="font-display text-2xl font-bold">{t(lang, "flash.title")}</h1>
        <p className="text-sm text-slate-500">{t(lang, "flash.sub")}</p>
      </div>

      {/* Subject picker */}
      <div className="flex flex-wrap gap-2">
        {studyable.map((s) => (
          <Link
            key={s.id}
            href={`/flashcards?subject=${s.id}`}
            className={`rounded-full px-3.5 py-1.5 text-sm font-medium transition ${
              s.id === subjectId ? "bg-brand-600 text-white" : "border border-slate-200 bg-white text-slate-600 hover:bg-slate-50"
            }`}
          >
            {s.name}
          </Link>
        ))}
      </div>

      {cards.length === 0 ? (
        <div className="card p-8 text-center">
          <div className="mx-auto grid h-14 w-14 place-items-center rounded-2xl bg-slate-100 text-slate-500">
            <Icon name="book" className="h-7 w-7" />
          </div>
          <p className="mt-3 text-slate-600">{t(lang, "flash.empty")}</p>
          <Link href="/practice" className="btn-primary mt-4 inline-flex items-center gap-1.5">
            <Icon name="practice" className="h-4 w-4" /> {t(lang, "analytics.start")}
          </Link>
        </div>
      ) : (
        <>
          <p className="text-xs text-slate-400">
            {subject?.name} · {cards.length} {t(lang, "flash.cards")}
          </p>
          <FlashcardDeck key={subjectId} cards={cards} />
        </>
      )}
    </div>
  );
}
