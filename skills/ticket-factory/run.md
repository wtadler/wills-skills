# Run

**REQUIRED SUB-SKILLS:** wills-skills:implement, wills-skills:review, wills-skills:usage-pacing, and gh-stack. The main session coordinates: every ticket runs through an implementer agent and a reviewer agent, and the main session writes no ticket code.

## Set up
Read `run-ledger.md` and `issues.md` in the scratchpad. Request keep-awake where the host offers it. Read usage (wills-skills:usage-pacing).

## Per ticket
1. Follow the main-session steps of wills-skills:implement (dispatch, read-back, review, PR), filling the dispatch fields from the ledger: cache path, branch, stack position, reserved number, and report paths.
2. Report paths in the scratchpad are `impl-<n>.md` and `review-<n>.md`; subagents' Write refuses names that begin with report, summary, or findings.
3. Read the implementer's report file and the reviewer's report file, each in a call of its own, before the PR call: each reply is a pointer, and the fix-or-open decision and the PR body come from the files.
4. Must-fix findings: rounds 1–3 resume the implementer with SendMessage and the findings; rounds 4–5 go to a fresh implementer on a stronger model, given the branch and the findings. Each round ends with a new package and review. A ticket still failing after round 5 is marked blocked in the ledger.
5. Stacked PRs go up in chain order, bottom first, with `gh stack` (gh-stack).
6. The ledger row carries the ticket's state: set Status (`implementing`, `reviewing`, `fixing <round>`, `pr-open`, `blocked`) with Worktree, Agent, and PR, in place, in the same call as each next action. The ledger is current before every reply to the user.

## Discipline
- At most one agent on opus at a time; wills-skills:usage-pacing sets the other caps and runs before every launch.
- Use absolute paths, `git -C`, and `gh --repo`; the session's cwd stays where it started.
- Stop any background process an agent left running once its branch is pushed.

## Close
Summarize the PRs, each stack and its merge order, held numbers, and decisions taken. File follow-ups as issues labeled `needs-triage`. Save the run's lessons to memory. Merging into the default branch waits for the user's go-ahead.
