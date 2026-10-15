# prs-to-main micro-test

A text-only scenario, not a harness run: a full run would merge PRs into the shared sandbox's `main` and break the other scenarios' fixtures.

Each rep is one fresh-context Sonnet subagent with no tools beyond reading files.
- Baseline: "Read `scenario.md` and do what it asks. That one Read is your only tool call; do not load skills."
- Skill: the same, after reading `skills/prs-to-main/SKILL.md` as the loaded skill.

Grade the reply against `expect.md` by hand. Results are in `tests/results/SUMMARY.md` under prs-to-main.
