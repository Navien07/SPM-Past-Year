import { cookies } from "next/headers";
import { LANG_COOKIE, normLang, type Lang } from "./i18n";

// Server Components: read the active language from the cookie.
export async function getLang(): Promise<Lang> {
  return normLang((await cookies()).get(LANG_COOKIE)?.value);
}
