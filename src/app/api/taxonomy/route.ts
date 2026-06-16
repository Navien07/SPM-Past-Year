import { NextResponse } from "next/server";
import { prisma } from "@/lib/db";

// Subjects with their topics (and question counts) — used by client pages.
export async function GET() {
  const subjects = await prisma.subject.findMany({
    orderBy: { name: "asc" },
    include: {
      _count: { select: { questions: true } },
      topics: {
        orderBy: [{ form: "asc" }, { chapter: "asc" }],
        include: { _count: { select: { questions: true } } },
      },
    },
  });
  return NextResponse.json(subjects);
}
