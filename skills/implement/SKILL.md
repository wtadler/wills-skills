---
name: implement
description: Use when implementing a GitHub issue or ticket, when asked to build one piece of tracked work, or when dispatched as an implementer.
---

# Implement

**REQUIRED SUB-SKILLS:** superpowers:test-driven-development and superpowers:verification-before-completion.

## Where it runs
A prompt that opens "You are the implementer", or bounded work with no ticket: implement here.

Asked in the main session for a ticket (an issue number or link), dispatch and review however small or urgent:
1. Dispatch an implementer: agent type `wills-skills:implementer`, or general-purpose when that type is unavailable, with `isolation: worktree` where available and `model: sonnet` unless the user or the run ledger names another. Open its prompt "You are the implementer: load wills-skills:implement," then the dispatch fields.
2. When it returns, read its report file in a call of its own: the reply is a pointer.
3. Load wills-skills:review and run it on the branch. The review is the reviewer's report file, read in a call of its own before any PR call, not your own read of the diff.
4. Each must-fix goes back to the implementer, with a re-review after every round: rounds 1-3 resume it (SendMessage), rounds 4-5 go to a fresh implementer on a stronger model with the branch and findings. Failing after round 5 means blocked.
5. After a clean review or re-review, open the PR: yourself for a small ticket, the implementer for a stack or a large one.

Dispatch fields: ticket number and cache path, branch, base or stack position, reserved numbers (migrations), and the report path: absolute, outside the repo checkout, named `impl-<n>.md` (a subagent's Write refuses names starting report, summary, or findings); copy it to the user's path.

## Steps
1. Read the ticket (the cached copy your prompt names, else `gh issue view <n> --json title,body,comments`) and its parent, if any.
2. Branch before the first edit: your prompt's branch and base, else `<slug>-<n>` from the default branch.
3. Measure an open sizing question with read-only queries; keep the numbers for the PR.
4. Red first: one test per acceptance criterion, at the seam the ticket names, through external behavior. Every test goes red on its own assertion: stub a missing module with an empty body, and fix any test that passes against it. Run the tests as their own command, read the failures, and quote one line per test in the report's Red Evidence table; write the passing code in a later command.
5. Commit and push the branch. The report stays out of the commit.

## Checkpoint
On a usage warning or checkpoint message, follow wills-skills:usage-pacing's checkpoint.

## Report and reply
Fill in [report-template.md](report-template.md) at your prompt's report path.

The whole reply, the implementer's and the orchestrator's, is five lines at most, with no blank lines. Line 1: status and a one-line test summary. Line 2: branch and head SHA, or the PR URL. Line 3: the report path. Lines 4-5: blockers or open must-fix findings.

## Opening the PR
When told to: title = the issue title; body = [pr-template.md](pr-template.md); base = the default branch, or the branch below in the stack (`gh stack submit`, via the gh-stack skill).
