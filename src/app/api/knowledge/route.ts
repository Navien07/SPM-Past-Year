import { NextRequest, NextResponse } from "next/server";
import { prisma } from "@/lib/db";
import { getCurrentUser } from "@/lib/auth";

// Knowledge base ("main brain") — admin-ingested reference notes that ground
// Cikgu AI chat. Admin-only.
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
  const { title, subjectId, form, kind, source, content } = await req.json();
  if (!title || !content) {
    return NextResponse.json({ error: "title and content are required" }, { status: 400 });
  }
  const doc = await prisma.knowledgeDoc.create({
    data: {
      title,
      subjectId: subjectId || null,
      form: form ? Number(form) : null,
      kind: kind || "note",
      source: source || null,
      content,
    },
  });
  return NextResponse.json(doc, { status: 201 });
}
