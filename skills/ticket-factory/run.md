# Run

**REQUIRED SUB-SKILLS:** wills-skills:implement, wills-skills:review, wills-skills:usage-pacing, and gh-stack. The main session coordinates: implementer agents write every line of ticket code, and a reviewer agent reviews every ticket.

## Set up
Read `run-ledger.md` and `issues.md` in the scratchpad. Request keep-awake where the host offers it.

## Per ticket
1. Follow the main-session steps of wills-skills:implement (dispatch, read-back, review, PR), filling the dispatch fields from the ledger: cache path, branch, model, stack position, reserved number, and report paths.
2. Report paths in the scratchpad are `impl-<n>.md` and `review-<n>.md`; subagents' Write refuses names that begin with report, summary, or findings.
3. Read the implementer's report file and the reviewer's report file, each in a call of its own, before the PR call: each reply is a pointer, and the fix-or-open decision and the PR body come from the files.
4. Must-fix findings: rounds 1–3 resume the implementer with SendMessage and the findings; rounds 4–5 go to a fresh implementer on a stronger model, given the branch and the findings. Each round ends with a new package and review. A blocked ticket (its report says so, or round 5 still fails) holds the tickets above it; other chains go on, and Close lists it with the reason.
5. A stacked ticket's PR opens once its own review is clean, bottom first, with `gh stack` (gh-stack).
6. A ticket that turns out to need a migration takes the ledger's next free number, recorded in Numbers, before any file is written; the implementer receives that number.
7. Ledger upkeep, before the next tool call and before any reply to the user:
   - A ticket's Status follows the Status line of its agent's own report (done, checkpointed, blocked): read the report, then set the row from it. `blocked` puts the reason in Notes, and round 5 still failing sets it too.
   - Your own actions set the rest: `implementing` when the implementer is dispatched; `reviewing` before the reviewer is dispatched, only when the implementer's report says done; `fixing <round>` when findings are sent or a fresh implementer is dispatched; `pr-open` with the PR when it opens.
   - Each dispatch adds the agent's ID and Worktree to the row once the call returns.
   - A `checkpointed` row is resumed with SendMessage, lowest stack position first; the resumed agent's report sets the row again.

## Discipline
- At most one agent on opus at a time. Read usage before every launch and log every reading in the ledger's Usage table, since the burn rate comes from two rows; wills-skills:usage-pacing sets the re-read interval, the other caps, and the checkpoint.
- Use absolute paths and `git -C`; put `--repo <repo>` on every `gh issue` and `gh pr` call and `repos/<repo>/` in every `gh api` path. The session's cwd stays where it started.
- Batch independent calls into one message.
- Stop any background process an agent left running once its branch is pushed.

## Close
Summarize the PRs, each stack and its merge order, held numbers, blocked tickets with their reasons, and decisions taken; this summary may run longer than five lines. File follow-ups as issues labeled `needs-triage`. Save the run's lessons to memory. Merging into the default branch and restacking (`gh stack sync`) are gh-stack's work, and wait for the user's go-ahead.
