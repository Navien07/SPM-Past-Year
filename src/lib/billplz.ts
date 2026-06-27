import crypto from "crypto";

// Billplz integration (FPX online banking + e-wallets, Malaysia).
// Env required:
//   BILLPLZ_API_KEY        — secret API key (Basic auth username, blank password)
//   BILLPLZ_COLLECTION_ID  — the collection bills are created under
//   BILLPLZ_XSIGN_KEY      — X-Signature key for verifying callbacks/redirects
//   BILLPLZ_BASE_URL       — https://www.billplz-sandbox.com/api (sandbox) or
//                            https://www.billplz.com/api (production)

export function billplzConfigured(): boolean {
  return !!(process.env.BILLPLZ_API_KEY && process.env.BILLPLZ_COLLECTION_ID && process.env.BILLPLZ_XSIGN_KEY);
}

function baseUrl() {
  return process.env.BILLPLZ_BASE_URL || "https://www.billplz-sandbox.com/api";
}

interface CreateBillInput {
  email: string;
  name: string;
  amountMyr: number; // ringgit, e.g. 39.90
  description: string;
  callbackUrl: string; // server webhook
  redirectUrl: string; // where the user lands after paying
  reference?: string; // our own id (e.g. studentId:plan)
}

export interface BillplzBill {
  id: string;
  url: string;
  paid: boolean;
}

// Create a bill and return its hosted payment URL.
export async function createBill(input: CreateBillInput): Promise<BillplzBill> {
  const body = new URLSearchParams({
    collection_id: process.env.BILLPLZ_COLLECTION_ID!,
    email: input.email,
    name: input.name.slice(0, 200),
    amount: String(Math.round(input.amountMyr * 100)), // cents
    description: input.description.slice(0, 200),
    callback_url: input.callbackUrl,
    redirect_url: input.redirectUrl,
  });
  if (input.reference) body.set("reference_1", input.reference);

  const auth = Buffer.from(`${process.env.BILLPLZ_API_KEY}:`).toString("base64");
  const res = await fetch(`${baseUrl()}/v3/bills`, {
    method: "POST",
    headers: { Authorization: `Basic ${auth}`, "Content-Type": "application/x-www-form-urlencoded" },
    body,
  });
  if (!res.ok) {
    const detail = await res.text().catch(() => "");
    throw new Error(`Billplz create bill failed (${res.status}): ${detail.slice(0, 300)}`);
  }
  const json = (await res.json()) as { id: string; url: string; paid: boolean };
  return { id: json.id, url: json.url, paid: !!json.paid };
}

// Verify Billplz X-Signature. The signed string is the source params (keys
// prefixed appropriately) sorted by key and joined with "|", HMAC-SHA256'd with
// the X-Signature key. For callbacks the keys are flat (id, paid, paid_at…);
// for redirects they arrive as billplz[id] etc. — pass them flattened as
// `billplz<key>` per Billplz's spec.
export function verifySignature(params: Record<string, string>, xSignature: string): boolean {
  const key = process.env.BILLPLZ_XSIGN_KEY;
  if (!key || !xSignature) return false;
  const source = Object.keys(params)
    .filter((k) => k !== "x_signature")
    .sort()
    .map((k) => `${k}${params[k]}`)
    .join("|");
  const computed = crypto.createHmac("sha256", key).update(source).digest("hex");
  try {
    return crypto.timingSafeEqual(Buffer.from(computed), Buffer.from(xSignature));
  } catch {
    return false;
  }
}
