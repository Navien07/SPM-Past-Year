# SPM AI — Learning Management System (POC)

An AI-powered revision platform for the Malaysian **Sijil Pelajaran Malaysia (SPM)**.
Upload past-year, trial, state and mock papers; an AI agent categorizes every question by
subject, topic, form and year; students practise by topic or by year and get **instant,
rubric-based grading**, a **personal AI tutor**, and **AI-generated KBAT practice**.

Built with **Next.js 15 + TypeScript + Tailwind + Prisma**, powered by **Anthropic Claude
(`claude-opus-4-8`)**.

> The app is fully runnable **without** an API key — every AI feature falls back to a
> deterministic offline mode (clearly labelled in the UI). Add `ANTHROPIC_API_KEY` to switch
> on real Claude grading, tutoring, categorization and generation.

## The six modules

| # | Module | Where | What it does |
|---|--------|-------|--------------|
| 1 | **Admin / Ingest** | `/admin` | Upload papers (paste text/extracted PDF) tagged by type · subject · year · state · paper number, with marking scheme & rubric. |
| 2 | **Categorization agent** | `POST /api/papers/[id]/categorize` | Claude splits a paper into questions and tags each: subject · form · chapter · subtopic · KBAT · marks · type. |
| 3 | **Content compilation** | `/practice`, `/api/taxonomy` | Per-subject question bank organised by topic and year. |
| 4 | **Practice & grading** | `/practice`, `/practice/[id]` | Browse **by topic** or **by year**, attempt MCQ/structured/essay, get instant grading against the rubric/marking scheme. |
| 5 | **AI tutor + generator** | `/tutor`, `/generate` | Tutor names weak subjects/topics and gives a focus plan; generator writes new KBAT questions in the style of real papers. |
| 6 | **Analytics + mock builder** | `/analytics`, `/mock` | Mastery, time-on-task and score trend; auto-assemble mock papers from the bank. |

## Quick start

```bash
npm install
cp .env.example .env        # optional: set ANTHROPIC_API_KEY for live AI
npm run setup               # prisma generate + db push + seed
npm run dev                 # http://localhost:3000
```

`npm run setup` seeds 8 subjects, 36 topics and a realistic **Sejarah** trial paper so every
screen is populated on first run.

### Useful scripts

| Script | Purpose |
|--------|---------|
| `npm run dev` | Dev server |
| `npm run build` / `npm start` | Production build / serve |
| `npm run setup` | Generate client, push schema, seed |
| `npm run db:reset` | Wipe + re-seed the SQLite DB |
| `npm run db:seed` | Seed only |

## Architecture

```
src/
  lib/
    ai.ts          # The 4 AI agents (categorize / grade / tutor / generate) with
                   # graceful offline fallbacks. Defaults to claude-opus-4-8 + adaptive thinking.
    db.ts          # Prisma client singleton
    types.ts       # Shared shapes (rubric, grade result, tutor rec, etc.)
    constants.ts   # Paper types, states, SPM grade bands
    student.ts     # Current (demo) student
  app/
    api/           # papers, categorize, attempts, tutor, generate, mock, taxonomy
    page.tsx       # Dashboard
    admin/         # Module 1 + 2 trigger
    practice/      # Module 3 + 4 (browse + attempt + grade)
    tutor/         # Module 5 (tutor)
    generate/      # Module 5 (generator)
    analytics/     # Module 6 (progress)
    mock/          # Module 6 (mock builder)
prisma/
  schema.prisma    # Subject, Topic, Paper, Question, Student, Attempt,
                   # StudySession, GeneratedQuestion, MockPaper
  seed.ts          # Subjects, topics, Sejarah trial paper, demo student & attempts
```

### AI layer

All AI runs through `src/lib/ai.ts`:

- **Model:** `claude-opus-4-8` (override with `SPM_AI_MODEL`), adaptive thinking on.
- **Robust JSON:** prompts request JSON; the response is parsed defensively (handles code
  fences / surrounding prose).
- **Offline fallback:** with no `ANTHROPIC_API_KEY`, each agent returns a deterministic
  placeholder and the UI badges the result as *offline* so grading is never silently faked.
- **MCQ** is always graded deterministically (no model call).

## Production path (beyond the POC)

- Swap the Prisma datasource from SQLite to **Postgres** (no model changes).
- Real **PDF upload + text extraction** (Anthropic Files API / document blocks) feeding the
  categorization agent.
- **Auth** + multi-student accounts (replace `getCurrentStudent`).
- Background jobs / batching for large paper sets.
- Caching of marking-scheme prompts (prompt caching) to cut grading cost.
