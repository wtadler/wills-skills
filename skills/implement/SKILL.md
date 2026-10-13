---
name: implement
description: Use when implementing a GitHub issue or ticket, when asked to build one piece of tracked work, or when dispatched as an implementer.
---

# Implement

**REQUIRED SUB-SKILLS:** superpowers:test-driven-development and superpowers:verification-before-completion.

## Where it runs
A prompt that opens "You are the implementer", or bounded work with no ticket: implement here.

Asked in the main session for a ticket (an issue number or link), dispatch and review however small or urgent:
1. Dispatch an implementer: agent type `wills-skills:implementer` (general-purpose if unavailable), with `isolation: worktree` where available and `model: sonnet` unless the user or the run ledger names another. Open its prompt "You are the implementer: load wills-skills:implement," then the dispatch fields.
2. Read its report file in a call of its own: the reply is a pointer.
3. Load wills-skills:review and run it on the branch. The review is the reviewer's report file, read in a call of its own before any PR call, not your own read of the diff.
4. Must-fix findings go back to the implementer, and a re-review ends each round: rounds 1-3 resume it (SendMessage), rounds 4-5 go to a fresh implementer on a stronger model. Still failing after round 5 means blocked.
5. Once a review is clean, open the PR: yourself for a small ticket, the implementer for a stack or a large one.

Dispatch fields: ticket and cache path, branch, base or stack position, reserved migration numbers, and the report path: absolute, outside the repo checkout, named `impl-<n>.md` (Write refuses names starting report, summary, or findings); copy it to the user's path.

## Steps
1. Read the ticket (the cached copy your prompt names, else `gh issue view <n> --json title,body,comments`) and any parent.
2. Branch before the first edit: your prompt's branch and base, else `<slug>-<n>` from the default branch.
3. Measure an open sizing question with read-only queries; keep the numbers for the PR.
4. Red first: one test per acceptance criterion, at the seam the ticket names, through external behavior. Every test goes red on its own assertion: stub a missing module with an empty body, and fix any test that passes against it. Run the tests as their own command, read the failures, and quote one line per test in the report's Red Evidence table; write the passing code in a later command.
5. Commit and push the branch. The report stays out of the commit.

## Checkpoint
On a usage warning or checkpoint message, checkpoint per wills-skills:usage-pacing.

## Report and reply
Fill in [report-template.md](report-template.md) at your prompt's report path.

The whole reply, the implementer's and the orchestrator's, is five lines at most, with no blank lines. Line 1: status and a one-line test summary. Line 2: branch and head SHA, or the PR URL. Line 3: the report path. Lines 4-5: blockers or open must-fix findings, one line each; with none, stop at line 3. Consider findings go in the PR's Notes; the rest stays in the report.

## Opening the PR
When told to: title = the issue title; body = [pr-template.md](pr-template.md); base = the default branch, or the branch below in a stack (`gh stack submit`, via gh-stack).
