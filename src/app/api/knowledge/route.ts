import { NextRequest, NextResponse } from "next/server";
import { prisma } from "@/lib/db";
import { getCurrentUser } from "@/lib/auth";
import { extractPdfText, MAX_PDF_BYTES } from "@/lib/pdf";

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
      try {
        content = await extractPdfText(await file.arrayBuffer());
      } catch {
        return NextResponse.json({ error: "Could not read text from that PDF (is it scanned/image-only?)." }, { status: 422 });
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
  }

  if (!title || !content.trim()) {
    return NextResponse.json({ error: "title and content (or a text PDF) are required" }, { status: 400 });
  }

  const doc = await prisma.knowledgeDoc.create({
    data: { title, subjectId, form, kind, source, content },
  });
  return NextResponse.json(doc, { status: 201 });
}
