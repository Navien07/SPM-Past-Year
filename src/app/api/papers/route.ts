import { NextRequest, NextResponse } from "next/server";
import { prisma } from "@/lib/db";
import { getCurrentUser } from "@/lib/auth";
import { extractPdfText, MAX_PDF_BYTES } from "@/lib/pdf";
import { aiEnabled, ocrPdf } from "@/lib/ai";
import { storageEnabled, downloadFromStorage, removeFromStorage } from "@/lib/storage";

export const maxDuration = 60;

export async function GET() {
  const papers = await prisma.paper.findMany({
    orderBy: { createdAt: "desc" },
    include: {
      subject: true,
      _count: { select: { questions: true } },
    },
  });
  return NextResponse.json(papers);
}

// Create a paper. Accepts either JSON (pasted rawText) or multipart/form-data
// with a PDF file, whose text is auto-extracted into rawText for the AI agent.
export async function POST(req: NextRequest) {
  const user = await getCurrentUser();
  if (!user || user.role !== "admin") {
    return NextResponse.json({ error: "Forbidden" }, { status: 403 });
  }

  const contentType = req.headers.get("content-type") || "";
  let title: string, subjectId: string, paperType: string, year: number;
  let state: string | null = null;
  let paperNumber = 1;
  let rawText: string | null = null;
  let markingScheme: string | null = null;
  let fileName: string | null = null;

  if (contentType.includes("multipart/form-data")) {
    const form = await req.formData();
    title = String(form.get("title") || "");
    subjectId = String(form.get("subjectId") || "");
    paperType = String(form.get("paperType") || "");
    year = Number(form.get("year"));
    state = (form.get("state") as string) || null;
    paperNumber = Number(form.get("paperNumber")) || 1;
    markingScheme = (form.get("markingScheme") as string) || null;

    const file = form.get("file") as File | null;
    if (file && file.size > 0) {
      if (file.size > MAX_PDF_BYTES) {
        return NextResponse.json(
          { error: `PDF too large (${(file.size / 1e6).toFixed(1)} MB). Max ${(MAX_PDF_BYTES / 1e6).toFixed(0)} MB on this plan — split the paper.` },
          { status: 413 },
        );
      }
      fileName = file.name;
      const ab = await file.arrayBuffer();
      try {
        rawText = await extractPdfText(ab);
      } catch {
        rawText = "";
      }
      // Scanned / image-only PDF → no selectable text. Fall back to Claude OCR.
      if ((!rawText || rawText.length < 200) && aiEnabled()) {
        const { text } = await ocrPdf(Buffer.from(ab).toString("base64"));
        if (text) rawText = text;
      }
      if (!rawText) {
        return NextResponse.json(
          { error: "No selectable text found (looks scanned). Set ANTHROPIC_API_KEY to enable OCR, or upload a text-based PDF." },
          { status: 422 },
        );
      }
    }
  } else {
    const body = await req.json();
    ({ title, subjectId, paperType, year, state, paperNumber, rawText, markingScheme } = body);
    year = Number(year);
    paperNumber = Number(paperNumber) || 1;

    // Large file uploaded directly to Supabase Storage → download & extract here.
    if (body.storagePath && storageEnabled()) {
      fileName = String(body.storagePath).split("/").pop() ?? null;
      try {
        const ab = await downloadFromStorage(String(body.storagePath));
        rawText = await extractPdfText(ab).catch(() => "");
        if ((!rawText || rawText.length < 200) && aiEnabled()) {
          const { text } = await ocrPdf(Buffer.from(ab).toString("base64"));
          if (text) rawText = text;
        }
        await removeFromStorage(String(body.storagePath)); // transient
      } catch (e) {
        return NextResponse.json(
          { error: e instanceof Error ? e.message : "Could not read the uploaded file from storage." },
          { status: 422 },
        );
      }
      if (!rawText) {
        return NextResponse.json({ error: "No text could be extracted (scanned & OCR unavailable?)." }, { status: 422 });
      }
    }
  }

  if (!title || !subjectId || !paperType || !year) {
    return NextResponse.json(
      { error: "title, subjectId, paperType and year are required" },
      { status: 400 },
    );
  }

  const paper = await prisma.paper.create({
    data: {
      title,
      subjectId,
      paperType,
      year,
      state: state || null,
      paperNumber,
      rawText: rawText || null,
      fileName,
      markingScheme: markingScheme || null,
      status: "uploaded",
    },
  });

  return NextResponse.json(paper, { status: 201 });
}
