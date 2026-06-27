import React from "react";

// Lightweight, dependency-free markdown renderer for AI text (chat, tutor,
// feedback) and knowledge notes. Handles headings, bullet/numbered lists,
// bold/italic/code and paragraphs, rendered as React nodes (no innerHTML).

function renderInline(text: string, keyBase: string): React.ReactNode[] {
  const nodes: React.ReactNode[] = [];
  // Tokenize **bold**, *italic*, `code`. Process in order with a combined regex.
  const re = /(\*\*([^*]+)\*\*|\*([^*]+)\*|`([^`]+)`)/g;
  let last = 0, m: RegExpExecArray | null, i = 0;
  while ((m = re.exec(text))) {
    if (m.index > last) nodes.push(text.slice(last, m.index));
    if (m[2] !== undefined) nodes.push(<strong key={`${keyBase}-b${i}`}>{m[2]}</strong>);
    else if (m[3] !== undefined) nodes.push(<em key={`${keyBase}-i${i}`}>{m[3]}</em>);
    else if (m[4] !== undefined) nodes.push(<code key={`${keyBase}-c${i}`} className="rounded bg-slate-100 px-1 py-0.5 text-[0.85em]">{m[4]}</code>);
    last = m.index + m[0].length;
    i++;
  }
  if (last < text.length) nodes.push(text.slice(last));
  return nodes;
}

export default function FormattedText({ text, className = "" }: { text: string; className?: string }) {
  const lines = (text || "").replace(/\r/g, "").split("\n");
  const blocks: React.ReactNode[] = [];
  let para: string[] = [];
  let list: { ordered: boolean; items: string[] } | null = null;

  const flushPara = () => {
    if (para.length) {
      blocks.push(<p key={`p${blocks.length}`} className="whitespace-pre-wrap">{renderInline(para.join("\n"), `p${blocks.length}`)}</p>);
      para = [];
    }
  };
  const flushList = () => {
    if (list) {
      const Tag = list.ordered ? "ol" : "ul";
      blocks.push(
        <Tag key={`l${blocks.length}`} className={`${list.ordered ? "list-decimal" : "list-disc"} ml-5 space-y-1`}>
          {list.items.map((it, j) => <li key={j}>{renderInline(it, `l${blocks.length}-${j}`)}</li>)}
        </Tag>,
      );
      list = null;
    }
  };

  for (const raw of lines) {
    const line = raw.trimEnd();
    const h = line.match(/^(#{1,4})\s+(.*)$/);
    const bullet = line.match(/^\s*[-*•]\s+(.*)$/);
    const ordered = line.match(/^\s*\d+[.)]\s+(.*)$/);
    if (h) {
      flushPara(); flushList();
      blocks.push(<p key={`h${blocks.length}`} className="font-bold">{renderInline(h[2], `h${blocks.length}`)}</p>);
    } else if (bullet) {
      flushPara();
      if (!list || list.ordered) { flushList(); list = { ordered: false, items: [] }; }
      list.items.push(bullet[1]);
    } else if (ordered) {
      flushPara();
      if (!list || !list.ordered) { flushList(); list = { ordered: true, items: [] }; }
      list.items.push(ordered[1]);
    } else if (line.trim() === "") {
      flushPara(); flushList();
    } else {
      flushList();
      para.push(line);
    }
  }
  flushPara(); flushList();

  return <div className={`space-y-2 ${className}`}>{blocks}</div>;
}
