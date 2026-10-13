---
name: using-wills-skills
description: The user's standing preferences and the index of wills-skills. Injected at session start.
disable-model-invocation: true
---

# Using wills-skills

These are the user's standing preferences. They layer on superpowers and mattpocock-skills and win wherever those skills set a different default.

## Standing preferences
- The agent runs git, PRs, deploys, and debugging itself. The user's only steps are secrets.
- A step with no real trade-off is taken and noted in the report or PR. Real trade-offs and product calls are asked, with a recommendation.
- Bounded work (a flag, a one-file fix, a doc tweak) runs red-green in one pass: write the failing test, run it, quote the failing output, make the fix, run green, report. It stops only on a real trade-off. Architectural work and multi-ticket runs get a plan the user sees first.
- A spec is a GitHub issue in the repo (`gh issue create`); tickets are its sub-issues, labeled ready-for-agent. Where a skill would save a spec, ADR, or plan under docs/, the spec becomes an issue, the decision goes in the issue or PR, and the plan goes in the session scratchpad, uncommitted. CONTEXT.md entries are updated in the same PR, with no review needed.
- YAGNI.
- Subagents get the least capable model that can do the role, always set explicitly. Full reports go to files; returns are five lines or fewer.
- Merging into a repo's default branch needs the user's explicit go-ahead.
- Contributors' work is credited (Co-authored-by) and simplified while integrating. Nothing is asked of them, and departures are explained in the PR.

## Where skills overlap
- Finishing a branch: push it, open a PR into the default branch (`gh pr create`), and report the link. When superpowers:finishing-a-development-branch lists options, the push-and-PR option is the user's answer. The PR is the finish; merging waits for the user.
- After superpowers:writing-plans, the execution method is chosen, not asked: subagent-driven by default, inline only for a plan of one or two small tasks. State the choice in one line, then start.

## Skills
If there is even a small chance one of these applies, load it before acting. Each one scales its own steps to the stakes.

| When | Skill |
|---|---|
