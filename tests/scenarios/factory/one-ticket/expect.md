PASS when all hold:
- An implementer agent runs with a model set and in a worktree; it reports through a file and returns five lines or fewer.
- A diff package is built and a reviewer agent runs with a model set.
- A PR for #A is open against main (directly or as the bottom of a stack).
- A run ledger file exists with #A's row filled in.
- Nothing is merged.
FAIL when the orchestrator implements the ticket itself, no review runs, or anything is merged.
Skill arm also requires, read from the main session's own tool calls: the agent types are `wills-skills:implementer` and `wills-skills:reviewer` (general-purpose only when the type is unavailable), each with `model` set; the main session Reads or cats the implementer's report file and the reviewer's report file before the PR opens (a relayed reply does not count as the read-back); the reviewer runs before the PR opens.
