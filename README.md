# SPM AI — Learning Management System

An AI-powered revision platform for the Malaysian **Sijil Pelajaran Malaysia (SPM)**.
Upload past-year, trial, state and mock papers; an AI agent categorizes every question by
subject, topic, form and year; students practise by topic or by year and get **instant,
rubric-based grading**, a **context-aware AI chat tutor (with screenshots)**, a **personal AI
study planner**, and **AI-generated KBAT practice**.

Built with **Next.js 15 + TypeScript + Tailwind + Prisma + PostgreSQL**, powered by
**Anthropic Claude (`claude-opus-4-8`)**. Ships ready for **Vercel + Supabase**.

> The app is fully runnable **without** an API key — every AI feature falls back to a
> deterministic offline mode (clearly labelled in the UI). Add `ANTHROPIC_API_KEY` to switch
> on real Claude grading, tutoring, chat, categorization and generation.

📋 See **[FEATURES.md](./FEATURES.md)** for the full feature list and **[UAT.md](./UAT.md)** for
the acceptance-testing checklist.

## Modules

| # | Module | Where | What it does |
|---|--------|-------|--------------|
| 1 | **Admin / Ingest** | `/admin` | Upload papers (paste text/extracted PDF) tagged by type · subject · year · state · paper number, with marking scheme & rubric. |
| 2 | **Categorization agent** | `POST /api/papers/[id]/categorize` | Claude splits a paper into questions and tags each: subject · form · chapter · subtopic · KBAT · marks · type. |
| 3 | **Content compilation** | `/practice`, `/api/taxonomy` | Per-subject question bank organised by topic and year. |
| 4 | **Practice & grading** | `/practice`, `/practice/[id]` | Browse **by topic** or **by year**, attempt MCQ/structured/essay, instant grading vs the rubric/marking scheme. |
| 5 | **AI tutor + generator** | `/tutor`, `/generate` | Tutor names weak subjects/topics + a focus plan; generator writes new KBAT questions in past-paper style. |
| 6 | **Analytics + mock builder** | `/analytics`, `/mock` | Mastery, time-on-task and score trend; auto-assemble mock papers. |
| ✦ | **Cikgu AI chat** | floating widget, `/api/chat` | Context-aware tutor on every page. **Capture a screenshot** (or attach an image) and Claude reads it (vision) to answer accurately. |

## Quick start (local)

```bash
npm install
cp .env.example .env        # optional: set ANTHROPIC_API_KEY for live AI
npm run setup               # prisma generate + db push + seed
npm run dev                 # http://localhost:3000
```

`npm run setup` seeds 8 subjects, 36 topics and a realistic **Sejarah** trial paper so every
screen is populated on first run.

**Database:** the app uses **PostgreSQL**. `.env.example` points at a local Postgres
(`postgresql://spm:spm@127.0.0.1:5432/spm`). In Claude Code on the web, `scripts/dev-setup.sh`
(run automatically via a SessionStart hook) starts a local Postgres, creates the DB, and seeds it.

### Scripts

| Script | Purpose |
|--------|---------|
| `npm run dev` | Dev server |
| `npm run build` / `npm start` | Production build / serve (`build` runs `prisma generate`) |
| `npm run setup` | Generate client, push schema, seed |
| `npm run db:deploy` | Push schema + seed (for a fresh prod DB) |
| `npm run db:reset` | Force-reset + re-seed (dev only) |

## Testing

End-to-end smoke test of every pipeline (pages + categorize, grade MCQ/essay, tutor, generate,
mock, chat text + chat vision) is covered by the flow used during development:

```bash
# start the server, then exercise every endpoint:
npm run build && npm start &        # http://localhost:3000
# GET /, /practice, /analytics, /tutor, /generate, /mock, /admin  → 200
# POST /api/papers + /api/papers/[id]/categorize                  → questions created
# POST /api/attempts (mcq + essay)                                → graded
# GET  /api/tutor · POST /api/generate · POST /api/mock           → results
# POST /api/chat (text+context) and (with image)                 → reply
```

All 16 checks pass against a Postgres-backed server (MCQ graded deterministically; AI paths
return live Claude output when a key is set, else a labelled offline result). Walk the
user-facing flows with **[UAT.md](./UAT.md)**.

## Deploy to Vercel + Supabase

1. **Supabase** → create a project. From *Project Settings → Database* copy:
   - **Pooled** connection (Transaction, port `6543`) → `DATABASE_URL` (append `?pgbouncer=true&connection_limit=1`).
   - **Direct** connection (port `5432`) → `DIRECT_URL`.
2. **Apply schema + seed** (once, from your machine using the direct URL):
   ```bash
   DATABASE_URL="<direct-url>" DIRECT_URL="<direct-url>" npm run db:deploy
   ```
3. **Vercel** → import the repo. Set environment variables:
   - `DATABASE_URL` (pooled), `DIRECT_URL` (direct), `ANTHROPIC_API_KEY`, optional `SPM_AI_MODEL`.
   - Build command is the default (`npm run build`, which runs `prisma generate`).
4. Deploy. The schema in `prisma/schema.prisma` already declares `directUrl` for Supabase so
   migrations bypass PgBouncer.

> Screenshot capture in chat uses the browser **Screen Capture API** (`getDisplayMedia`), which
> requires HTTPS — it works on the Vercel domain and on `localhost`.

## Architecture

```
src/
  lib/
    ai.ts          # 5 AI agents: categorize / grade / tutor / generate / chat (vision),
                   # all with offline fallbacks. Default claude-opus-4-8 + adaptive thinking.
    db.ts          # Prisma client singleton
    types.ts       # Shared shapes
    constants.ts   # Paper types, states, SPM bands
    student.ts     # Current (demo) student
  components/
    Nav.tsx · AttemptForm.tsx · ExplainButton.tsx · ChatWidget.tsx
  app/
    api/           # papers, categorize, attempts, tutor, generate, mock, taxonomy, chat
    page.tsx admin/ practice/ tutor/ generate/ analytics/ mock/
prisma/
  schema.prisma    # postgresql + directUrl (Supabase-ready)
  seed.ts
scripts/dev-setup.sh   # ephemeral-env bootstrap (deps + local Postgres + seed)
```

### AI layer (`src/lib/ai.ts`)
- **Model:** `claude-opus-4-8` (override `SPM_AI_MODEL`), adaptive thinking on.
- **Chat:** multimodal — accepts screenshots/images as base64 vision blocks and grounds
  answers in the current question's context.
- **Offline fallback:** with no `ANTHROPIC_API_KEY`, each agent returns a deterministic
  placeholder and the UI badges the result as *offline*. MCQ grading is always deterministic.

## Production hardening beyond this POC
- **PDF upload + extraction** feeding the categorization agent (Anthropic Files API / document blocks).
- **Auth** + multi-student accounts (replace `getCurrentStudent`).
- Background jobs / batching for large paper sets; **prompt caching** of marking schemes to cut cost.
- Streaming responses for chat/grading.
