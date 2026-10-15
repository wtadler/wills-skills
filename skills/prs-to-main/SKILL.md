---
name: prs-to-main
description: Use when several open PRs need to reach the default branch, especially with a staging check, including "get these PRs onto staging", "ship the open PRs", "chunk the PRs", or after tickets-to-prs finishes a run.
---

# PRs to Main

Open PRs reach the default branch in a few large chunks, each checked by the user on staging before it merges. The user is needed at four stops; the rest is yours.

**REQUIRED SUB-SKILLS:** wills-skills:review and gh-stack.

## The staging recipe
From the repo's agent docs or runbook: deploying a ref to staging, taking and restoring a database restore point, every test suite, and which deployments staging shares with production. Ask once for any missing piece and add it to the agent docs in the next PR. A deploy shared with production is a production deploy.

## Plan
1. Sweep live state: open PRs with CI, mergeability, review state, and stacks (`gh stack`); what merged since the last sweep; the build staging and production serve.
2. Conflict matrix: `git merge-tree --write-tree origin/<a> origin/<b>` for every pair of stack tops and lone PRs. A conflict only in append-only shared lists, test pins, or snapshots is not real: the chunk build keeps both sides.
3. Chunks, few and large: whole stacks and lone PRs with no real conflict among them. Chunks needing a deploy shared with production, and cross-cutting UI work, come after the rest. PRs with nothing to see on staging (tests, CI, docs) join no chunk and merge on green CI after Stop 1's go-ahead.
4. Any PR nobody has reviewed is listed for wills-skills:review, which runs after the go-ahead and before its chunk is built.
5. **Stop 1, the plan:** every PR placed: chunks in order with their migrations and deploy surfaces, the no-staging list, and pending reviews. The turn ends on it.

## Per chunk, after the go-ahead
1. Bring each PR up to date with the default branch by merge (no force-push); CI green.
2. Build `staging/chunk-<n>`: the default branch plus the chunk's branches. Run every suite on that tree, one after another. Push the branch, never the default branch.
3. **Stop 2, the before checklist:** per user-visible PR, a staging link found with read-only queries, what it does today, what it should do after, and what to undo after testing. Staging that sends real email is tested with the user's own or test accounts, never skipped. The turn ends on it, since a deploy writes to staging.
4. On the user's OK: record the restore point, deploy, confirm staging serves the new build and its migrations, and smoke-check it yourself. A deploy shared with production is handed to the user instead, and you check it after they run it.
5. **Stop 3, the after checklist:** the same items, now live. Feedback becomes reviewed fixes on the PR branches and a rebuilt chunk.
6. If something breaks, redeploy the previous build. A database restore needs the user's OK.
7. **Stop 4, sign-off:** merge a stack by its top PR (`gh stack merge`) and the rest by the repo's merge method. Before each merge, merge the default branch into that PR (shared lists keep both sides) and wait for green CI. Confirm the default branch matches the staged tree for the chunk's files. Hand the user the production deploy command; it is theirs. Then the next chunk.

## Common mistakes
| Mistake | Instead |
|---|---|
| Staging one ad hoc batch and holding the rest | Place every PR in Stop 1's plan |
| Deploying before the before checklist | Stop 2 first |
| Treating appends to a shared list as conflicts | Keep both sides in the chunk build |
| Skipping staging because it sends real email | Test with the user's own or test accounts |
| Checklists that say only what should happen | Link, before, after, and undo for each PR |
| Deploying a service staging shares with production | It is a production deploy: the user's |
