import { NextRequest } from "next/server";
import { getCurrentUser } from "./auth";

export interface ImportActor {
  name: string;
  id: string | null;
  role: string;
}

// Authorize a bulk-import request: either a logged-in admin/teacher, or an
// automated client presenting `Authorization: Bearer <IMPORT_TOKEN>`.
// The token lets a scraper push content without managing session cookies.
export async function authorizeImport(req: NextRequest): Promise<ImportActor | null> {
  const user = await getCurrentUser();
  if (user && (user.role === "admin" || user.role === "teacher")) {
    return { name: user.name, id: user.id, role: user.role };
  }
  const token = process.env.IMPORT_TOKEN;
  if (token && token.length >= 16) {
    const provided = (req.headers.get("authorization") || "").replace(/^Bearer\s+/i, "").trim();
    if (provided && provided === token) return { name: "Import bot", id: null, role: "import" };
  }
  return null;
}
