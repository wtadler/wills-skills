---
name: usage-pacing
description: Use when the user asks about Claude usage or rate limits (the 5-hour or weekly window, resets, how much is left), before launching subagents in a long or unattended run, or when a usage warning appears.
---

# Usage Pacing

## Reading usage
Read usage from the host's session usage tool when one is offered: it reports live plan limits. Otherwise `node ${CLAUDE_SKILL_DIR}/scripts/check_usage.js` prints the 5-hour and weekly windows from Claude Desktop's on-disk cache (`--compact` for one line, `--json` for scripts). macOS with Claude Desktop only; elsewhere it reports that no cache exists.

Every cache reading carries an `as of` stamp. A reading older than 30 minutes, or past its `resets_at`, is **stale**: report it as unknown, never as headroom. Opening or focusing Claude Desktop refreshes it. Report reset times in the user's local time zone.

## Pacing a run
- At most three agents at once.
- Burn rate comes from two readings in this run (Δ% ÷ Δhours). With no fresh pair, assume the high observed rate: about 70%/h with five or more agents including Opus, about 25%/h with two Sonnet agents.
- While agents run, re-read usage at each agent return, and while idle schedule a wakeup so the gap never exceeds 15 minutes.
- At 75% or above: no new launches.
- At 80%: send every running agent a checkpoint message: commit with a `wip:` prefix, push, write the handoff (done, left, exact next step) into its report, and stop. Agents see no warning when the reading is stale, so the orchestrator sends this.
- After the reset: auto-continue resumes the main session. Schedule one CronCreate a few minutes after `resets_at` whose prompt reads usage first, then resumes each checkpointed agent with SendMessage, in a stated order. Timers live only while the app is open.

## The hook
A PostToolUse hook prints a quiet usage line at most every 20 minutes, and a checkpoint warning on nearly every tool call at 80% or above. A stale reading prints as unknown.

Maintenance and troubleshooting: [reference.md](reference.md).
