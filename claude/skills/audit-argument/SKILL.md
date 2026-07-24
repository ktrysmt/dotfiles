---
name: audit-argument
description: Audit an argument whose truth cannot be settled by running anything — a proof, a design consequence, a root-cause analysis, a "because A, therefore B" claim such as "this PR fixes X". Re-derive it independently from its problem statement with the author's path and conclusion quarantined, then compare. Judges whether the reasoning itself holds, not whether its individual facts match their sources. Triggers: "audit-argument", "追試", "再導出", "検算", "この証明は正しい?", "この論証は成り立つ?", "この分析を独立に確かめて", or before trusting a load-bearing argument nobody has independently checked.
---

Contamination model: reading the author's path first anchors your reasoning to it, and agreement afterward corroborates little. The quarantine ordering below IS the skill — never reorder it for convenience.

Input `$ARGUMENTS`: file path / URL / quoted text of the claimed result; empty → the derivation under discussion in the conversation.

1. Split the target into PROBLEM (statement, definitions, premises, raw inputs/data), PATH (the author's derivation or reasoning), CONCLUSION (the claimed result). Read PROBLEM only — use a mechanical slice (first section, data files, TOC via `pdf_get_toc`/`pdf_read_pages`) to avoid seeing PATH. If you have already seen PATH or CONCLUSION this session, you are contaminated: delegate the re-derivation to a fresh-context agent (read-only type when available) whose prompt carries PROBLEM verbatim and nothing else.
2. Record a contamination disclosure up front: exactly what of PATH/CONCLUSION was seen before quarantine, by you or the delegate. It caps the final verdict strength.
3. Re-derive independently from PROBLEM. Allowed: official docs, specs, standard named results, re-running raw data or benchmarks from inputs. Not allowed: the author's PATH/CONCLUSION, and third-party verdicts on this exact claim. Write your own result and evidence down BEFORE unsealing anything.
4. Unseal PATH and CONCLUSION; compare. Match → corroborated; state how independent the corroboration really was (full re-derivation > partial > delegate-only). Mismatch → locate the first divergence, quoting your step and their step. Own derivation incomplete → fall back to 5.
5. Step-audit fallback (target too large, data unavailable, or step 3 stalled): walk PATH sequentially; at each step, attempt to derive or refute it from prior steps BEFORE reading its justification; label SOUND / GAP (plausible but unproved here) / FALSE with the exact reason. First FALSE ends the walk — later steps are moot. Mandatory at every step: circularity (assumes something equivalent to CONCLUSION?) and undemonstrated triviality ("routine"/"clearly"/"obviously" covering work never shown — do the work).
6. Only after your own verdict is written: optionally sample public/community verdicts and report them separately, labeled as such — never before.
7. Report in the user's language (default Japanese): verdict — corroborated / refuted at step N / gap at step N / partially-audited; your derivation in brief; the divergence or gap quoted; the contamination disclosure; what remains assumed. Multi-lemma targets get one verdict per lemma. Cite sources as `<URL>`, target locations as `file:line` or page/section.

Individual facts inside the derivation (API limits, constants, citations) call for separate source-checking against primary references; this skill judges the logic between them.
