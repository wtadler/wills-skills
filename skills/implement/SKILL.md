---
name: implement
description: Use when implementing a GitHub issue or ticket, when asked to build one piece of tracked work, or when dispatched as an implementer.
---

# Implement

One ticket, start to pushed branch. **REQUIRED SUB-SKILLS:** superpowers:test-driven-development and superpowers:verification-before-completion.

## Where it runs
A prompt that opens "You are the implementer" is the dispatched case: implement here.

Asked in the main session for a ticket (an issue number or link), dispatch and review however small or urgent it is; the main session does not implement it:
1. Dispatch an implementer: agent type `wills-skills:implementer`, or general-purpose when that type is unavailable, with `isolation: worktree` where available and `model: sonnet` unless the user names another. Open its prompt with "You are the implementer: load wills-skills:implement and implement here," then the dispatch fields.
2. When it returns, read the report file. Its reply is a pointer.
3. Load wills-skills:review and run it on the branch. Send each must-fix back to the implementer, then have it open the PR.
4. Reply to the user as under Reply.

Dispatch fields: ticket number and cache path · branch · base or stack position · reserved numbers (migrations) · absolute report path outside the repo checkout, which a worktree cannot write into (copy it to the path the user named).

## Steps
1. Branch before the first edit: the branch and base your prompt names, else `<slug>-<n>` from the default branch.
2. Measure an open sizing question with read-only queries and keep the numbers for the PR.
3. Red first: one test per acceptance criterion, at the seam the ticket names, through external behavior (a route, a rendered component, CLI output, a sent message). Every test goes red on its own assertion: when the module does not exist yet, add a stub with an empty body (it returns undefined), and fix any test that passes against it. Run the tests as their own command, read the failure, and copy one line per test into the report's Red Evidence table. Write the code that passes them in a later command.
4. Commit and push the branch. The report stays out of the commit.

## Checkpoint
On a usage warning at 80%, or a checkpoint message: commit `wip: <what>`, push, and write the handoff (done, left, exact next step) into the report.

## Report and reply
Fill in [report-template.md](report-template.md) at the report path your prompt gives.

The whole reply, the implementer's and the orchestrator's to the user, is at most five lines, with no blank lines. Line 1: status and a one-line test summary. Line 2: branch and head SHA, or the PR URL. Line 3: the report path. Lines 4-5: blockers or open must-fix findings, one line each; with none, stop at line 3. Findings tagged consider go in the PR's Notes, and everything else stays in the report.

## Opening the PR
When told to: title = the issue title; body = [pr-template.md](pr-template.md); base = the default branch, or the branch below in the stack (`gh stack submit`, via the gh-stack skill). Drop "Part of #<parent>." when there is no parent. The repo's attribution footer ends the body.
