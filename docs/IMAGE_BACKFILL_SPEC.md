# Diagram / image backfill — spec for the scraper session

**Problem:** questions were imported as text only. Diagram/figure/graph/table
images were never captured, so diagram-dependent questions (lots of Kertas 1 &
2) are currently unanswerable. The app now supports per-question images; this
spec is how the scraper backfills them.

## App side (already done — no changes needed)
- `Question.images` is a JSON array of image URLs.
- The bulk import (`POST /api/admin/papers/bulk`) accepts `images: string[]` per
  question, matched/created by `sourceKey` (idempotent).
- The question page renders all `images` under the stem.
- Run the **prod migration** once (Supabase SQL editor):
  ```sql
  ALTER TABLE "Question" ADD COLUMN IF NOT EXISTS "images" text NOT NULL DEFAULT '[]';
  ```

## Recommended approach (Route A — page images, fastest)

For each question that came from a PDF:

1. **Render the source PDF page** the question sits on to PNG (e.g. `pdf2image`
   / `pdftoppm` at ~150 DPI). One image per page is fine; if a question spans
   pages, attach both.
2. **Upload to Supabase Storage** (create a public bucket, e.g. `question-images`):
   ```python
   # supabase-py
   path = f"{sourceKey}/p{page}.png"
   supabase.storage.from_("question-images").upload(path, png_bytes,
       {"content-type": "image/png", "upsert": "true"})
   url = supabase.storage.from_("question-images").get_public_url(path)
   ```
3. **Push back via bulk import**, re-sending the question with its `images`
   array (same `sourceKey` as the original import so it updates in place):
   ```python
   requests.post(f"{BASE}/api/admin/papers/bulk",
       headers={"Authorization": f"Bearer {IMPORT_TOKEN}"},
       json={"papers": [{
           "sourceKey": paperSourceKey, "subject": ..., "questions": [
               {"sourceKey": qSourceKey, "stem": ..., "images": [url], ...}
           ]
       }]})
   ```
   (Send the full question payload as in the original import; just add `images`.)

## Higher fidelity (Route B — cropped figures, later)
- Extract embedded images from the PDF (`PyMuPDF` `page.get_images()` /
  `pdfplumber` `.images`) and crop the figure bounding box, OR
- Send the page image to a vision model and ask for the figure's bounding box,
  then crop. More accurate, more cost — reserve for high-traffic subjects.

## Prioritisation
1. Run **Admin → QA → Preview** on "Hold diagram-only" to see how many questions
   are affected per the keyword heuristic.
2. Backfill **high-traffic subjects first** (Physics, Chemistry, Biology, Add
   Maths Kertas 2/3 — most diagram-heavy).
3. As images land, the held questions can be re-approved (status → approved) in
   the QA view so students see them again.

## Storage / cost notes
- Page PNGs at 150 DPI are ~100–300 KB each. 50k images ≈ 5–15 GB — within
  Supabase Pro storage; use the CDN public URL.
- Set the bucket to public-read (images aren't sensitive) for simple `<img>`
  rendering.
