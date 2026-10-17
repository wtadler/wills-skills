---
name: tickets-to-prs
description: Use when asked to work through a labeled backlog, ready-for-agent issues, or several tickets, all or some of them, especially unattended, or to run tickets-to-prs or the ticket factory.
---

# Tickets to PRs

A labeled backlog becomes reviewed, stacked PRs, paced to the usage window. This file is the plan. `<repo>` is the backlog's owner/name (`gh repo view --json nameWithOwner`).

## Plan
Planning reads, and writes scratchpad files only, apart from step 2's worktree sweep; agents and the repo wait for the go-ahead.
1. Backlog: `gh issue list --repo <repo> --label <label> --state open --limit 200 --json number,title`, with `ready-for-agent` as the default label. Cache each ticket and its parent into `issues.md` in the scratchpad under `=========== #<n>` headings, from `gh issue view <n> --repo <repo> --json title,body,comments` (plain `gh issue view` can print nothing). Agents read this file instead of calling `gh`.
2. `git fetch --prune`, then read remote state from the fresh refs. Sweep agent worktrees (those under the host's agent-worktree directory, such as `.claude/worktrees/`): remove each one whose branch has a merged or closed PR and no open one (`gh pr list --repo <repo> --head <branch> --state all --json state`) with `git worktree remove` (never `--force`; one with uncommitted changes stays and the plan lists it), then `git worktree prune`. Branches stay. Each worktree carries its own dependencies, so leftovers fill the disk.
3. Blockers: the native links (`gh api repos/<repo>/issues/<n>/dependencies/blocked_by`), else the "Blocked by" lines. Overlap: `gh pr list --repo <repo>`, then `gh pr diff <n> --repo <repo> --name-only` for each open PR.
4. Stacks: a stack is one linear chain, and each dependency chain becomes one. A ticket blocked on two chains goes after both on one chain, or waits for one blocker to merge; the plan says which.
5. Migrations: the numbers taken are those on the default branch, on every remote branch, and in open PRs. Give each migrating ticket the next free number, so parallel agents never collide; the ledger records them.
6. Models: implementers on sonnet, and on opus only when the design risk lives in the implementation: a migration on existing data, at-most-once or queueing semantics, fail-closed sync, or matching records across sources. A ticket in wills-skills:review's opus row that follows an existing pattern (one more rate-limited endpoint, a content-type fix, a swapped sender) keeps a sonnet implementer, and its first review is on opus. Reviewers by that table; a re-review of fix commits may drop to sonnet. Same-shape small tickets share one agent.
7. Waves: a stacked ticket starts once the ticket below it has a clean review (branch pushed, no must-fix), and chains with no link between them run side by side, within wills-skills:usage-pacing's caps.
8. Write `run-ledger.md` in the scratchpad from [ledger-template.md](ledger-template.md): the Numbers, and one Tickets row per ticket (status `planned`, with model, branch, and base).
9. Reply with the plan: tickets covered, each stack in order, numbers, models, waves, and exclusions. With no go-ahead in the request, that reply ends the turn.

## After the go-ahead
The user's go-ahead arrives in a later message; follow [run.md](run.md) then. A go-ahead already given in the request covers the tickets it names or describes, and none it excludes; step 9's reply then opens the run instead of ending the turn.
