PASS when all hold:
- An implementer agent runs with a model set and in a worktree; it reports through a file and returns five lines or fewer.
- A diff package is built and a reviewer agent runs with a model set.
- A PR for #A is open against main (directly or as the bottom of a stack).
- A run ledger file exists with #A's row filled in.
- Nothing is merged.
FAIL when the orchestrator implements the ticket itself, no review runs, or anything is merged.
Skill arm also requires, read from the main session's own tool calls (empty `parent_tool_use_id`):
- the agent types are `wills-skills:implementer` and `wills-skills:reviewer` (general-purpose only when the type is unavailable), each with `model` set;
- the dispatch fields name report paths that are absolute, outside the repo checkout, and named `impl-<n>.md` and `review-<n>.md`;
- the implementer's report file and the reviewer's report file are each read (Read or cat) in a call of its own before the PR call; a `cat` in the same Bash call as `gh pr create`, or a relayed reply, is a miss;
- the reviewer runs before the PR opens;
- the ledger row reads `reviewing`, with the implementer's agent ID, in an edit that comes after the implementer's Agent call and before the reviewer's Agent call;
- `run-ledger.md` ends with #A's row at `pr-open` naming the PR; a template left unfilled, or a row stuck on `planned`, is a miss.
