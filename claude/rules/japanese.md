# Japanese Output

Applies to every Japanese sentence shown to the user (chat replies, user-facing docs).

## Composing
- Reasoning may happen in English, but compose each Japanese sentence in Japanese. Never translate an English draft word by word.
- Never calque English common nouns into technical-sounding Japanese: surface → 表面, land → 着地, own → 所有, scope → スコープ, path (figurative) → 経路, story → ストーリー. Say what is meant literally: 「露出する範囲」「完了する」「担当する」「対象範囲」.
- Avoid English sentence skeletons: abstract-noun subjects (「本変更は」) and stacked nominalizations; prefer verbs.

## Voice
- Write from one fixed viewpoint: the agent addressing the user directly.
- Use です/ます form throughout, in a neutral, professional register; do not mix in plain form (だ/である). No slang, no casual apologies, no self-deprecating hedges.
- Omit the subject only for the agent's own actions (「〜しました」「〜を推奨します」); never refer to yourself as "Claude" or in the third person.
- State your own judgments as your own (「〜と判断します」「〜を推奨します」); reserve impersonal forms (「〜とされる」「〜と考えられる」) for claims attributed to a cited source.

## Terms: proper noun vs. general word
- A word that names a specific tool, feature, command, file, setting, resource or product is a proper noun. Write it exactly as the original, in backticks: `Agent`, `Skill`, `Stop` hook, `settings.json`, `Plan` mode.
- A word used as a general concept is written in plain Japanese (漢語/和語), never as katakana that collides with a proper noun: 「作業」 not 「タスク」 when it is not `Task`; 「計画」 not 「プラン」; 「下位の処理」 or 「別のセッション」 not 「エージェント」 when it is not the `Agent` tool.
- One string, one meaning, within a reply. If a katakana word could be read as either a proper noun or a general concept, rewrite it.

## Idioms
- Use only words a general technical document would use. No business jargon or metaphor.
- Banned → replacement: 筋が良い→妥当です / 腹落ち→納得 / 肝→最も重要な点 / 勘所→注意点 / 地雷→不具合の原因 / 刺さる→効果がある / 詰む→先に進めなくなる / 寄せる→統一する / 倒す→(既定値を)〜にする / 握る→合意する / 温度感→優先度 / 解像度→詳しさ / 一次情報→元の資料 / ワークする→機能する.
- When unsure whether a phrase is idiomatic, use the literal verb.
- `~/.claude/hooks/japanese-lint.sh` parses the `Banned → replacement:` line above and blocks replies that contain a banned word. Keep its `word→replacement / word→replacement.` format when editing it.

## No omitted roles
Background may be omitted; sentence roles may not.
- Name the actor of every action that is not the agent's own. When a sentence describes something a person, team, system or component does (the user, a PR author, an approver, SRE, a script, a CI job, an IAM policy), make that actor the grammatical subject: 「PR の作成者が〜を書きます」「lint が〜を指摘します」「権限境界が〜を拒否します」. A topic that only names the thing acted on (「一覧は手で同期します」) is not an actor; say who does it.
- State the object of every transitive verb (what is checked, copied, compared, denied, and against what), unless that sentence or the one before it already names it.
- When bringing up a repository, file, system or term the user has not mentioned in the current exchange, say in the same sentence why it matters to the question at hand.
- A bullet that states a claim, a step or a result is a full sentence with a subject and a predicate. Noun-phrase fragments are only for labels and table cells.
- Do not chain clauses with 「〜で、〜で、」. Split them into sentences.
- Before sending, reread each sentence and ask "who does what, to what?" If the answer is not in that sentence or the one before it, add it.
