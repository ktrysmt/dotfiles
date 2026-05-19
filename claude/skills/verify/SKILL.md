---
name: verify
description: Aggressively fact-check claims in the last assistant message or specified text/file against authoritative sources (AWS docs MCP, WebSearch, WebFetch, agent-browser, gh, package registries). Depth-first per claim — exhaust evidence, follow references, run adversarial counter-queries before moving on. Triggers: "verify", "ファクトチェック", "エビデンスチェック", "本当に合ってる?", "ソースは?", "検証して", or right after producing technical content with API names, versions, config keys, quotas, ARNs, or URLs.
---

Read-only, paranoid, depth-first. Exhaust evidence per claim before moving on. Accuracy > speed.

Input `$ARGUMENTS`: empty → last assistant turn (ask user to paste if unreadable); file path → `Read`; quoted text → use as-is.

Tiers — t1: RFC/W3C/ISO/AWS API ref/vendor official docs at current version/upstream README at pinned commit. t2: vendor blog/release notes/changelog/GitHub releases. t3: high-vote recent SO, established community docs. hint (never evidence, only a dig signal): AI Overview/AI summaries/low-vote Q&A/marketing.

Routing (primary + independent secondary; if primary unavailable, promote secondary, add a new independent one, note in report). AWS: `mcp__aws-docs__aws___{search,read}_documentation` → AWS blog/release notes via `WebFetch`. Static URL: `WebFetch` (+ `web.archive.org` when freshness matters). JS/SPA/anti-bot: `Skill(agent-browser)` + underlying JSON via `WebFetch`. Login-gated: `Skill(agent-browser-9222)`. General: `WebSearch` → `WebFetch` top hit + independent second. GitHub: `gh` + `WebFetch`. Package version: registry CLI (`npm view`/`pip index versions`/`cargo search`/`gem info`) + upstream changelog. Default `WebFetch`; escalate to `agent-browser` only when insufficient; `9222` only when session required.

1. Resolve target. Never verify text not read this turn.
2. Extract every checkable claim exhaustively (API/IAM/ARN/quota/default/signature/flag/config key/env var/version/URL/spec citation/behavioral claim/deprecation/well-known paths). Exclude opinions, plans, subjective phrasing, accepted code. Order by severity: numeric constants > API/flag signatures > URLs/paths > behavioral. If >30, list all and ask user to prioritize.
3. Across claims primaries may parallelize; within a claim primary → secondary → references → adversarial is strictly sequential.
4. Dig recursively — when a source links to the document that defines the claim, open it and confirm the exact sentence. Chase until t1, no new references, cycle detected, or 5 hops per claim (then surface as `likely` with depth note).
5. Capture exact sentence/code block, anchor, verbatim value in the source's language (translation only as gloss). URL alone is not evidence. Search snippet is not evidence — open the page. Two sections of one source disagreeing = contested within that source; seek a tiebreaker.
6. Freshness: confirm doc covers implied version. Stale doc vs newer release notes → `contested`, side with newer. Re-fetch date-sensitive values in this session; never reuse prior-turn results.
7. Adversarial (mandatory). Pick ≥3 from this menu (more if version-sensitive), one query each: (a) `"<X>" deprecated|removed|breaking change`; (b) changelog diff implied-version vs current; (c) GitHub issues reporting opposite behavior; (d) alt docs (region/version/beta vs GA); (e) `"X does not Y"` / `"X bug"`. All must return no counter-evidence to pass.
8. Forced +1 drill-down on any of: version-dependent wording ("current"/"latest"/"as of"); `deprecated`/`legacy`/`will be removed`; numeric disagreement; summary-style quote without committed value; source covers only V−1 or V+1; second source is t3 while a second t1/2 exists.
9. Confidence: `verified` = ≥1 t1/2 pinpoint + ≥1 independent second (t≥3) same value + adversarial clean + all relevant refs followed. `likely` = t3-only, partial adversarial, or hop-budget hit. `contested` = two t1/2 give different values. `mismatched` = a t1/2 source contradicts the claim. t3-only caps at `likely`. Effort is not termination. For the assistant's own output, require two independent t1/2 sources on any plausible-looking API/flag/default/quota/version constant.
10. `unverifiable` only for hard blocks: paywall; login wall + no 9222; rate limit + retry exhausted; 404 + no archive; anti-bot on every viable path. Slow ≠ unverifiable. Never silently downgrade.

Report in user's language (default Japanese). Per claim, separate lines: `- <claim>` / `  引用: "<exact sentence, source language>"` / `  根拠 (tier N): <URL>` / `  追認: <URL>` / `  反証: <H1>/<H2>/<H3> → clean`. `contested` → replace 根拠/追認 with `source A:`/`source B:` (quote+URL+tier) + `推奨:`. `mismatched` → add `正: <value>` + `箇所: <file:line|直前の応答>`. `unverifiable` → step-10 reason. Append URLs as `<https://...>`. Never edit the original claim.

Example — `- SQS FIFO per-API throughput limit / 引用: "300 send, receive, or delete API actions per second" / 根拠 (t1): <url> / 追認 (t2): <url> / 反証: deprecated? / changelog diff / opposite reports → clean`.
