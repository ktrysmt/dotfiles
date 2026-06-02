---
name: canvas
description: Render analysis, dashboards, audits, reports, comparisons, or architecture diagrams as a single self-contained HTML file (inline SVG charts + CSS, no React, no CDN, works offline) instead of a wall of markdown, then open it in the browser. Triggers: "/canvas", "canvas", "キャンバス", "ダッシュボード", "dashboard", "図解して", "可視化して", "グラフィカルに", "visualize", "make it visual", "render as a page", "レポートにして", or when a result is data-dense (multi-source metrics, table comparisons, dependency/architecture maps, PR review summaries, eval results) and markdown would be hard to scan.
model: sonnet
context: fork
---

Produce a graphical, interactive view of a result as ONE self-contained HTML file, then open it. This is the Claude Code analogue of Cursor's Canvas — but the artifact is a portable HTML page, not a React app.

## When to reach for it

Use a canvas when the answer is data-dense or spatial and markdown would force linear scrolling: dashboards, metric summaries from multiple sources, audits, comparison matrices, dependency/architecture diagrams, PR-review groupings, eval/test-failure clustering, timelines, before/after diffs. Skip it for short prose answers, single code edits, or anything the user can read in a few lines — never auto-canvas a trivial reply. If unsure whether the user wants a file written, ask first.

## Output contract (non-negotiable)

- Exactly one `.html` file, fully self-contained. No external `<script src>`, no `<link href>` to CDNs, no web fonts, no network calls. It must render identically offline and when shared as a single file.
- No React / Vue / build step. Plain HTML + inline `<style>` + inline `<svg>`. Add a small inline `<script>` ONLY for genuine interactivity (tab switching, filtering, collapsibles); the page must still be readable with JS disabled.
- All data is baked into the file at write time — never fetch it live. If the data came from a tool/command in this session, inline the actual values.
- System font stack only: `-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif` and `ui-monospace, SFMono-Regular, Menlo, monospace`.

## Workflow

1. Gather the real data first (run the queries/commands/reads you need). Never invent numbers to fill a chart — show only values you actually have, and label gaps.
2. Pick a layout: a header (title + one-line context + generation date), a row of stat cards for headline numbers, then sections (tables, charts, diagrams). Arrange non-linearly — most important block top-left.
3. Decide the output path. Default: `./<slug>.canvas.html` in the current working directory, where `<slug>` is a short kebab-case name of the topic. Compute a timestamp with `date '+%Y-%m-%d %H:%M'` for the header (script context cannot call Date.now()). If writing into a git repo the user may not want tracked, mention the path so they can gitignore it.
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
- Diagrams/flows: position `<rect>`+`<text>` nodes and connect with `<line>`/`<path>` + a marker arrowhead. For complex graphs prefer an inline `<svg>` you lay out by hand; only use a Mermaid block if rendering to HTML is not required.
- Always set `viewBox` and `preserveAspectRatio` so charts scale; never hardcode pixel-only sizes.

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
  body{margin:0;background:var(--bg);color:var(--text);font-family:var(--sans);line-height:1.5}
  .wrap{max-width:1100px;margin:0 auto;padding:32px 24px 64px}
  header h1{margin:0 0 4px;font-size:24px;font-weight:600}
  header .meta{color:var(--muted);font-size:13px}
  .grid{display:grid;gap:16px;grid-template-columns:repeat(auto-fit,minmax(220px,1fr));margin:24px 0}
  .card{background:var(--surface);border:1px solid var(--border);border-radius:12px;padding:18px}
  .stat .label{color:var(--muted);font-size:12px;text-transform:uppercase;letter-spacing:.04em}
  .stat .value{font-size:28px;font-weight:600;margin-top:6px}
  .stat .delta{font-size:12px;margin-top:4px}
  section{margin:28px 0}
  section h2{font-size:15px;font-weight:600;color:var(--muted);text-transform:uppercase;letter-spacing:.05em;margin:0 0 12px}
  table{width:100%;border-collapse:collapse;font-size:14px}
  th,td{text-align:left;padding:9px 12px;border-bottom:1px solid var(--border)}
  th{color:var(--muted);font-weight:500;font-size:12px}
  tbody tr:nth-child(odd){background:var(--surface-2)}
  td.num{text-align:right;font-family:var(--mono)}
  code,.mono{font-family:var(--mono)}
  .badge{display:inline-block;padding:2px 9px;border-radius:999px;font-size:12px;border:1px solid var(--border)}
  .badge.good{color:var(--good);border-color:var(--good)}
  .badge.warn{color:var(--warn);border-color:var(--warn)}
  .badge.bad{color:var(--bad);border-color:var(--bad)}
  svg{display:block;width:100%;height:auto}
  .axis{stroke:var(--grid);stroke-width:1}
  .axis-label{fill:var(--muted);font-size:11px;font-family:var(--sans)}
  .bar{fill:var(--accent)}
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
</div>
</body>
</html>
```
