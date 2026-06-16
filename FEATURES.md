# SPM AI — Full Features List

A complete inventory of what the platform does, grouped by module. Legend:
**[AI]** uses Claude (`claude-opus-4-8`) with a deterministic offline fallback ·
**[Core]** works fully offline.

---

## Module 1 — Admin / Ingest (`/admin`)
- **[Core]** Add papers tagged by **type** (Past Year / Trial / State / Mock), **subject**, **year**, **state/body**, **paper number** (1/2).
- **[Core]** Paste paper text (or extracted PDF text) as the source for categorization.
- **[Core]** Attach a **marking scheme / answer key** and **rubric** per paper.
- **[Core]** Paper list with live **status** (uploaded → categorizing → categorized / failed) and question counts.
- **[Core]** Pre-filled sample text so the flow is demonstrable immediately.

## Module 2 — AI Categorization Agent (`POST /api/papers/[id]/categorize`)
- **[AI]** Splits a paper into individual questions.
- **[AI]** Tags each question: **type** (MCQ / structured / essay), **stem**, **options**, **answer**, **marks**, **KBAT flag**, **form (4/5)**, **chapter**, **chapter title**, **subtopic**.
- **[AI]** Auto-creates/links **Topic** rows so new chapters appear in the taxonomy.
- **[Core]** Idempotent re-categorization (re-running replaces that paper's questions).
- **[Core]** Offline heuristic splitter when no API key is set.

## Module 3 — Content Compilation (`/practice`, `/api/taxonomy`)
- **[Core]** Per-subject question banks (8 subjects seeded: Sejarah, BM, English, Maths, Add Maths, Physics, Chemistry, Biology).
- **[Core]** KSSM-style topic taxonomy (Form 4 & 5 chapters + subtopics; 36 topics seeded).
- **[Core]** Question counts per subject / topic / year.

## Module 4 — Practice & Instant Grading (`/practice`, `/practice/[id]`)
- **[Core]** Browse **by Topic** or **by Year** (toggle), filtered per subject.
- **[Core]** Question detail with metadata (subject, topic, paper, marks, KBAT, year, source).
- **[Core]** MCQ answered by option selection; structured/essay via free text.
- **[Core]** **MCQ graded deterministically** (no model needed).
- **[AI]** Structured/essay graded against the **marking scheme / rubric**: score, **SPM band**, summary, strengths, improvements, **per-criterion breakdown**, model answer.
- **[Core]** Time-on-task captured per attempt; every attempt stored.
- **[Core]** Result clearly badged **"Graded by Claude"** vs **"Offline estimate"**.

## Module 5 — AI Tutor & Question Generator (`/tutor`, `/generate`)
- **[AI]** **Tutor**: aggregates attempts per topic → identifies **weak subjects & topics**, gives a **prioritised focus plan** + motivation.
- **[Core]** Per-topic performance bars.
- **[AI]** **Generator**: creates new questions in the **style of real past papers** for a chosen topic, with **KBAT** toggle, type and count.
- **[Core]** Generated questions persisted; answer + marking scheme reveal.

## Module 6 — Analytics & Mock Builder (`/analytics`, `/mock`)
- **[Core]** Stats: attempts, average score, time-on-task, subjects practised.
- **[Core]** **Mastery by subject** bars; **score trend** per attempt.
- **[Core]** **Mock paper builder**: auto-assembles a paper from the bank, spread across topics, with optional **KBAT bias**; links each item to its practice page.

## AI Chat — "Cikgu AI" (global widget, `/api/chat`)
- **[Core]** Floating chat available on **every page** (desktop + mobile).
- **[AI]** Context-aware tutoring: answers in **BM or English** matching the student.
- **[AI]** **Fully context-aware** — when opened on a question page it loads that exact question (stem, options, answer, marking scheme, topic) so answers are grounded.
- **[Core]** **📸 Screenshot tool** — captures the screen/tab via the browser and attaches it as a snippet.
- **[Core]** **📎 Image attach** — attach screenshots/photos (auto-downscaled).
- **[AI]** **Vision** — Claude reads attached screenshots and explains them.
- **[Core]** "🧑‍🏫 Explain with AI" button on each question opens the chat pre-seeded with context.
- **[Core]** Multi-turn history; image thumbnails rendered inline; offline mode clearly labelled.

## Cross-cutting
- **[Core]** Mobile-first responsive UI (top bar + bottom tab bar) with a polished design system.
- **[Core]** **Runs with or without an API key** — every AI feature degrades to a labelled offline mode; AI is never silently faked.
- **[Core]** Configurable model via `SPM_AI_MODEL` (default `claude-opus-4-8`, adaptive thinking).
- **[Core]** Postgres/**Supabase**-ready data layer (Prisma); deployable to **Vercel**.
- **[Core]** SessionStart bootstrap script for fresh/ephemeral environments.

## Data model (Prisma)
`Subject`, `Topic`, `Paper`, `Question`, `Student`, `Attempt`, `StudySession`,
`GeneratedQuestion`, `MockPaper`.
