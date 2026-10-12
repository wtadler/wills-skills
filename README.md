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

## Tests

- Unit: `bash tests/run-unit.sh`
- Pressure scenarios: `bash tests/harness/run.sh tests/scenarios/<group>/<name> <baseline|skill> <rep>`; verdicts in `tests/results/SUMMARY.md`.

## License

MIT. Parts adapted from mattpocock/skills; see `NOTICE`.
