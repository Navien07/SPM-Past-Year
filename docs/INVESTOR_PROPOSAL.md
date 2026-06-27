# SPM AI — Investor Proposal

*Malaysia's first AI-powered SPM revision platform*

> **Confidential.** Prepared for prospective investor / content partner review.
> Figures marked *projected* or *illustrative* are management estimates, not guarantees.
> This document is for discussion only and is not financial advice or an offer of securities.

---

## 1. Executive summary

SPM AI is an AI-powered revision platform built specifically for Malaysian **Sijil Pelajaran Malaysia (SPM)** students (Form 4–5, ages 16–17). It turns the entire bank of SPM past-year, trial, MRSM and state papers into an adaptive, instantly-graded practice experience — with an AI tutor ("Cikgu AI"), exam-readiness forecasting, gamified progress, and a knowledge base drawn from real textbooks.

We are currently running a **free pilot for 200 students**. The product is live, with **53,000+ tagged questions across 12 KSSM subjects** and **287 knowledge documents**, deployed on a modern, low-cost cloud stack.

We are raising a **seed round** to convert the pilot into a paying, scalable business ahead of the 2026 SPM cycle, and to bring on a **teacher-investor as content & moderation partner**.

---

## 2. The problem

- SPM is the single highest-stakes exam in a Malaysian student's life — it gates university, scholarships (JPA, MARA), and matriculation.
- Quality revision is **expensive and unequal**: private tuition runs RM150–400+/subject/month; good past-paper coverage with worked answers is scattered across photocopies, Telegram groups and paywalled PDFs.
- Students get **no fast feedback**: they attempt a paper and wait days (or never) for marking against the real SPM rubric.
- Teachers are stretched thin and cannot give per-student, per-topic diagnostics at scale.

## 3. The solution — what we've already built

A complete, working product (not a prototype):

| Pillar | What it does |
|---|---|
| **Practice & instant grading** | Browse by topic or year, attempt MCQ/structured/essay; MCQ graded instantly (free), written answers graded by AI against the SPM marking scheme with strengths, improvements and a model answer. |
| **Cikgu AI tutor** | Chat tutor that explains topics, reads a screenshot of a question, and shows how to score full marks — grounded in our textbook knowledge base. |
| **Exam-readiness forecast** | A composite readiness score (mastery + topic coverage + practice volume) mapped to real KSSM grade bands (A+ → G), per subject and overall. |
| **"Why is this the answer?"** | One-tap AI explanation cached per question — cheap at scale, builds an answer-explanation asset over time. |
| **Flashcards** | Spaced-repetition flip decks per subject and topic. |
| **Gamification** | XP, levels, badges, streaks and celebrations to drive daily engagement among teens. |
| **Progress & analytics** | Mastery curves, time-on-task, score trends; admin sees cohort behaviour and at-risk students. |
| **Content pipeline** | 53,000+ questions + 287 knowledge docs ingested, AI-tagged to the 2020+ KSSM syllabus, with human moderation. |
| **Compliance** | PDPA-compliant consent, guardian consent for minors, full IP ownership of derived data. |

Built mobile-first (PWA, installable, push notifications), bilingual (Bahasa Melayu / English).

---

## 4. Market size (real figures)

**SPM is a large, recurring, non-discretionary market.**

- **402,918 candidates** sat SPM in **2024** (up from **373,924** in 2023) — roughly **+8% year-on-year**.¹
- Each candidate is the tail end of a **Form 4 + Form 5 population of ~800,000 students** at any given time (two cohorts of ~400k).
- The market **renews every single year** — a fresh ~400k cohort sits SPM annually, an inherent, durable demand cycle.

**Sizing (illustrative, annual):**

| Layer | Definition | Students | At blended ARPU ~RM250/yr |
|---|---|---|---|
| **TAM** | All Form 4 + Form 5 students | ~800,000 | ~RM200M |
| **SAM** | SPM candidates with smartphone + revising actively | ~400,000 | ~RM100M |
| **SOM (3-yr target)** | ~7–8% of the annual SPM cohort | ~30,000 | ~RM7.5M |

Even a **single-digit percentage** of one SPM cohort is a multi-million-ringgit ARR business — and the cohort reloads every year.

---

## 5. Business model

**Subscription, student-friendly pricing** (already live in the product):

| Plan | Price | Notes |
|---|---|---|
| **Full SPM year** | **RM399 / year** | Best value (~17% cheaper than monthly); aligns with the exam cycle. |
| **Monthly** | **RM39.90 / month** | Flexible, cancel anytime. |
| **7-day free trial** | Free | No card to start; converts on accumulated progress, streak and readiness score. |
| **Sponsored access** | Free | Unlimited free access for **underprivileged students** (CSR + brand goodwill; admin-granted). |

- Payments via **Billplz** (FPX online banking + e-wallets — how Malaysian parents/students actually pay).
- One paid annual plan (RM399) ≈ the cost of **~1 month of single-subject tuition**, for **all 12 subjects, all year**.

### Unit economics (illustrative)

| Item | Per paying student / year |
|---|---|
| Revenue (annual plan) | RM399 |
| AI inference cost (with prompt caching + tiered models) | ~RM12–40 |
| Hosting / infra (amortised) | ~RM10–20 |
| Payment fees (~RM5–8) | ~RM6 |
| **Gross margin** | **~85–90%** |

AI is the only variable cost that scales with usage, and we've already implemented **prompt caching** and a path to cheaper models (Haiku) to keep it low. MCQ grading — the highest-volume action — is **free** (deterministic).

---

## 6. Traction & status

- ✅ **Live product** (web + installable PWA), 12 subjects on the 2020+ KSSM syllabus.
- ✅ **53,000+ questions** and **287 knowledge documents** ingested, 99.8% AI-tagged, human-moderated.
- ✅ **200-student free pilot** underway, with engagement analytics and at-risk tracking.
- ✅ Full billing, trial and paywall system in place, ready to switch on.

---

## 7. The data moat

Every interaction is a proprietary, compounding data asset:

- **Per-question difficulty & discrimination** (how students actually perform vs the official answer) — far richer than a static answer key.
- **Behavioural signals**: time-per-question, "rushing" (fast + wrong), retry/hesitation patterns, session timing, streak behaviour.
- **Mastery curves** per student, per topic, over time → the basis for **psychometric and learning-behaviour analysis** at cohort scale.
- **Answer-explanation corpus** generated once and reused — a growing teaching asset.

This data improves the product (better recommendations, adaptive difficulty), is defensible (no competitor has it for the Malaysian SPM context), and is itself monetisable (anonymised cohort insights for schools/states). All consented under PDPA, with IP owned by SPM AI.

---

## 8. Go-to-market & scaling

1. **Convert the pilot** → paid, ahead of the 2026 SPM cycle (results season + new Form 5 intake are peak acquisition windows).
2. **School & teacher channel** — teacher dashboards + class assignments make SPM AI a tool teachers *recommend* (and our content partner is a teacher).
3. **Referral + streak virality** — students study in WhatsApp groups; gamified streaks and "challenge a friend" drive organic growth.
4. **CSR / sponsorship** — sponsored seats for underprivileged students, funded by corporates/foundations (brand + impact + acquisition).
5. **Adjacent expansion** — same engine extends to **trial papers, MRSM, matrikulasi, and eventually other Malaysian exams** (UASA, STPM) and regional equivalents.

---

## 9. Financial projection (illustrative, management estimate)

| | Year 1 (post-pilot) | Year 2 | Year 3 |
|---|---|---|---|
| Paying students | ~2,000 | ~10,000 | ~30,000 |
| Blended ARPU | ~RM250 | ~RM250 | ~RM250 |
| **Revenue** | **~RM0.5M** | **~RM2.5M** | **~RM7.5M** |
| Gross margin | ~85% | ~87% | ~88% |

**Projected valuation:** Growth edtech SaaS typically trades at **4–6× ARR**. At a Year-3 ARR of ~RM7.5M, that implies an **enterprise value of roughly RM30–45M** (*projected, scenario-dependent*).

At the current **seed/pilot stage**, a defensible **pre-money valuation of ~RM3–6M** reflects: a live product, a proprietary 53k-question dataset, a working monetisation stack, and a clearly sized, renewing market.

---

## 10. The ask & proposed shareholding (illustrative)

**Raising: ~RM500,000 seed** to fund the 2026 go-to-market, AI/infra at scale, content QA, and a small team.

Because the incoming investor is a **practising teacher** who will also **monitor and moderate content** (an active, ongoing contribution — not just capital), we propose a structure that recognises both **cash and sweat**:

| Shareholder | Stake (illustrative) | Contribution |
|---|---|---|
| **Founder(s)** | **75–80%** | Product, technology, operations, vision |
| **Teacher-investor / content partner** | **12–18%** | Seed capital + ongoing content moderation, pedagogy & quality assurance |
| **ESOP / option pool** | **5–10%** | Reserved for future key hires |

> Example at ~RM4–5M pre-money: a RM500k cheque ≈ **~10–11% equity**, with an additional vesting slice for the content/moderation role — total in the **12–18%** range above. Final split, vesting and any board/advisory terms to be agreed and papered by a lawyer.

A teacher-investor is strategically ideal: she anchors **content credibility and moderation**, opens the **school/teacher channel**, and aligns the cap table with the people who make the product trustworthy.

---

## 11. Team

- **Founder** — product & engineering; built the full platform end-to-end.
- **Teacher-investor / content partner** *(prospective)* — curriculum expertise, content moderation, pedagogy, and school relationships.
- **Advisors / ESOP** — reserved for go-to-market and growth hires.

---

## 12. Key risks & mitigation

| Risk | Mitigation |
|---|---|
| Seasonality (SPM is annual) | Annual plan captures full-year revenue upfront; expand to Form 4 + lower forms + other exams to smooth the curve. |
| AI cost at scale | Prompt caching live; tiered/cheaper models; free deterministic MCQ grading; cached explanations. |
| Content accuracy | Human moderation by a qualified teacher (our content partner); QA tooling and low-quality filters built in. |
| Competition | Proprietary SPM dataset + behavioural moat + local payment rails are hard to replicate; first-mover in Malaysian AI SPM prep. |
| Data/privacy | PDPA-compliant consent, guardian consent for minors, clear IP ownership. |

---

## 13. Why now

- AI grading and tutoring are finally **good enough and cheap enough** to deliver one-to-one feedback at scale.
- SPM participation is **growing** (+8% in 2024).¹
- No incumbent owns **AI-native, Malaysia-specific SPM revision** — the window is open, and we have a live product and dataset today.

---

*¹ Source: SPM 2024 candidate figures reported in Malaysian press, April 2025 (402,918 candidates for 2024 vs 373,924 for 2023). See: Malay Mail, “SPM 2024 posts best results since 2013…” (24 Apr 2025).*

**Contact:** [founder details] · SPM AI
