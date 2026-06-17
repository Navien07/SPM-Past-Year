import { NextRequest, NextResponse } from "next/server";
import { prisma } from "@/lib/db";
import { getCurrentUser } from "@/lib/auth";
import { extractPdfText, MAX_PDF_BYTES } from "@/lib/pdf";
import { aiEnabled, ocrPdf } from "@/lib/ai";
import { storageEnabled, downloadFromStorage, removeFromStorage } from "@/lib/storage";

export const maxDuration = 60;

// Knowledge base ("main brain") — admin-ingested reference notes/textbooks that
// ground Cikgu AI chat. Admin-only. Accepts JSON or a PDF upload.
export async function GET() {
  const docs = await prisma.knowledgeDoc.findMany({
    orderBy: { createdAt: "desc" },
    include: { subject: true },
  });
  return NextResponse.json(docs);
}

export async function POST(req: NextRequest) {
  const user = await getCurrentUser();
  if (!user || user.role !== "admin") {
    return NextResponse.json({ error: "Forbidden" }, { status: 403 });
  }

  const contentType = req.headers.get("content-type") || "";
  let title: string, content = "";
  let subjectId: string | null = null;
  let form: number | null = null;
  let kind = "note";
  let source: string | null = null;

  if (contentType.includes("multipart/form-data")) {
    const fd = await req.formData();
    title = String(fd.get("title") || "");
    subjectId = (fd.get("subjectId") as string) || null;
    form = fd.get("form") ? Number(fd.get("form")) : null;
    kind = (fd.get("kind") as string) || "textbook";
    source = (fd.get("source") as string) || null;
    content = (fd.get("content") as string) || "";

    const file = fd.get("file") as File | null;
    if (file && file.size > 0) {
      if (file.size > MAX_PDF_BYTES) {
        return NextResponse.json(
          { error: `PDF too large (${(file.size / 1e6).toFixed(1)} MB). Max ${(MAX_PDF_BYTES / 1e6).toFixed(0)} MB — split the chapter.` },
          { status: 413 },
        );
      }
      if (!title) title = file.name.replace(/\.pdf$/i, "");
      if (!source) source = file.name;
      const ab = await file.arrayBuffer();
      try {
        content = await extractPdfText(ab);
      } catch {
        content = "";
      }
      if ((!content || content.length < 200) && aiEnabled()) {
        const { text } = await ocrPdf(Buffer.from(ab).toString("base64"));
        if (text) content = text;
      }
    }
  } else {
    const body = await req.json();
    title = body.title;
    subjectId = body.subjectId || null;
    form = body.form ? Number(body.form) : null;
    kind = body.kind || "note";
    source = body.source || null;
    content = body.content || "";

    // Large textbook PDF uploaded directly to Storage → download & extract here.
    if (body.storagePath && storageEnabled()) {
      if (!title) title = String(body.storagePath).split("/").pop()?.replace(/\.pdf$/i, "") ?? "Document";
      if (!source) source = String(body.storagePath).split("/").pop() ?? null;
      try {
        const ab = await downloadFromStorage(String(body.storagePath));
        content = await extractPdfText(ab).catch(() => "");
        if ((!content || content.length < 200) && aiEnabled()) {
          const { text } = await ocrPdf(Buffer.from(ab).toString("base64"));
          if (text) content = text;
        }
        await removeFromStorage(String(body.storagePath));
      } catch (e) {
        return NextResponse.json(
          { error: e instanceof Error ? e.message : "Could not read the uploaded file from storage." },
          { status: 422 },
        );
      }
    }
  }

  if (!title || !content.trim()) {
    return NextResponse.json({ error: "title and content (or a text PDF) are required" }, { status: 400 });
  }

  const doc = await prisma.knowledgeDoc.create({
    data: { title, subjectId, form, kind, source, content },
  });
  return NextResponse.json(doc, { status: 201 });
}
