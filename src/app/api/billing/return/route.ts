import { NextRequest, NextResponse } from "next/server";
import { getSessionStudent } from "@/lib/student";
import { verifySignature } from "@/lib/billplz";
import { applyPaidBill } from "@/lib/billing";

export const maxDuration = 30;

// Where Billplz sends the user after paying. Params arrive as billplz[id],
// billplz[paid], billplz[paid_at], billplz[x_signature]. We verify, grant
// access as a fallback to the webhook (idempotent), then redirect.
export async function GET(req: NextRequest) {
  const url = new URL(req.url);
  const origin = process.env.NEXT_PUBLIC_BASE_URL || url.origin;
  const id = url.searchParams.get("billplz[id]") || "";
  const paid = url.searchParams.get("billplz[paid]") || "";
  const paidAt = url.searchParams.get("billplz[paid_at]") || "";
  const sig = url.searchParams.get("billplz[x_signature]") || "";
  const plan = url.searchParams.get("plan") || "";

  // Redirect-signature source keys are "billplz" + field name.
  const ok = verifySignature({ billplzid: id, billplzpaid: paid, billplzpaid_at: paidAt }, sig);
  const isPaid = paid === "true";

  if (ok && isPaid && (plan === "monthly" || plan === "annual")) {
    const student = await getSessionStudent();
    if (student) await applyPaidBill(id, student.id, plan);
    return NextResponse.redirect(`${origin}/?welcome=paid`);
  }
  return NextResponse.redirect(`${origin}/paywall?status=${ok ? "pending" : "failed"}`);
}
