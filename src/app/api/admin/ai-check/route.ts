import { NextResponse } from "next/server";
import { getCurrentUser } from "@/lib/auth";
import { aiHealthCheck } from "@/lib/ai";

export const maxDuration = 30;

// Admin: live AI key check (does the key actually work / have credit?).
export async function GET() {
  const user = await getCurrentUser();
  if (!user || (user.role !== "admin" && user.role !== "teacher")) {
    return NextResponse.json({ error: "Forbidden" }, { status: 403 });
  }
  const result = await aiHealthCheck();
  return NextResponse.json(result);
}
