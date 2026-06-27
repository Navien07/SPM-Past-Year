import { redirect } from "next/navigation";
import { getSessionStudent } from "@/lib/student";
import { accessState, PLANS } from "@/lib/access";
import PlanPicker from "@/components/PlanPicker";
import Icon from "@/components/Icon";

export const dynamic = "force-dynamic";

export default async function PaywallPage({ searchParams }: { searchParams: Promise<{ status?: string }> }) {
  const student = await getSessionStudent();
  if (!student) redirect("/login");
  const sp = await searchParams;
  const state = accessState(student);

  // Already have access → no need for the paywall.
  if (state.ok) redirect("/");

  return (
    <div className="mx-auto max-w-2xl space-y-6 py-6">
      <div className="text-center">
        <div className="mx-auto grid h-14 w-14 place-items-center rounded-2xl bg-brand-50 text-brand-600">
          <Icon name="bolt" className="h-7 w-7" />
        </div>
        <h1 className="font-display mt-3 text-2xl font-bold">Your free trial has ended</h1>
        <p className="mt-2 text-sm text-slate-600">
          Subscribe to keep your streak, progress and full access to every past paper, AI tutor and exam-readiness tool.
        </p>
        {sp.status === "pending" && (
          <p className="mt-2 text-sm font-medium text-amber-600">Payment received, confirming now. Refresh in a moment.</p>
        )}
        {sp.status === "failed" && (
          <p className="mt-2 text-sm font-medium text-red-600">That payment didn&apos;t go through. Please try again.</p>
        )}
      </div>

      <PlanPicker plans={[PLANS.annual, PLANS.monthly]} />

      <p className="text-center text-xs text-slate-400">
        Secure payment via Billplz (FPX online banking &amp; e-wallets). Need help? WhatsApp us anytime.
      </p>
    </div>
  );
}
