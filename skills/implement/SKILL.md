---
name: implement
description: Use when implementing a GitHub issue or ticket, when asked to build one piece of tracked work, or when dispatched as an implementer.
---

# Implement

**REQUIRED SUB-SKILLS:** superpowers:test-driven-development and superpowers:verification-before-completion.

## Where it runs
A prompt that opens "You are the implementer", or bounded work with no ticket: implement here.

Asked in the main session for a ticket (an issue number or link), dispatch and review however small or urgent; the main session does not implement it:
1. Dispatch an implementer: agent type `wills-skills:implementer`, or general-purpose when that type is unavailable, with `isolation: worktree` where available and `model: sonnet` unless the user names another. Open its prompt with "You are the implementer: load wills-skills:implement and implement here," then the dispatch fields.
2. When it returns, read the report file.
3. Load wills-skills:review and run it on the branch before any PR; reading the diff yourself is not the review. Send each must-fix back to the implementer.
4. Open the PR yourself when the ticket is small and the review found no must-fix; have the implementer open it for a stack or a large ticket.

Dispatch fields: ticket number and cache path · branch · base or stack position · reserved numbers (migrations) · absolute report path outside the repo checkout (a worktree cannot write there); copy it to the user's path.

## Steps
1. Read the ticket (the cached copy your prompt names, else `gh issue view <n> --json title,body,comments`) and its parent, if any.
2. Branch before the first edit: your prompt's branch and base, else `<slug>-<n>` from the default branch.
3. Measure an open sizing question with read-only queries; keep the numbers for the PR.
4. Red first: one test per acceptance criterion, at the seam the ticket names, through external behavior (a route, a rendered component, CLI output, a sent message). Every test goes red on its own assertion: stub a missing module with an empty body (returns undefined), and fix any test that passes against it. Run the tests as their own command, read the failure, and copy one line per test into the report's Red Evidence table. Write the code that passes them in a later command.
5. Commit and push the branch. The report stays out of the commit.

## Checkpoint
On a usage warning or a checkpoint message, follow wills-skills:usage-pacing's checkpoint.

## Report and reply
Fill in [report-template.md](report-template.md) at your prompt's report path.

The whole reply, the implementer's and the orchestrator's to the user, is at most five lines, with no blank lines. Line 1: status and a one-line test summary. Line 2: branch and head SHA, or the PR URL. Line 3: the report path. Lines 4-5: blockers or open must-fix findings, one line each; with none, stop at line 3. Consider findings go in the PR's Notes; everything else stays in the report.

## Opening the PR
Title = the issue title; body = [pr-template.md](pr-template.md); base = the default branch, or the branch below in the stack (`gh stack submit`, via the gh-stack skill). Drop "Part of #<parent>." when there is no parent. The repo's attribution footer ends the body.
