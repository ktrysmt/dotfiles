# Change verification

- Back every behavioral claim with a doc URL or a command run in this session. In PR bodies and runbooks, cite that URL or command next to the claim. In code comments, cite a doc URL only where the behavior is non-obvious. Never write an unverified claim as fact: mark it unverified or list it as an open item.
- IAM: trace the full call chain (caller -> service -> assumed role) against AWS docs, and list every required action for each principal, including `iam:PassRole` wherever a role is passed to a service.
- When repo docs conflict with vendor docs (AWS, GitHub, library docs), the vendor docs win unless a live test in this session shows otherwise. Record the conflict as an open item.
- Before writing logic against a resource, grep its IaC definition (CloudFormation/CDK/Terraform) for limits and settings (e.g. CodeBuild `ConcurrentBuildLimit`, triggers) and for invariants stated in comments. Check the new code against each one.
- Env-conditional output: bundle and inspect every env (staging and prod).
- Before reporting done, list failure scenarios: concurrency, stale or duplicate input, per-principal permissions, env differences. Answer each with a test or a citation. Put the list in the PR body or the open items, not in the chat reply.
- Fix a gap you notice in the same change when it is within the agreed scope; otherwise list it as an open item. Never mention it only in passing.
- Run project tools in non-mutating mode (`uv run --frozen`), and check `git status` afterwards.
