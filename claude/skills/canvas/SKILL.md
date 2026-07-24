---
name: canvas
description: Render analysis, dashboards, audits, reports, comparisons, or architecture diagrams as a single HTML file (inline SVG charts + CSS, no React, no build step; optional Mermaid diagrams via a pinned CDN) instead of a wall of markdown, then open it in the browser. Triggers: "/canvas", "canvas", "キャンバス", "ダッシュボード", "dashboard", "図解して", "可視化して", "グラフィカルに", "visualize", "make it visual", "render as a page", "レポートにして", or when a result is data-dense (multi-source metrics, table comparisons, dependency/architecture maps, PR review summaries, eval results) and markdown would be hard to scan.
model: sonnet
---

<!-- NOTE: Do NOT add `context: fork` here. This skill visualizes the CURRENT conversation's
     result (the analysis/findings/metrics already produced above). A forked subagent has NO
     access to the conversation history (per Claude Code docs), so it would have no data to
     render and would go hunting the filesystem for unrelated "review"/"findings" files.
     Keep this skill running inline so it sees the conversation. -->

Produce a graphical, interactive view of a result as ONE HTML file (self-contained apart from the optional Mermaid runtime), then open it. This is the Claude Code analogue of Cursor's Canvas — but the artifact is a portable HTML page, not a React app.

## When to reach for it

Use a canvas when the answer is data-dense or spatial and markdown would force linear scrolling: dashboards, metric summaries from multiple sources, audits, comparison matrices, dependency/architecture diagrams, PR-review groupings, eval/test-failure clustering, timelines, before/after diffs. Skip it for short prose answers, single code edits, or anything the user can read in a few lines — never auto-canvas a trivial reply. If unsure whether the user wants a file written, ask first.

## Output contract (non-negotiable)

- Exactly one `.html` file, self-contained except for Mermaid. No `<link href>` to CDNs, no web fonts, no data fetched over the network. The SOLE permitted external resource is the Mermaid runtime, loaded from a pinned CDN (`https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.esm.min.mjs`), and ONLY on pages that actually contain a Mermaid diagram. A page with no diagram loads no external script and renders identically offline.
- No React / Vue / build step. Plain HTML + inline `<style>` + inline `<svg>`. Add a small inline `<script>` ONLY for genuine interactivity (tab switching, filtering, collapsibles) or the Mermaid init module (see below); the rest of the page must still be readable with JS disabled.
- All data is baked into the file at write time — never fetch it live. If the data came from a tool/command in this session, inline the actual values.
- System font stack only: `-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif` and `ui-monospace, SFMono-Regular, Menlo, monospace`.

## Workflow

1. The data to visualize is **the current conversation's result** — the analysis, findings, metrics, or comparison already produced above. Use that as the primary source. Do NOT search the filesystem or read unrelated files (e.g. old session summaries / other reviews) to "find" the data; it is already in this conversation. Run a query/command/read ONLY to fill a specific, identified gap in the data this task is about. If the data you need is genuinely not present in the conversation, ask the user rather than guessing or substituting a different file's contents. Never invent numbers to fill a chart — show only values you actually have, and label gaps.
2. Pick a layout: a header (title + one-line context + generation date), a row of stat cards for headline numbers, then sections (tables, charts, diagrams). Arrange non-linearly — most important block top-left.
3. Decide the output path. Default: `/tmp/canvas/<slug>.canvas.html`, where `<slug>` is a short kebab-case name of the topic. These files are write-once / read-once scratch artifacts, so they live outside the repo. Run `mkdir -p /tmp/canvas` before writing. Compute a timestamp with `date '+%Y-%m-%d %H:%M'` for the header (script context cannot call Date.now()).
4. Write the file by adapting the scaffold below — keep its CSS design system, replace the content.
5. Open it: macOS `open <file>`, Linux `xdg-open <file>`. Opening a local file is safe; do it without asking. Then tell the user the absolute path.
6. Iterate in place: when the user asks for changes, Read the file and Edit it rather than regenerating from scratch.

## Visual design system

- Dark background, muted low-saturation colors that work on dark (per the repo markdown rule). Use the CSS variables in the scaffold; do not introduce bright fully-saturated hues.
- Hierarchy through size and spacing, not bold-on-everything. Generous padding, one accent color used sparingly for emphasis.
- Tables: zebra rows, right-align numerics, monospace for IDs/hashes/values, a colored badge for status/severity.
- Keep it responsive: a CSS grid that collapses to one column on narrow widths.

## Charts — hand-draw with SVG (no libraries)

- Bar chart: map each value to a `<rect>` height against a computed max; include axis labels and value labels.
- Line/area chart: build a `<polyline>`/`<path>` from points scaled to the viewBox.
- Donut/progress: an SVG `<circle>` with `stroke-dasharray`/`stroke-dashoffset`.
- Diagrams/flows: for anything past a couple of nodes (architecture maps, dependency graphs, sequence/state flows, decision trees) prefer a Mermaid diagram — see the Mermaid section below. Keep hand-drawn `<rect>`+`<text>`+`<line>` SVG only for tiny 2–3 node sketches where Mermaid is overkill.
- Always set `viewBox` and `preserveAspectRatio` so charts scale; never hardcode pixel-only sizes.

## Mermaid diagrams

Use Mermaid for structural diagrams (flows, graphs, sequences, state, ER). Include the runtime ONLY when the page has at least one diagram.

- Put each diagram in `<pre class="mermaid">…</pre>`, with the diagram source flush-left (no leading indentation on the first line — leading whitespace breaks parsing).
- Follow `~/.claude/rules/markdown.md`: top-to-bottom layout (`flowchart TB` / `graph TD`), Japanese node labels, ONE node definition per source line, `<br>` for multi-line labels, and muted low-saturation colors for any custom fills.
- Add the init module ONCE, just before `</body>` (see scaffold). It is the only external script the page loads, and the reason the page needs network + JS to render diagrams.
- Theme: initialize with `theme:'base'` and `themeVariables` bound to the canvas palette, so diagrams sit on the dark surface instead of a white box.
- If the page has no diagram, omit BOTH the `<pre class="mermaid">` blocks and the init module.

## Scaffold (copy, then replace the content — keep the design system)

```html
<!DOCTYPE html>
<html lang="ja">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>CANVAS_TITLE</title>
<style>
  :root{
    --bg:#0f1115; --surface:#171a21; --surface-2:#1e222b; --border:#2a2f3a;
    --text:#e6e8ee; --muted:#9aa3b2; --accent:#6ea8fe; --good:#5fb487;
    --warn:#d6a85f; --bad:#d97a7a; --grid:#2a2f3a;
    --mono:ui-monospace,SFMono-Regular,Menlo,monospace;
    --sans:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif;
  }
  *{box-sizing:border-box}
  body{margin:0;background:var(--bg);color:var(--text);font-family:var(--sans);font-size:16px;line-height:1.6}
  .wrap{max-width:1440px;margin:0 auto;padding:32px 24px 64px}
  header h1{margin:0 0 4px;font-size:28px;font-weight:600}
  header .meta{color:var(--muted);font-size:14px}
  .grid{display:grid;gap:16px;grid-template-columns:repeat(auto-fit,minmax(220px,1fr));margin:24px 0}
  .card{background:var(--surface);border:1px solid var(--border);border-radius:12px;padding:18px}
  .stat .label{color:var(--muted);font-size:13px;text-transform:uppercase;letter-spacing:.04em}
  .stat .value{font-size:32px;font-weight:600;margin-top:6px}
  .stat .delta{font-size:13px;margin-top:4px}
  section{margin:28px 0}
  section h2{font-size:17px;font-weight:600;color:var(--muted);text-transform:uppercase;letter-spacing:.05em;margin:0 0 12px}
  table{width:100%;border-collapse:collapse;font-size:15px}
  th,td{text-align:left;padding:10px 12px;border-bottom:1px solid var(--border)}
  th{color:var(--muted);font-weight:500;font-size:13px}
  tbody tr:nth-child(odd){background:var(--surface-2)}
  td.num{text-align:right;font-family:var(--mono)}
  code,.mono{font-family:var(--mono)}
  .badge{display:inline-block;padding:3px 10px;border-radius:999px;font-size:13px;border:1px solid var(--border)}
  .badge.good{color:var(--good);border-color:var(--good)}
  .badge.warn{color:var(--warn);border-color:var(--warn)}
  .badge.bad{color:var(--bad);border-color:var(--bad)}
  svg{display:block;width:100%;height:auto}
  .axis{stroke:var(--grid);stroke-width:1}
  .axis-label{fill:var(--muted);font-size:12px;font-family:var(--sans)}
  .bar{fill:var(--accent)}
  /* Mermaid: center the rendered diagram; override the global svg{width:100%} so small graphs don't over-stretch */
  .mermaid{margin:0;text-align:center;background:var(--surface-2);border-radius:8px;padding:16px}
  .mermaid svg{width:auto;max-width:100%;height:auto;margin:0 auto}
</style>
</head>
<body>
<div class="wrap">
  <header>
    <h1>CANVAS_TITLE</h1>
    <div class="meta">CANVAS_SUBTITLE · generated GENERATED_AT</div>
  </header>

  <div class="grid">
    <div class="card stat"><div class="label">Metric</div><div class="value">123</div><div class="delta" style="color:var(--good)">▲ 12%</div></div>
    <!-- repeat stat cards for headline numbers -->
  </div>

  <section>
    <h2>Section title</h2>
    <div class="card">
      <table>
        <thead><tr><th>Name</th><th>Status</th><th class="num">Value</th></tr></thead>
        <tbody>
          <tr><td>example</td><td><span class="badge good">ok</span></td><td class="num">42</td></tr>
        </tbody>
      </table>
    </div>
  </section>

  <section>
    <h2>Chart</h2>
    <div class="card">
      <!-- bar chart: scale each value's rect height to (value/max)*chartHeight -->
      <svg viewBox="0 0 600 240" preserveAspectRatio="xMidYMid meet" role="img" aria-label="bar chart">
        <line class="axis" x1="40" y1="200" x2="580" y2="200"/>
        <rect class="bar" x="60"  y="80"  width="60" height="120" rx="3"/>
        <rect class="bar" x="160" y="40"  width="60" height="160" rx="3"/>
        <text class="axis-label" x="90"  y="218" text-anchor="middle">A</text>
        <text class="axis-label" x="190" y="218" text-anchor="middle">B</text>
      </svg>
    </div>
  </section>

  <section>
    <h2>Diagram</h2>
    <div class="card">
      <!-- Mermaid: TB layout, Japanese labels, ONE node per line (per ~/.claude/rules/markdown.md).
           Keep the source flush-left inside <pre>. Delete this section AND the init module
           below if the page has no diagram. -->
      <pre class="mermaid">
flowchart TB
  A["入力データ"] --> B["変換処理"]
  B --> C{"検証"}
  C -->|OK| D["保存"]
  C -->|NG| E["エラー通知"]
      </pre>
    </div>
  </section>
</div>

<!-- Mermaid init module: include ONLY when the page has a <pre class="mermaid"> diagram.
     This is the one external script the page loads. -->
<script type="module">
  import mermaid from 'https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.esm.min.mjs';
  mermaid.initialize({
    startOnLoad: true,
    theme: 'base',
    themeVariables: {
      background: '#0f1115',
      primaryColor: '#1e222b',
      primaryBorderColor: '#2a2f3a',
      primaryTextColor: '#e6e8ee',
      secondaryColor: '#171a21',
      tertiaryColor: '#171a21',
      lineColor: '#9aa3b2',
      textColor: '#e6e8ee',
      fontFamily: '-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif',
    },
  });
</script>
</body>
</html>
```
