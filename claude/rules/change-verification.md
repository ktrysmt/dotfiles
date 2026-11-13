# Change verification

- Back every behavioral claim with a doc URL or a command run in this session. In PR bodies and runbooks, cite that URL or command next to the claim. In code comments, cite a doc URL only where the behavior is non-obvious. Mark every unverified claim as unverified, or list it as an open item.
- IAM: trace the full call chain (caller, service, assumed role) against AWS docs, and list every required action for each principal, including `iam:PassRole` wherever a role is passed to a service.
- Define IAM from the AWS Service Authorization Reference first: the `list_<service prefix>.html` page, column `Resource types (*required)`. Fetch it directly if a doc tool fails. Then diff it against implementations already in operation (repo, Terraform, live), and state the reason and the risk of each difference. Never use an example or an existing implementation as the definition.
- When repo docs conflict with vendor docs, the vendor docs win unless a live test in this session shows otherwise. Record the conflict as an open item.
- Before writing logic against a resource, read its IaC definition for limits, settings and invariants stated in comments, and check the new code against each one.
- For env-conditional output, bundle and inspect every env.
- Before reporting done, list failure scenarios: concurrency, stale or duplicate input, per-principal permissions, env differences. Answer each with a test or a citation. Put the list in the PR body or the open items, not in the chat reply.
- Fix a gap you notice in the same change when it is within the agreed scope. Otherwise list it as an open item.
- Run project tools in non-mutating mode, and check `git status` afterwards.
