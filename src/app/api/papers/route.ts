import { NextRequest, NextResponse } from "next/server";
import { prisma } from "@/lib/db";
import { getCurrentUser } from "@/lib/auth";
import { extractPdfText, MAX_PDF_BYTES } from "@/lib/pdf";

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
      try {
        rawText = await extractPdfText(await file.arrayBuffer());
      } catch {
        return NextResponse.json({ error: "Could not read text from that PDF (is it scanned/image-only?)." }, { status: 422 });
      }
      if (!rawText) {
        return NextResponse.json({ error: "No selectable text found in the PDF (it may be a scan)." }, { status: 422 });
      }
    }
  } else {
    const body = await req.json();
    ({ title, subjectId, paperType, year, state, paperNumber, rawText, markingScheme } = body);
    year = Number(year);
    paperNumber = Number(paperNumber) || 1;
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
