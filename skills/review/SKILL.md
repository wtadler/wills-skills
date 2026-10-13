---
name: review
description: Use when reviewing a branch, pull request, or diff against its issue or spec, before merging, or when dispatched as a reviewer.
---

# Review

One reviewer runs both axes in turn. **REQUIRED SUB-SKILL:** mattpocock-skills:code-review supplies the axes, the standards sources, and the smell baseline.

Read-only: the reviewer writes only its report; edits, commits, pushes, and GitHub comments belong to the implementer and orchestrator.

## Where it runs
You are the reviewer: review here. Asked for a review in the main session:
1. Build the package.
2. Dispatch a reviewer for every diff, whatever its size, because the reviewer has not seen the implementation. Use agent type `wills-skills:reviewer`, or general-purpose when that type is unavailable. Tell it to load wills-skills:review, and give it the package path, the spec, the worktree path, and, for a re-review, the previous must-fix list, plus a report path: absolute, outside the repo checkout, named `review-<n>.md` (a subagent's Write refuses names starting report, summary, or findings). The reviewer reads only from the worktree. Set `model` from the table below.
3. When it returns, read the report file; the reviewer's reply is a pointer, and its count and lines are partial. Inside the loop of wills-skills:implement or wills-skills:ticket-factory, must-fix findings go back to the implementer; otherwise relay every must-fix to the user.

## Package
`bash ${CLAUDE_SKILL_DIR}/scripts/diff-package.sh <worktree> <base> <out-file>` writes the log, stat, and `diff -U10`. A re-review builds it against the head the previous review saw, so it covers only the fix commits; the reviewer also gives each item of the previous must-fix list a verdict, addressed or not.

## Model
| The diff touches | Model |
|---|---|
| auth or security, migrations on existing data, concurrency, data integrity | opus |
| only a small fix commit after a review | haiku |
| anything else | sonnet |

## Report
Sections: `## Standards`, `## Spec`, `## Probes`. Tag each finding **must-fix** (a bug, a missed criterion, a broken documented standard) or **consider** (a judgment call), with file:line and the fix.

For each acceptance criterion, name the test at its seam that fails without the change, or say none.

Answer each probe in writing:
- Concurrency: what happens when two calls run this at once, across every `await` or transaction gap, and which test exercises that?
- Migrations: does it apply to existing data, foreign keys, indexes, and a re-run?
- Auth: who can call this, and can a lower role reach it?
- Data loss: what does it delete or overwrite, and can that be undone?

## Reply
The whole reply is at most five lines. Line 1: the report's must-fix count and its path. Lines 2–4: the worst three must-fix findings, one line each. Line 5: the decision for the orchestrator. The rest stays in the report.
