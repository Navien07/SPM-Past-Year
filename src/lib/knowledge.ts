import { prisma } from "./db";

// Lexical retrieval over the admin knowledge base ("main brain"). No external
// embeddings (works offline + within the network sandbox); swap for pgvector
// later without changing callers. Returns bounded snippets to ground the chat.
const STOP = new Set([
  "the", "a", "an", "is", "are", "of", "to", "and", "or", "in", "on", "for", "what",
  "how", "why", "explain", "this", "that", "with", "yang", "dan", "atau", "apa", "di",
  "ke", "untuk", "saya", "anda",
]);

function tokens(s: string): string[] {
  return (s.toLowerCase().match(/[a-zÀ-ɏ0-9]+/gi) ?? [])
    .map((t) => t.toLowerCase())
    .filter((t) => t.length > 2 && !STOP.has(t));
}

export async function retrieveKnowledge(
  query: string,
  opts: { subjectId?: string | null; limit?: number; perDocChars?: number } = {},
): Promise<{ title: string; snippet: string }[]> {
  const limit = opts.limit ?? 2;
  const perDocChars = opts.perDocChars ?? 800;
  const qTokens = new Set(tokens(query));
  if (qTokens.size === 0) return [];

  // Pull a candidate set (small in the POC); score in memory.
  const docs = await prisma.knowledgeDoc.findMany({ take: 200, orderBy: { createdAt: "desc" } });

  const scored = docs
    .map((d) => {
      const docTokens = tokens(`${d.title} ${d.content}`);
      let overlap = 0;
      for (const t of docTokens) if (qTokens.has(t)) overlap++;
      const subjectBoost = opts.subjectId && d.subjectId === opts.subjectId ? 3 : 0;
      return { d, score: overlap + subjectBoost };
    })
    .filter((x) => x.score > 0)
    .sort((a, b) => b.score - a.score)
    .slice(0, limit);

  return scored.map(({ d }) => ({
    title: d.title,
    // Bounded snippet around the first query-term hit (avoid dumping the whole doc).
    snippet: bestWindow(d.content, qTokens, perDocChars),
  }));
}

function bestWindow(content: string, qTokens: Set<string>, size: number): string {
  if (content.length <= size) return content;
  const lower = content.toLowerCase();
  let pos = -1;
  for (const t of qTokens) {
    const i = lower.indexOf(t);
    if (i >= 0 && (pos === -1 || i < pos)) pos = i;
  }
  const start = Math.max(0, (pos === -1 ? 0 : pos) - 120);
  return (start > 0 ? "…" : "") + content.slice(start, start + size) + (start + size < content.length ? "…" : "");
}
