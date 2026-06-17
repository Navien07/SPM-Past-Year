import { NextRequest, NextResponse } from "next/server";
import { getCurrentUser } from "@/lib/auth";
import { storageEnabled, createSignedUpload, safeKey, STORAGE_BUCKET } from "@/lib/storage";

// Whether direct-to-Storage upload is available (for large files).
export async function GET() {
  return NextResponse.json({ enabled: storageEnabled(), bucket: STORAGE_BUCKET });
}

// Issue a one-time signed upload URL so the browser can PUT a large PDF straight
// to Supabase Storage (bypassing Vercel's request-body limit). Admin-only.
export async function POST(req: NextRequest) {
  const user = await getCurrentUser();
  if (!user || user.role !== "admin") {
    return NextResponse.json({ error: "Forbidden" }, { status: 403 });
  }
  if (!storageEnabled()) {
    return NextResponse.json({ error: "Storage not configured (set SUPABASE_URL & SUPABASE_SERVICE_ROLE_KEY)." }, { status: 501 });
  }
  const { kind, filename } = await req.json();
  const path = safeKey(kind === "knowledge" ? "knowledge" : "papers", String(filename || "upload.pdf"));
  try {
    const signed = await createSignedUpload(path);
    return NextResponse.json({ ...signed, bucket: STORAGE_BUCKET });
  } catch (e) {
    return NextResponse.json({ error: e instanceof Error ? e.message : "Could not create upload URL" }, { status: 500 });
  }
}
