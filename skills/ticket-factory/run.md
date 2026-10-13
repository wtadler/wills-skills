# Run

**REQUIRED SUB-SKILLS:** wills-skills:implement, wills-skills:review, wills-skills:usage-pacing, and gh-stack. The main session coordinates: implementer agents write every line of ticket code, and a reviewer agent reviews every ticket.

## Set up
Read `run-ledger.md` and `issues.md` in the scratchpad. Request keep-awake where the host offers it.

## Per ticket
1. Follow the main-session steps of wills-skills:implement (dispatch, read-back, review, fix rounds, PR), filling the dispatch fields from the ledger: cache path, branch, model, stack position, reserved number, and report paths in the scratchpad.
2. A blocked ticket (its report says so, or round 5 still fails) holds the tickets above it; other chains go on, and Close lists it with the reason.
3. A stacked ticket's PR opens once its own review is clean, bottom first, with `gh stack` (gh-stack).
4. A ticket that turns out to need a migration takes the ledger's next free number, recorded in Numbers, before any file is written; the implementer receives that number.
5. Ledger upkeep, before the next tool call and before any reply to the user:
   - A ticket's Status follows the Status line of its agent's own report (done, checkpointed, blocked): read the report, then set the row from it. `blocked` puts the reason in Notes, and round 5 still failing sets it too. A checkpoint message that stops a reviewer sets `checkpointed`, since a review report has no Status line.
   - Your own actions set the rest: `implementing` when the implementer's Agent call returns its launch result, not at the completion notice; `reviewing` before the reviewer is dispatched, only when the implementer's report says done; `fixing <round>` when findings are sent or a fresh implementer is dispatched; `pr-open` with the PR when it opens.
   - The same launch result adds the agent's ID and Worktree to the row, each ID labeled `impl` or `review` in the Agent IDs column.
   - A `checkpointed` row keeps its round, for example `checkpointed (fixing 2)`. It is resumed with SendMessage, lowest stack position first; the row goes back to `implementing` or `fixing <round>` at the resume, and the resumed agent's report sets it again.

## Discipline
- At most one agent on opus at a time. Read usage before every launch and log every reading in the ledger's Usage table, since the burn rate comes from two rows; wills-skills:usage-pacing sets the re-read interval, the other caps, and the checkpoint.
- Use absolute paths and `git -C`; put `--repo <repo>` on every `gh issue` and `gh pr` call and `repos/<repo>/` in every `gh api` path. The session's cwd stays where it started.
- Batch independent calls into one message.
- Stop any background process an agent left running once its branch is pushed.

## Close
Summarize the PRs, each stack and its merge order, held numbers, blocked tickets with their reasons, and decisions taken; this summary may run longer than five lines. File follow-ups as issues labeled `needs-triage`. Save the run's lessons to memory. Merging into the default branch and restacking (`gh stack sync`) are gh-stack's work, and wait for the user's go-ahead.
