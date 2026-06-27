import { NextRequest, NextResponse } from "next/server";
import { getSessionStudent } from "@/lib/student";
import { billplzConfigured, createBill } from "@/lib/billplz";
import { PLANS } from "@/lib/access";

export const maxDuration = 30;

// Start checkout for a plan: create a Billplz bill and return its payment URL.
export async function POST(req: NextRequest) {
  const student = await getSessionStudent();
  if (!student) return NextResponse.json({ error: "Not signed in" }, { status: 401 });

  const { plan } = await req.json().catch(() => ({}));
  const p = PLANS[plan as "monthly" | "annual"];
  if (!p) return NextResponse.json({ error: "Unknown plan" }, { status: 400 });

  if (!billplzConfigured()) {
    return NextResponse.json({ error: "Payments are not configured yet. Please check back soon." }, { status: 503 });
  }

  const origin = process.env.NEXT_PUBLIC_BASE_URL || new URL(req.url).origin;
  try {
    const bill = await createBill({
      email: student.email,
      name: student.name,
      amountMyr: p.price,
      description: `SPM AI — ${p.label}`,
      callbackUrl: `${origin}/api/billing/callback`,
      redirectUrl: `${origin}/api/billing/return?plan=${p.id}`,
      reference: `${student.id}:${p.id}`,
    });
    return NextResponse.json({ url: bill.url });
  } catch (e) {
    return NextResponse.json({ error: e instanceof Error ? e.message : "Checkout failed" }, { status: 502 });
  }
}
