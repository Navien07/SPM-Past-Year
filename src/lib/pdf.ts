import { extractText, getDocumentProxy } from "unpdf";

// Extract plain text from a PDF buffer. Serverless-friendly (unpdf bundles a
// pdf.js build with no native deps). Returns merged text across pages.
export async function extractPdfText(buffer: ArrayBuffer | Uint8Array): Promise<string> {
  const data = buffer instanceof Uint8Array ? buffer : new Uint8Array(buffer);
  const pdf = await getDocumentProxy(data);
  const { text } = await extractText(pdf, { mergePages: true });
  return (Array.isArray(text) ? text.join("\n") : text).trim();
}

// Vercel serverless caps request bodies around 4.5 MB.
export const MAX_PDF_BYTES = 4 * 1024 * 1024;
