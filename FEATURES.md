# SPM AI — Full Features List

A complete inventory of what the platform does, grouped by module. Legend:
**[AI]** uses Claude (`claude-opus-4-8`) with a deterministic offline fallback ·
**[Core]** works fully offline.

---

## Module 1 — Admin / Ingest (`/admin/papers`)
- **[Core]** Add papers tagged by **type** (Past Year / Trial / State / Mock), **subject**, **year**, **state/body** (incl. **MRSM, SBP, SPP**), **paper number** (1/2/**3** for sciences).
- **[Core]** **PDF upload → auto-parse**: drop in a paper PDF; the text is extracted server-side (`unpdf`, serverless) and the AI **auto-categorizes** every question by subject/topic/form/year in one flow. Or paste text.
- **[Core]** Attach a **marking scheme / answer key** and **rubric** per paper.
- **[Core]** Paper list with live **status** and question counts.

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
- **[Core]** **Progress tracker**: a per-subject done/left bar, **done/total** counts on each topic & year, and a **✓ Done / Not done** badge on every question.
- **[Core]** Every question is **labelled** with topic + form + exam, e.g. *Bab 3 · Tingkatan 4 · SPM 2025* (trial/state bodies render as *Percubaan MRSM 2024*, etc.).
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

## Authentication & roles
- **[Core]** Login (`/login`) with two roles: **Admin** and **Student**; scrypt-hashed passwords; httpOnly session cookie.
- **[Core]** Server-side route gating: `/admin/*` and `/moderate` (admin), student portal (student); each role lands on its own home.
- **[Core]** The admin handles **everything** — content, students, payments, and the review/approval queue (no separate moderator).
- **[Core]** Seeded demo accounts (1 admin / 4 students).

## Module 1b — Admin dashboard (`/admin`)
- **[Core]** KPIs: students, active enrollments, **revenue (paid)**, pending moderation, papers, approved questions, attempts, AI status.
- **[Core]** **Students list** (`/admin/students`) — per-student subjects, attempts, avg score, total paid.
- **[Core]** **Student detail** (`/admin/students/[id]`) — stats, **mastery by subject**, **performance trend**, **enrolled subjects**, full **payment history**.
- **[Core]** Recent payments feed + quick actions.
- Paper upload & AI categorization (`/admin/papers`) is **admin-only**.

## Module 2b — Confidence-gated review (`/moderate`, admin)
- **[AI]** The categorizer returns a **confidence (0–1)** per question for its subject/form/topic tagging.
- **[Core]** **Confidence gate**: questions at/above the threshold (`SPM_AUTOAPPROVE_THRESHOLD`, default **0.85**) are **auto-approved** (no review); below it they're flagged **`pending`** for a human. So the moderator only sees the doubtful ones.
- **[Core]** Queue ordered **most-doubtful first**, each showing the AI confidence; per-question correction of **subject, topic (form · chapter), marks, KBAT**, then **Approve** (→ live) or **Reject** (→ hidden).
- **[Core]** Counts of pending / approved / rejected; categorize result reports auto-approved vs sent-to-review.

## Knowledge base — "main brain" (`/admin/knowledge`)
- **[Core]** Admin ingests reference notes/summaries (title · subject · form · kind · content), or **uploads a textbook/notes PDF** (text auto-extracted) tagged per subject & form.
- **[AI]** **Cikgu AI chat is grounded** on the knowledge base: lexical retrieval pulls the most relevant bounded snippets (subject-boosted) into the chat context.
- **[Core]** The prompt instructs the AI to **explain in its own words** — it synthesises from the notes rather than reproducing them verbatim. Lexical retrieval works offline; swap for pgvector embeddings later.

## SPM exam structure (encoded)
- **[Core]** SPM = **Form 4–5**. Paper structure per subject in `constants.ts`:
  sciences (Physics/Chemistry/Biology) have **Kertas 1 (objektif) / 2 (struktur+esei) / 3 (amali)**;
  Sejarah/Maths/etc. have **Kertas 1 / 2**; languages have writing + comprehension papers.
- **[Core]** Students only ever see **approved** questions; admin/moderator see all statuses.

## Data model (Prisma)
`Subject`, `Topic`, `Paper`, `Question` (+ moderation `status`), `Student`, `Attempt`,
`StudySession`, `GeneratedQuestion`, `MockPaper`, **`User`** (roles), **`Enrollment`**, **`Payment`**.
