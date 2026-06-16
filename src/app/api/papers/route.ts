import { NextRequest, NextResponse } from "next/server";
import { prisma } from "@/lib/db";

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

// Create a paper from pasted/extracted text (POC). Files can be wired to the
// Files API + PDF extraction later; the categorization agent consumes rawText.
export async function POST(req: NextRequest) {
  const body = await req.json();
  const { title, subjectId, paperType, year, state, paperNumber, rawText, markingScheme } = body;

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
      year: Number(year),
      state: state || null,
      paperNumber: Number(paperNumber) || 1,
      rawText: rawText || null,
      markingScheme: markingScheme || null,
      status: "uploaded",
    },
  });

  return NextResponse.json(paper, { status: 201 });
}
