import { createClient, type SupabaseClient } from "@supabase/supabase-js";

// Supabase Storage — lets the browser upload large PDFs directly to Storage,
// bypassing Vercel's ~4.5 MB request-body cap. Gated on env; degrades to the
// direct (multipart) upload path when not configured.
const URL = process.env.SUPABASE_URL;
const KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;
export const STORAGE_BUCKET = process.env.SUPABASE_BUCKET || "uploads";

export function storageEnabled(): boolean {
  return !!(URL && KEY);
}

let _client: SupabaseClient | null = null;
function client(): SupabaseClient {
  if (!_client) _client = createClient(URL!, KEY!, { auth: { persistSession: false } });
  return _client;
}

export function safeKey(kind: string, filename: string): string {
  const base = filename.replace(/[^a-zA-Z0-9._-]/g, "_").slice(-80);
  return `${kind}/${Date.now()}-${Math.random().toString(36).slice(2, 8)}-${base}`;
}

export async function createSignedUpload(path: string) {
  const { data, error } = await client().storage.from(STORAGE_BUCKET).createSignedUploadUrl(path);
  if (error) throw error;
  return { path, token: data.token, signedUrl: data.signedUrl };
}

export async function downloadFromStorage(path: string): Promise<ArrayBuffer> {
  const { data, error } = await client().storage.from(STORAGE_BUCKET).download(path);
  if (error) throw error;
  return await data.arrayBuffer();
}

export async function removeFromStorage(path: string): Promise<void> {
  try {
    await client().storage.from(STORAGE_BUCKET).remove([path]);
  } catch {
    /* best effort */
  }
}
