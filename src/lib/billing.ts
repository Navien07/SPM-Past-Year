import { prisma } from "./db";
import { PLANS } from "./access";

// Grant paid access for a settled Billplz bill. Idempotent: a second call with
// the same bill id is a no-op (we key the Payment row on gatewayRef).
export async function applyPaidBill(billId: string, studentId: string, planId: "monthly" | "annual"): Promise<boolean> {
  const plan = PLANS[planId];
  if (!plan) return false;

  const existing = await prisma.payment.findFirst({ where: { gatewayRef: billId } });
  if (existing) return true; // already processed

  const student = await prisma.student.findUnique({ where: { id: studentId }, select: { accessUntil: true } });
  if (!student) return false;

  // Extend from the later of "now" or the current expiry (so renewals stack).
  const now = new Date();
  const base = student.accessUntil && student.accessUntil > now ? student.accessUntil : now;
  const periodEnd = new Date(base.getTime() + plan.periodDays * 86400000);

  await prisma.$transaction([
    prisma.student.update({
      where: { id: studentId },
      data: { accessType: "paid", plan: planId, accessUntil: periodEnd },
    }),
    prisma.payment.create({
      data: {
        studentId,
        amount: plan.price,
        currency: "MYR",
        method: "fpx",
        status: "paid",
        gateway: "billplz",
        gatewayRef: billId,
        plan: planId,
        periodEnd,
        description: `${plan.label} subscription`,
      },
    }),
  ]);
  return true;
}
