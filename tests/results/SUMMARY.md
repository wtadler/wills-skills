# Pressure-Test Results

One row per run. Verdicts are read by hand against the scenario's `expect.md`; quote rationalizations verbatim.

## Harness Notes

- Blocked-by links: the native REST endpoint (`POST /repos/{owner}/{repo}/issues/{issue_number}/dependencies/blocked_by`) worked. Sandbox issues #5 and #6 are blocked by #4, and #7 is blocked by #5 and #6. The "Blocked by" text in each issue body matches.
- Permission mode: `run.sh` uses `--permission-mode bypassPermissions` as specified. The fallback (`acceptEdits` plus `--allowedTools`) has not been needed.
- Provisional fixture: `tests/harness/fixtures/sample.jsonl` was written by hand in the stream-json shape because the headless `claude -p` capture failed with an authentication error in the build environment. Replace it with a real capture (Task 0, Step 3) and rerun `bash tests/run-unit.sh`.

| Scenario | Arm | Rep | Verdict | Evidence |
|---|---|---|---|---|
