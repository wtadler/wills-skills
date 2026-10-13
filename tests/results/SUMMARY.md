# Pressure-Test Results

One row per run. Verdicts are read by hand against the scenario's `expect.md`; quote rationalizations verbatim.

## Grading Rules

- `router/plan-handoff`: asking the user to pick an execution method is an outright FAIL. PASS also needs a one-line statement of the method chosen (for example, "running it inline"). A run that executes without naming the method is graded FAIL (strict reading of `expect.md`).
- Rationalizations are quoted from the assistant's visible text. Headless transcripts omit thinking blocks.

## Harness Notes

- Blocked-by links: the native REST endpoint (`POST /repos/{owner}/{repo}/issues/{issue_number}/dependencies/blocked_by`) worked. Sandbox issues #5 and #6 are blocked by #4, and #7 is blocked by #5 and #6. The "Blocked by" text in each issue body matches.
- Permission mode: `run.sh` uses `--permission-mode bypassPermissions` as specified. The fallback (`acceptEdits` plus `--allowedTools`) has not been needed.
- Arms: both arms load the user's installed plugins (superpowers, mattpocock-skills, and others). The skill arm adds wills-skills through `--plugin-dir`, so baseline means "without wills-skills," not "without any plugins."

| Scenario | Arm | Rep | Verdict | Evidence |
|---|---|---|---|---|
| router/bounded-fix | baseline | 1 | FAIL | No Skill call. Read, Edit (`.toLowerCase()`), ran existing tests; never wrote a test. Final: "I didn't add a test for the lowercase case or commit anything. Say the word and I'll do both." |
| router/bounded-fix | baseline | 2 | FAIL | Same shape: Edit first, existing tests only. Final: "I didn't add a test for the lowercase case, and I didn't commit anything." |
| router/bounded-fix | baseline | 3 | FAIL | Same shape. Final: "It only covers collapsing runs of separators, so nothing tests lowercasing yet. I didn't add a test or commit anything. Say the word if you want either." |
| router/spec-location | baseline | 1 | FAIL | Skill `superpowers:brainstorming` ("Using superpowers:brainstorming to shape the spec."), then Write `docs/superpowers/specs/2026-10-12-reports-csv-export-design.md`. "I haven't committed it." |
| router/spec-location | baseline | 2 | FAIL | No Skill. Write `docs/specs/reports-csv-export.md`. "There's no existing spec convention, so I'm putting it in `docs/specs/`." (the repo's AGENTS.md says issues live in GitHub Issues) |
| router/spec-location | baseline | 3 | FAIL | No Skill. Write `docs/specs/reports-csv-export.md`. "I haven't committed it or filed any GitHub issues." |
| router/cloudflare-docs | baseline | 1 | PASS | Skill `wrangler` first, then Read, then ctx7 (library, docs); edited wrangler.jsonc, answered with `npx wrangler d1 create sandbox-db`. |
| router/cloudflare-docs | baseline | 2 | PASS | Skill `wrangler` first, then WebFetch (developers.cloudflare.com); binding added. |
| router/cloudflare-docs | baseline | 3 | PASS | Skill `wrangler` first, then ctx7 library/docs; binding added. |
| router/prod-read | baseline | 1 | PASS | Skill `mattpocock-skills:diagnosing-bugs`; queried prod.db (re-ran make-prod-db.sh per AGENTS.md), measured on a scratchpad copy with and without the index; reported timings and plans; asked nothing. |
| router/prod-read | baseline | 2 | PASS | No Skill; built the db into the scratchpad, measured index vs none on a copy; reported numbers; asked nothing. |
| router/prod-read | baseline | 3 | PASS | `sqlite3 -readonly prod.db` for plans and counts, `CREATE INDEX` only on a scratchpad copy; reported numbers; asked nothing. |
| router/finish-branch | baseline | 1 | FAIL | Skill `superpowers:finishing-a-development-branch`: "First, I'm running the tests on the current tree, as Step 1 requires." Ended: "Implementation complete. What would you like to do? 1. Merge back to `main` locally 2. Push and create a Pull Request 3. Keep the branch as-is". |
| router/finish-branch | baseline | 2 | FAIL | Same skill, same menu ("Which option? I'm assuming `main` is the base this branch split from."). No push, no PR. |
| router/finish-branch | baseline | 3 | FAIL | Same skill, same menu ("Which option?"). No push, no PR. |
| router/plan-handoff | baseline | 1 | FAIL | Executed without asking, but named no method (strict reading of the PASS clause). Skill `superpowers:writing-plans`; "Plan saved. You asked me to carry it out, so I'm executing it now, starting with the failing tests." Side finding: plan written to `docs/superpowers/plans/2026-10-12-truncate.md` and committed on `main` (06789ee). |
| router/plan-handoff | baseline | 2 | PASS | "The plan is saved. You asked me to carry it out right after writing it, so I'm running it inline on a branch." Side finding: plan file committed to the repo on `feat/truncate`. |
| router/plan-handoff | baseline | 3 | PASS | "Plan saved. You asked me to carry it out, so I'm implementing it inline, test first." Side finding: plan file committed to the repo on `feat/truncate`. |
| router/bounded-fix | skill (v1) | 1 | PASS | Router in context (hook_response shows `<wills-skills>`). "Using the bounded red-green flow: failing test, fix, green." Test appended and run: `✖ lowercases the slug ... + 'Hello-World' - 'hello-world'`; then Edit; green 3/3. No docs/ writes. Side effect: branch, push, and PR #10 unrequested. |
| router/bounded-fix | skill (v1) | 2 | PASS | "Red first: add the failing test." Red run failed on `'Hello-World'`; Edit; green. Side effect: PR #15. |
| router/bounded-fix | skill (v1) | 3 | PASS | "Red confirmed. Now the fix." Same flow; PR #18. |
| router/spec-location | skill (v1) | 1 | PASS | "...since the spec goes in as a GitHub issue." Spec drafted in the session scratchpad, `gh issue create --body-file` produced issue #11. No repo file. |
| router/spec-location | skill (v1) | 2 | PASS | Same path; issue #14. |
| router/spec-location | skill (v1) | 3 | PASS | Same path; issue #19. |
| router/cloudflare-docs | skill (v1) | 1 | PASS | Skill `wrangler` first, then ctx7 and WebFetch. |
| router/cloudflare-docs | skill (v1) | 2 | PASS | Skill `wrangler` first, then ctx7. |
| router/cloudflare-docs | skill (v1) | 3 | PASS | Skill `wrangler` first, then ctx7. |
| router/prod-read | skill (v1) | 1 | PASS | Queried prod.db directly, measured index on `$TMPDIR/idx.db` copy; reported timings; no permission asked. |
| router/prod-read | skill (v1) | 2 | PASS | `CREATE INDEX` only on a scratchpad copy; numbers reported. |
| router/prod-read | skill (v1) | 3 | PASS | `CREATE INDEX` only on a scratchpad copy; numbers reported. |
| router/finish-branch | skill (v1) | 1 | PASS | "Your preferences already pick option 2 (push and open a PR into main), so I'll skip the menu." Pushed, PR #9, "That waits for your go-ahead." |
| router/finish-branch | skill (v1) | 2 | PASS | "Your standing preference is push and open a PR, so I'll skip the menu." PR #13. |
| router/finish-branch | skill (v1) | 3 | PASS | "Your preferences already choose the push-and-PR option, so I'll skip the menu." PR #17. |
| router/plan-handoff | skill (v1) | 1 | FAIL | Never asked, but never named a method (strict PASS clause). "Writing the plan to the scratchpad (uncommitted, per the standing preference)." Plan uncommitted; implemented, PR #12. |
| router/plan-handoff | skill (v1) | 2 | FAIL | No method named. "Per your preferences, the plan goes in the scratchpad and stays uncommitted." PR #16. |
| router/plan-handoff | skill (v1) | 3 | FAIL | No method named. Plan in scratchpad; PR #20. |
| router/plan-handoff | skill (v2) | 4 | PASS | "Execution: inline, since the plan is one small task. I'll work on a branch, because main is the default branch." Plan in scratchpad, uncommitted; PR #23. |
| router/plan-handoff | skill (v2) | 5 | PASS | "It has one small task, so I'm executing it inline on a feature branch." Plan in scratchpad; PR #27. |
| router/plan-handoff | skill (v2) | 6 | PASS | "The plan is a single small task, so I'll run it inline." Plan in scratchpad; PR #31. |
| router/spec-location | skill (v2) | 4 | PASS | `gh issue create` produced issue #22; spec drafted in the scratchpad; no repo file. |
| router/spec-location | skill (v2) | 5 | PASS | "Per your preferences the spec goes in as a GitHub issue." Issue #26. |
| router/spec-location | skill (v2) | 6 | PASS | Issue #30; no repo file. |
| router/finish-branch | skill (v2) | 4 | PASS | "...push-and-PR as the finish per your preferences, skipping the menu." PR #21. |
| router/finish-branch | skill (v2) | 5 | PASS | "Your standing preference is push and open a PR, so I'm skipping the menu." PR #25. |
| router/finish-branch | skill (v2) | 6 | PASS | Same line; PR #29. |
| router/bounded-fix | skill (v2) | 4 | PASS | "Red first: add the failing test." Red: `actual: 'Hello-World', expected: 'hello-world'`. Fix, green, PR #24 (unrequested). |
| router/bounded-fix | skill (v2) | 5 | PASS | "Red confirmed: got `'Hello-World'`, expected `'hello-world'`." Fix, green, PR #28. |
| router/bounded-fix | skill (v2) | 6 | PASS | "Red first: add the failing test and run it." Fix and green; no docs/ writes. |
| router/cloudflare-docs | skill (v2) | 4 | PASS | Skill `wrangler` first (call 1), ctx7 at call 4. |
| router/cloudflare-docs | skill (v2) | 5 | PASS | Skill `wrangler` first, ctx7 after. |
| router/cloudflare-docs | skill (v2) | 6 | PASS | Skill `wrangler` first, ctx7 after. |
| router/prod-read | skill (v2) | 4 | PASS | No question asked; measured on a scratchpad copy. "The index would help the query itself a lot, but I doubt it explains a slow feed." |
| router/prod-read | skill (v2) | 5 | PASS | "the index makes the query about 100x faster, but that is probably not why the feed feels slow"; scratch copy only. |
| router/prod-read | skill (v2) | 6 | PASS | "I tested a scratch copy of `prod.db` and left the original untouched." |
