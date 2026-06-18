import { NextRequest, NextResponse } from "next/server";
import { prisma } from "@/lib/db";
import { getCurrentUser } from "@/lib/auth";

// Admin: list waitlist signups, and mark them invited.
export async function GET() {
  const admin = await getCurrentUser();
  if (!admin || admin.role !== "admin") return NextResponse.json({ error: "Forbidden" }, { status: 403 });
  const rows = await prisma.waitlist.findMany({ orderBy: { createdAt: "asc" } });
  return NextResponse.json(rows);
}

export async function PATCH(req: NextRequest) {
  const admin = await getCurrentUser();
  if (!admin || admin.role !== "admin") return NextResponse.json({ error: "Forbidden" }, { status: 403 });
  const { id, invited } = await req.json();
  if (!id) return NextResponse.json({ error: "id required" }, { status: 400 });
  const row = await prisma.waitlist.update({ where: { id }, data: { invited: !!invited } });
  return NextResponse.json(row);
}
