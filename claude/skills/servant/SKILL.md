---
name: servant
description: >-
  One pass over the user's own open Jira issues: classify each as a review,
  implementation or other task from the URLs in its summary and description, apply
  the two Jira updates the user pre-authorized ([review] prefix, REVIEW-OK status),
  prepare local fixes and reply drafts for review feedback on the user's own pull
  requests, propose Slack-evidenced completions, and render the overview canvas.
  Started by the `servant` shell function in a background session, which then
  re-runs `/servant` every 20 minutes. Triggers: "/servant", "servantを回して",
  "担当チケットを巡回して".
disallowed-tools: AskUserQuestion
model: sonnet
effort: low
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash(~/.claude/skills/servant/servant.py *)
  - mcp__slack__slack_read_thread
---

One invocation is one pass. Each pass is stateless: everything it needs from
earlier passes is in the files under `~/.local/state/servant/`, read and written
only through `~/.claude/skills/servant/servant.py` (written `S` below). Never rely
on what an earlier pass in this conversation said, and never ask the user
anything: nobody is watching. Report what needs the user on the canvas instead.

## Authority

The user pre-authorized exactly two kinds of write to Jira: the `[review]` summary
prefix (`add_review_prefix`) and the transition to REVIEW-OK
(`transition_review_ok`). Both go only through `S apply KEY <type>`, for a line that
block [1] of `S scan` printed. `S apply` reads the issue and its GitHub links again,
writes only if they still call for the update, writes a fixed value through
light-jira's helper, verifies the result and records it. Never call light-jira, its
helper or the Jira API yourself.

Everything else stays local, because the user wants to answer or confirm first:

- Code fixes stay as uncommitted changes in a servant worktree.
- Replies stay as draft files.
- Every judgment call becomes a proposal on the canvas: Slack-evidenced completion,
  a pull request closed without merge, a ticket that may need `[review]`, an update
  held because a GitHub link could not be read in full.

Never push, commit, comment, review, merge, post to Slack, or write to Confluence.
A guard (`~/.claude/skills/servant/guard.py`, hooked in by the session's settings)
blocks every tool call this pass does not need:

- Bash runs only `S`, as one plain command: no `$`, backticks, backslashes, line
  breaks, pipes, `;`, `&&` or redirects, even inside quotes.
- Edit and Write reach only files under `~/.local/state/servant/worktrees/` and
  `~/.local/state/servant/drafts/`.

A block is final for this pass: note it and move on, and never look for another way
to do the same thing.

## Time limits

The Mac sleeps and the Wi-Fi drops, so `S` ends every network call on time: each
command stops within 90 seconds (`S worktree`: 240) and exits 5 when the network did
not answer, with nothing saved. Run `S` exactly as `~/.claude/skills/servant/servant.py
<args>`, with the Bash tool's default timeout; give `S worktree` `timeout` 300000.

- Exit 5 from any step: the network is down for this pass. Note it and go to step 7.
- If the Bash tool still moves an `S` command to the background, treat it as exit 5.
  Do not wait for it, read its output or stop it: it ends by itself within its limit,
  and the next `S lock` stops anything an earlier pass left running.
- Ignore notifications about background commands. They belong to earlier passes.

## Pass

Run the steps in order. If a step fails, note the failure and continue with the
next step; steps 7 and 8 always run once step 0 succeeded.

0. `S lock`. Exit status 3 means another pass is running: reply
   `skipped: a pass is already running` and stop. Otherwise it also stops the `S`
   commands earlier passes left running.

1. Schedule. Only when `S context` prints `background`:
   - Load the cron tools: ToolSearch `select:CronCreate,CronList,CronDelete`.
   - `S meta`. It prints the `schedule` to use and whether to `renew` the job.
   - `CronList`. Take the jobs whose prompt is exactly `/servant`.
   - None: `CronCreate` with cron set to the printed `schedule`, prompt `/servant`,
     recurring true. Then `S meta --cron-job <job id>`.
   - More than one: `CronDelete` all but one.
   - `renew: yes`: `CronDelete` the job, create a new one as above, and record it.
     This keeps the job clear of the 7-day expiry and on the current schedule.

2. `S scan`. It prints the to-do in four numbered blocks. If it fails, go to step 7.

3. Block [1], auto actions. For each printed line, in the printed order, run
   `S apply KEY <type>` and act on its exit status:
   - 0: written, verified and recorded. Go on.
   - 3: Jira or GitHub no longer call for it, and nothing was written. Go on.
   - 4: this pass already made 5 updates. Stop block [1]; the next pass does the rest.
   - 1: the write failed. `S apply` recorded the failure, and the scan skips that
     update for 24 hours. Go on.
   - 5: the network did not answer. Go to step 7; the next pass checks again.
   - Anything else: note the error and go on.

4. Block [2], review feedback on the user's own pull requests. Handle at most 3
   tickets. For each, `S feedback KEY` prints every open item in full, with its `id`.
   Decide per item:
   - It needs a code change: `S worktree <pull request URL>` prints a worktree path.
     Edit files only inside that path. Never commit. Do not run the repository's
     lint or tests: the guard blocks every command but `S`, so the user runs them. If the worktree is reported `dirty` or `diverged`, leave its
     files alone and only draft a reply.
   - It needs an answer: write the reply in Japanese, following
     `~/.claude/rules/japanese.md`, to
     `~/.local/state/servant/drafts/<owner>-<repo>-<number>/<short-slug>.md`.
   - Record the item: `S note KEY --handled <id> --how fix|draft|none` plus
     `--path <worktree>` for a fix, `--draft <file>` for a reply, and
     `--memo "<one Japanese line: what changed or why nothing; for a fix, end with テスト未実行>"`.
     Use `none` only for items that need nothing, such as a plain acknowledgement.

5. Block [3], Slack threads. For each line, call `slack_read_thread` with the
   printed `channel_id` and `message_ts`, `oldest` set to the printed value (omit it
   when the value is `-`), `response_format` detailed, `limit` 100. Then:
   - `S note KEY --slack-seen <url> <newest message ts you read>`.
   - If the new messages show the work is finished, such as an explicit
     done/完了 message, a :done:-like reaction, or the requester agreeing that the
     request is settled, record a proposal:
     `S note KEY --proposal "Slack で完了と読めます: 「<one short quote>」" --evidence <url>`.
   - Never change Jira on Slack evidence.

6. Block [4], work summaries. Take at most 10 keys, in the printed order. For each,
   `S ticket KEY`, then read only what you need: the description file it prints,
   `S view <GitHub URL>` (title and the first 4000 characters of the body), and the
   page title in a Confluence URL. Then record:
   `S note KEY --summary "<仕事内容>" --next "<次の作業 or ->"`. Write both in
   Japanese, each 60 characters or fewer.

7. `S render`. It rewrites `~/.local/state/servant/canvas.html`, which reloads
   itself every 5 minutes in the user's browser. Never open the browser yourself.

8. `S unlock`. Then reply in at most 5 lines: the Jira updates made, the feedback
   items handled, the proposals added, and the canvas path.
