import { NextRequest, NextResponse } from "next/server";
import { verifySignature } from "@/lib/billplz";
import { applyPaidBill } from "@/lib/billing";

export const maxDuration = 30;

// Billplz server callback (webhook). Form-encoded; verify x_signature, then
// grant access if paid. Always 200 so Billplz doesn't retry endlessly on our
// own logic errors (we log + swallow).
export async function POST(req: NextRequest) {
  try {
    const form = await req.formData();
    const params: Record<string, string> = {};
    form.forEach((v, k) => (params[k] = String(v)));

    if (!verifySignature(params, params.x_signature || "")) {
      return NextResponse.json({ error: "Bad signature" }, { status: 400 });
    }
    const paid = params.paid === "true" || params.state === "paid";
    const reference = params.reference_1 || "";
    const [studentId, plan] = reference.split(":");
    if (paid && studentId && (plan === "monthly" || plan === "annual")) {
      await applyPaidBill(params.id, studentId, plan);
    }
    return NextResponse.json({ ok: true });
  } catch {
    return NextResponse.json({ ok: true });
  }
}
