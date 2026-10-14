# wills-skills

A Claude Code plugin that turns an idea into reviewed pull requests with as little hand-holding as possible. You describe a feature; Claude grills you on the design, measures its real impact, files a spec issue and ready-for-agent tickets on GitHub, then works through the tickets with an implementer subagent and a separate reviewer subagent per ticket, opening stacked PRs and pacing itself to your Claude usage window so an unattended run checkpoints instead of hitting the limit mid-edit.

It is tailored to one setup: Claude Code in Claude Desktop on a Mac, on a Claude Pro or Max subscription, where usage is metered in a five-hour session window plus a weekly limit. The pacing reads those windows from Claude Desktop's local cache when the host offers no usage tool. Most of the rest works anywhere Claude Code and `gh` run, but long unattended runs assume that setup.

It is not a standalone skill set. It sits on top of [superpowers](https://github.com/obra/superpowers) and [mattpocock/skills](https://github.com/mattpocock/skills), loads their skills by name, and settles the places where the two disagree. Both must be installed.

## The Idea

Superpowers and Matt Pocock's skills are each good at a different half of the job:

- **Superpowers is about execution discipline**: test-driven development, verification before claiming done, plans, worktrees, subagent-driven development, and finishing a branch.
- **Matt Pocock's skills are about thinking before building**: relentless grilling of a plan, a shared domain vocabulary, research against primary sources, specs and tickets, and a two-axis code review (does it follow the repo's standards, and does it do what the spec asked).

Installed together, they overlap and sometimes pull in opposite directions: two TDD skills, two code-review skills, specs saved under `docs/` versus tickets in an issue tracker, and a finishing step that stops to ask what to do with the branch. wills-skills does three things:

1. **Picks a winner where they overlap**, through a short router injected at session start (`using-wills-skills`).
2. **Sets standing preferences** so Claude asks fewer questions: it runs git and PRs itself, takes steps with no real trade-off and notes them, and asks only about real trade-offs, with a recommendation.
3. **Adds the pipeline glue** neither upstream has: idea → spec issue → tickets → implement → independent review → stacked PRs, with usage pacing for long runs.

## What Comes From Where

| wills-skills piece | From superpowers | From mattpocock/skills | Added here |
|---|---|---|---|
| `grill-to-tickets` | | `grilling`, `domain-modeling`, `research`; adapts `to-spec` and `to-tickets` | One question per round with a recommended answer, impact measured on real data, a single review stop, and publishing as a GitHub spec issue with native sub-issues and blocked-by links |
| `implement` | `test-driven-development`, `verification-before-completion` | | Dispatch to an implementer subagent in a worktree, red evidence quoted per acceptance criterion, review before any PR, and a bounded fix loop that escalates the model |
| `review` | Replaces `requesting-code-review` | `code-review` supplies the two axes and standards sources | One fresh-context reviewer for every diff, adversarial probes, must-fix and consider tags, and a reviewer model chosen by risk |
| `ticket-factory` | The implementer-plus-reviewer loop of `subagent-driven-development` | Consumes the ready-for-agent tickets `grill-to-tickets` files | Backlog planning into stacks with [gh-stack](https://github.com/github/gh-stack), migration-number reservation, waves, worktree cleanup, and a run ledger |
| `usage-pacing` | | | Reads the 5-hour and weekly usage windows, caps parallel agents, checkpoints agents at 80%, and resumes them after the reset |
| `using-wills-skills` (router) | Overrides `finishing-a-development-branch` (always push and open a PR), `writing-plans` (choose the execution method instead of asking), and `brainstorming` (spec goes to an issue, not `docs/`) | Overrides `code-review` and `tdd` in favor of the single paths above | Standing preferences and the skill index |
| `implementer`, `reviewer` agents | Preload `test-driven-development` and `verification-before-completion` | Reviewer preloads `code-review` | Sonnet by default; callers raise the model by risk |

## Opinionated Defaults

These are one person's preferences, written as instructions to Claude. Read `skills/using-wills-skills/SKILL.md` before installing; the ones most likely to surprise you:

- Claude commits, pushes, and opens PRs without asking. It never merges into the default branch without your go-ahead.
- Read-only queries against any environment, production included, run without asking. Writes and remote migrations wait for your OK.
- Specs are GitHub issues and tickets are their sub-issues. Plans live in the session scratchpad, uncommitted, not under `docs/`.
- Every change in behavior is red-green, with the failing output quoted.

Fork it and edit the router if yours differ.

## Install

In Claude Code:

```
/plugin install superpowers@claude-plugins-official
/plugin install mattpocock-skills@claude-plugins-official
/plugin marketplace add wtadler/wills-skills
/plugin install wills-skills@wills-skills
```

For auto-update, add to `~/.claude/settings.json`:

```json
"extraKnownMarketplaces": {
  "wills-skills": { "source": { "source": "github", "repo": "wtadler/wills-skills" }, "autoUpdate": true }
}
```

Requirements:

- The `gh` CLI, authenticated. `grill-to-tickets` creates tickets with `gh issue create --parent` and `--blocked-by`, verified on `gh` 2.102.
- For stacked PRs: `gh` 2.90.0 or later, `gh extension install github/gh-stack`, and `gh skill install github/gh-stack`.
- `usage-pacing` reads usage from the host's session usage tool when one is offered. Otherwise it falls back to Claude Desktop's on-disk cache, which works on macOS only.

## Staying Current

`upstream.json` lists each upstream repo wills-skills depends on, the skill paths it uses, and the commit last checked. `bash scripts/drift-check.sh` diffs those paths against each upstream's default branch and prints the changed files, or nothing when none changed. An upstream it cannot check prints `## <url> ERROR: ...` and the script exits non-zero. Resolving drift bumps `lastChecked` in a PR.

A non-zero exit or any `ERROR` line is a failed check to report, never "no drift." The weekly routine runs from the default branch with this prompt:

```
Run `bash scripts/drift-check.sh` in this repo and read its exit status and output.
- Exit 0 with empty output: no drift. Stop.
- Any other result is a finding. A non-zero exit or any line containing ERROR is a failed check: open or update an issue titled "Drift check failed" with the output, and never report it as no drift.
- Otherwise the output lists changed files per upstream: open or update one issue titled "Upstream drift" that lists each changed path and the wills-skills file that depends on it.
Do not edit upstream.json; resolving the issue bumps lastChecked in a PR.
```

## Tests

- Unit: `bash tests/run-unit.sh`
- Pressure scenarios: `bash tests/harness/run.sh tests/scenarios/<group>/<name> <baseline|skill> <rep>`; verdicts in `tests/results/SUMMARY.md`. Scenarios create issues and PRs in a sandbox repo; set `WSK_SANDBOX=<owner>/<repo>` to one you own.

## License

MIT. Parts adapted from mattpocock/skills; see `NOTICE`. Built to run alongside superpowers by Jesse Vincent.
