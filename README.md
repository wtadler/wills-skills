# wills-skills

Personal Claude Code conventions layered on [superpowers](https://github.com/obra/superpowers) and [mattpocock/skills](https://github.com/mattpocock/skills). Both must be installed; wills-skills loads their skills by name.

## Install

In Claude Code:

```
/plugin marketplace add wtadler/wills-skills
/plugin install wills-skills@wills-skills
```

The repo is private, so git needs a stored credential: run `gh auth setup-git` once per machine. For auto-update, add to `~/.claude/settings.json`:

```json
"extraKnownMarketplaces": {
  "wills-skills": { "source": { "source": "github", "repo": "wtadler/wills-skills" }, "autoUpdate": true }
}
```

Stacked PRs need `gh` 2.90.0 or later, `gh extension install github/gh-stack`, and `gh skill install github/gh-stack`.

`grill-to-tickets` creates tickets with `gh issue create --parent` and `--blocked-by`; both flags were verified on `gh` 2.102.

## What's Inside

| Component | Purpose |
|---|---|
| `using-wills-skills` | Standing preferences and skill index, injected at session start |
| `grill-to-tickets` | Idea → grilled → sized → spec issue → ready-for-agent tickets |
| `implement` | One ticket to a pushed branch, evidenced red-green |
| `review` | One reviewer, two axes, adversarial probes |
| `ticket-factory` | Labeled backlog → stacked, reviewed PRs, paced to the usage window |
| `usage-pacing` | Usage reader, hook, and pacing rules (macOS + Claude Desktop) |
| `implementer`, `reviewer` agents | Sonnet by default; callers raise the model by risk |

## Staying current

`upstream.json` lists each upstream repo wills-skills depends on, the skill paths it uses, and the commit last checked. `bash scripts/drift-check.sh` diffs those paths against each upstream's default branch and prints the changed files, or nothing when none changed. An upstream it cannot check prints `## <url> ERROR: ...` and the script exits non-zero. Resolving drift bumps `lastChecked` in a PR.

A non-zero exit or any `ERROR` line is a failed check to report, never "no drift". The weekly routine runs from the default branch with this prompt:

```
Run `bash scripts/drift-check.sh` in this repo and read its exit status and output.
- Exit 0 with empty output: no drift. Stop.
- Any other result is a finding. A non-zero exit or any line containing ERROR is a failed check: open or update an issue titled "Drift check failed" with the output, and never report it as no drift.
- Otherwise the output lists changed files per upstream: open or update one issue titled "Upstream drift" that lists each changed path and the wills-skills file that depends on it.
Do not edit upstream.json; resolving the issue bumps lastChecked in a PR.
```

## Tests

- Unit: `bash tests/run-unit.sh`
- Pressure scenarios: `bash tests/harness/run.sh tests/scenarios/<group>/<name> <baseline|skill> <rep>`; verdicts in `tests/results/SUMMARY.md`.

## License

MIT. Parts adapted from mattpocock/skills; see `NOTICE`.
