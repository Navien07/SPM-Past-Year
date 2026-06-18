"use client";

import { useEffect, useState } from "react";
import { LANG_COOKIE, normLang, type Lang } from "./i18n";

// Client Components: read the active language from the cookie (reactively).
export function useLang(): Lang {
  const [lang, setLang] = useState<Lang>("bm");
  useEffect(() => {
    const m = document.cookie.match(new RegExp(`(?:^|; )${LANG_COOKIE}=([^;]+)`));
    setLang(normLang(m ? decodeURIComponent(m[1]) : null));
  }, []);
  return lang;
}
