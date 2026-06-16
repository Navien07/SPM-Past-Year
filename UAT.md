# SPM AI — User Acceptance Testing (UAT) Checklist

How to use: run through each case in a browser after `npm run dev` (or on the
deployed Vercel URL). Mark **Pass/Fail**. Cases tagged **[AI-live]** require
`ANTHROPIC_API_KEY` to be set; without a key they should still complete and show
an **offline** label (that is itself a valid pass for **[offline]**).

> Automated end-to-end coverage of the API pipelines lives in the smoke test —
> see `README.md` → Testing. This UAT covers the user-facing flows.

---

## 0. Setup / smoke
| # | Case | Steps | Expected |
|---|------|-------|----------|
| 0.1 | App loads | Open `/` | Dashboard renders; stats show Subjects=8, Topics=36, Questions≥12 |
| 0.2 | AI status visible | Look at hero badge | Shows "AI live (Claude)" with a key, else "AI offline" |
| 0.3 | Navigation | Click each nav item / bottom tab | All 6 sections load without error |
| 0.4 | Mobile layout | Narrow the window / open on phone | Bottom tab bar appears; layout is usable |

## 1. Admin / Ingest
| # | Case | Steps | Expected |
|---|------|-------|----------|
| 1.1 | Add a paper | `/admin` → fill title, subject, type, year → **Add paper** | Success message; paper appears with status `uploaded` |
| 1.2 | State tagging | Choose type *State*/*Trial* and a state | State chip shows on the paper |
| 1.3 | Validation | Submit with empty title | Blocked (HTML required) |
| 1.4 | Categorize | On a paper with text → **Categorize** | Status → `categorized`; question count > 0; message states AI vs offline |
| 1.5 | Re-categorize | Click **Re-categorize** | Count refreshes; no duplicate explosion (replaced) |

## 2. Categorization quality **[AI-live]**
| # | Case | Steps | Expected |
|---|------|-------|----------|
| 2.1 | Question split | Categorize a multi-question paper | Each question becomes its own item |
| 2.2 | Tagging | Inspect categorized questions in `/practice` | Type, marks, KBAT, topic populated sensibly |
| 2.3 | Topic creation | Categorize a paper covering a new chapter | New topic appears under the subject |

## 3. Content / browse
| # | Case | Steps | Expected |
|---|------|-------|----------|
| 3.1 | By Topic | `/practice` → pick subject → **By Topic** → pick a topic | Questions for that topic list on the right |
| 3.2 | By Year | Toggle **By Year** → pick a year | Questions for that year list |
| 3.3 | Subject switch | Click another subject chip | List updates to that subject |
| 3.4 | Counts | Check chips/badges | Counts match the listed questions |

## 4. Practice & grading
| # | Case | Steps | Expected |
|---|------|-------|----------|
| 4.1 | Open question | Click a question | Stem, metadata and answer area render |
| 4.2 | MCQ correct | Select the correct option → **Submit** | Score = full marks; "Correct"; band shown |
| 4.3 | MCQ wrong | Select a wrong option | Score 0; correct key shown |
| 4.4 | Essay grade **[AI-live]** | Write an essay answer → **Submit** | Score/maxScore, band, per-criterion rubric, strengths, improvements, model answer |
| 4.5 | Essay grade **[offline]** | Same with no key | Result shown, badged "Offline estimate" |
| 4.6 | Try again | Click **Try again** | Resets to answer the question again |
| 4.7 | Persistence | Re-open `/analytics` | The attempt is reflected in stats |

## 5. AI Tutor
| # | Case | Steps | Expected |
|---|------|-------|----------|
| 5.1 | Recommendations | Make a few attempts → open `/tutor` | Overview, focus subjects, topics to revise, focus plan |
| 5.2 | Performance bars | Scroll to "Performance by topic" | Bars reflect your scores |
| 5.3 | Refresh | Click **Refresh** | Re-computes after new attempts |
| 5.4 | Empty state | Brand-new student, no attempts | Friendly prompt to start practising |

## 6. Question Generator
| # | Case | Steps | Expected |
|---|------|-------|----------|
| 6.1 | Generate | `/generate` → subject → topic → type → count → **Generate** | N questions render |
| 6.2 | KBAT | Toggle KBAT on | Items badged KBAT |
| 6.3 | Reveal | Click **Show answer & scheme** | Answer + marking scheme shown |
| 6.4 | MCQ shape | Generate MCQ | 4 options + a correct key |

## 7. Analytics
| # | Case | Steps | Expected |
|---|------|-------|----------|
| 7.1 | Stats | `/analytics` | Attempts, avg score, time-on-task, subjects |
| 7.2 | Mastery | View mastery bars | One bar per practised subject, colour-coded |
| 7.3 | Trend | View score trend | One bar per attempt in order |
| 7.4 | Empty state | New student | Prompt to start practising |

## 8. Mock Paper Builder
| # | Case | Steps | Expected |
|---|------|-------|----------|
| 8.1 | Build | `/mock` → subject → paper → count → **Build** | Paper with N questions + total marks |
| 8.2 | KBAT bias | Toggle on → build | KBAT items float to the top |
| 8.3 | Open item | Click a question | Goes to its practice page |
| 8.4 | Empty subject | Pick a subject with no Kertas-N questions | Friendly error, no crash |

## 9. AI Chat — Cikgu AI
| # | Case | Steps | Expected |
|---|------|-------|----------|
| 9.1 | Open | Click the 💬 bubble (any page) | Chat panel opens |
| 9.2 | Ask **[AI-live]** | Type a topic question → send | Relevant explanation; "thinking…" then reply |
| 9.3 | Ask **[offline]** | Same with no key | Reply shown, badged "offline mode" |
| 9.4 | Context | Open a question → **Explain with AI** | Chat opens; answer references that exact question |
| 9.5 | 📸 Screenshot | Click 📸 → pick a screen/tab | Screenshot appears as a snippet in the tray |
| 9.6 | 📎 Attach | Click 📎 → choose an image | Thumbnail added to the tray |
| 9.7 | Send with image **[AI-live]** | Attach a screenshot of a question → send | Reply reads the image and explains it |
| 9.8 | Remove attachment | Click ✕ on a thumbnail | Attachment removed before sending |
| 9.9 | Multi-turn | Ask a follow-up | Prior context retained |
| 9.10 | Mobile | On phone, bubble sits above the tab bar | No overlap; panel fits the screen |

## 10. Resilience
| # | Case | Steps | Expected |
|---|------|-------|----------|
| 10.1 | No key | Unset `ANTHROPIC_API_KEY` | Every AI feature still completes, labelled offline |
| 10.2 | Bad question id | Open `/practice/does-not-exist` | 404, no crash |
| 10.3 | Reload | Refresh any page | State persists from Postgres |

## 11. Deployment (Vercel + Supabase)
| # | Case | Steps | Expected |
|---|------|-------|----------|
| 11.1 | Env vars | Set `DATABASE_URL`, `DIRECT_URL`, `ANTHROPIC_API_KEY` in Vercel | Build succeeds |
| 11.2 | Schema | `npx prisma db push` against Supabase (DIRECT_URL) | Tables created |
| 11.3 | Seed | `npm run db:deploy` (or seed) | Subjects/topics/sample paper present |
| 11.4 | Live grade **[AI-live]** | Grade an essay on the deployed URL | Real Claude grading returned |
| 11.5 | Live chat **[AI-live]** | Use Cikgu AI on deployed URL with a screenshot | Vision answer returned |
