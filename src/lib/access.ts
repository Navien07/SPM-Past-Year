// Subscription / trial access model.
//
// During the free pilot (PILOT_MODE on), every student gets accessType "pilot"
// = full free access. When you switch to paid (PILOT_MODE off via env), new
// signups get a 7-day trial, after which they must subscribe.

export const PILOT_MODE = process.env.PILOT_MODE !== "0"; // default: pilot is on
export const TRIAL_DAYS = 7;

export interface Plan {
  id: "monthly" | "annual";
  label: string;
  price: number; // MYR
  priceLabel: string;
  periodDays: number;
  blurb: string;
}

export const PLANS: Record<"monthly" | "annual", Plan> = {
  monthly: {
    id: "monthly",
    label: "Monthly",
    price: 39.9,
    priceLabel: "RM39.90",
    periodDays: 31,
    blurb: "Full access, billed monthly. Cancel anytime.",
  },
  annual: {
    id: "annual",
    label: "Full SPM year",
    price: 399,
    priceLabel: "RM399",
    periodDays: 366,
    blurb: "Best value — everything for a whole year (save ~17%).",
  },
};

export interface AccessState {
  ok: boolean;
  reason: "pilot" | "sponsored" | "paid" | "trial" | "expired";
  daysLeft: number | null; // for trial/paid
}

export interface AccessFields {
  accessType: string;
  accessUntil: Date | null;
  trialEndsAt: Date | null;
}

// Decide whether a student currently has access, and why.
export function accessState(s: AccessFields, now: Date = new Date()): AccessState {
  if (s.accessType === "pilot" || s.accessType === "sponsored") {
    return { ok: true, reason: s.accessType, daysLeft: null };
  }
  const days = (until: Date) => Math.max(0, Math.ceil((until.getTime() - now.getTime()) / 86400000));
  if (s.accessUntil && s.accessUntil > now) {
    return { ok: true, reason: "paid", daysLeft: days(s.accessUntil) };
  }
  if (s.trialEndsAt && s.trialEndsAt > now) {
    return { ok: true, reason: "trial", daysLeft: days(s.trialEndsAt) };
  }
  return { ok: false, reason: "expired", daysLeft: 0 };
}

export function hasAccess(s: AccessFields): boolean {
  return accessState(s).ok;
}
