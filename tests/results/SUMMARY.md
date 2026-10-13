# Pressure-Test Results

One row per run. Verdicts are read by hand against the scenario's `expect.md`; quote rationalizations verbatim.

## Harness Notes

- Blocked-by links: the native REST endpoint (`POST /repos/{owner}/{repo}/issues/{issue_number}/dependencies/blocked_by`) worked. Sandbox issues #5 and #6 are blocked by #4, and #7 is blocked by #5 and #6. The "Blocked by" text in each issue body matches.
- Permission mode: `run.sh` uses `--permission-mode bypassPermissions` as specified. The fallback (`acceptEdits` plus `--allowedTools`) has not been needed.
- Arms: both arms load the user's installed plugins (superpowers, mattpocock-skills, and others). The skill arm adds wills-skills through `--plugin-dir`, so baseline means "without wills-skills," not "without any plugins."

| Scenario | Arm | Rep | Verdict | Evidence |
|---|---|---|---|---|
