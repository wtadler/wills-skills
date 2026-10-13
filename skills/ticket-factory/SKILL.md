---
name: ticket-factory
description: Use when asked to work through a labeled backlog, ready-for-agent issues, or several tickets, all or some of them, especially unattended, or to run the ticket factory.
---

# Ticket Factory

A labeled backlog becomes reviewed, stacked PRs, paced to the usage window. This file is the plan, and the plan is where the turn ends.

## Plan
Planning is read-only: no agent is dispatched, and nothing in the repo changes.
1. Backlog: `gh issue list --label <label> --state open --limit 200 --json number,title`, with `ready-for-agent` as the default label. Cache each ticket and its parent into `issues.md` in the scratchpad under `=========== #<n>` headings, from `gh issue view <n> --json title,body,comments` (plain `gh issue view` can print nothing). Agents read this file instead of calling `gh`.
2. `git fetch --prune`, then read remote state from the fresh refs.
3. Blockers: the native links (`gh api repos/{owner}/{repo}/issues/<n>/dependencies/blocked_by`), else the "Blocked by" lines. Overlap: `gh pr list`, then `gh pr diff <n> --name-only` for each open PR.
4. Stacks: a stack is one linear chain, and each dependency chain becomes one. A ticket blocked on two chains goes after both on one chain, or waits for one blocker to merge; the plan says which.
5. Migrations: the numbers taken are those on the default branch, on every remote branch, and in open PRs. Give each migrating ticket the next free number, so parallel agents never collide; the ledger records them.
6. Models: implementers on sonnet, and on opus when the diff falls in wills-skills:review's opus row; reviewers by that table. Same-shape small tickets share one agent.
7. Waves: a ticket starts once the branch below it is pushed, and chains with no link between them run side by side, within wills-skills:usage-pacing's caps.
8. Write `run-ledger.md` in the scratchpad from [ledger-template.md](ledger-template.md): the Numbers, and one Tickets row per ticket (status `planned`, with model, branch, and base).
9. Reply with the plan: tickets covered, each stack in order, numbers, models, waves, and exclusions. That reply is the end of the turn.

## After the go-ahead
The user's go-ahead arrives in a later message; follow [run.md](run.md) then. A go-ahead already given in the request starts the run, on the tickets it names, right after step 9.
