---
name: review
description: Use when reviewing a branch, pull request, or diff against its issue or spec, before merging, or when dispatched as a reviewer.
---

# Review

One reviewer runs both axes in turn. **REQUIRED SUB-SKILL:** mattpocock-skills:code-review supplies the axes, the standards sources, and the smell baseline.

## Where it runs
- Asked for a review in the main session: build the package, then dispatch a reviewer for every diff, whatever its size, because the reviewer has not seen the implementation. Use agent type `wills-skills:reviewer`, or general-purpose when that type is unavailable. Tell it to load wills-skills:review, and set `model` from the table below. Read its report.
- You are the reviewer: review here.

## Package
`bash ${CLAUDE_SKILL_DIR}/scripts/diff-package.sh <worktree> <base> <out-file>` writes the log, stat, and `diff -U10`.

## Model
| The diff touches | Model |
|---|---|
| auth or security, migrations on existing data, concurrency, data integrity | opus |
| anything else | sonnet |

## Report
Sections: `## Standards`, `## Spec`, `## Probes`. Tag each finding **must-fix** (a bug, a missed criterion, a broken documented standard) or **consider** (a judgment call), with file:line and the fix.

Answer each probe in writing:
- Concurrency: what happens when two calls run this at once, across every `await` or transaction gap, and which test exercises that?
- Migrations: does it apply to existing data, foreign keys, indexes, and a re-run?
- Auth: who can call this, and can a lower role reach it?
- Data loss: what does it delete or overwrite, and can that be undone?

## Reply
The whole reply is at most five lines. Line 1: the must-fix count and the report path. Lines 2–4: the worst three must-fix findings, one line each. Line 5: the decision for the orchestrator. The rest stays in the report.
