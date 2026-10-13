---
name: using-wills-skills
description: Router and skill index for wills-skills. Injected at session start.
disable-model-invocation: true
---

# Using wills-skills

The user's standing preferences layer on superpowers and mattpocock-skills and win wherever those skills set a different default.

## Standing preferences
- The agent runs git, PRs, and debugging itself. The user's only steps are secrets.
- A step with no real trade-off is taken and noted in the report or PR. Real trade-offs and product calls are asked, with a recommendation.
- Read-only queries against any environment, production included, run without asking; writes and remote migrations wait for the user's OK.
- Bounded work (a flag, a one-file fix) runs in one pass, ends with a pushed branch and an open PR, and stops only on a real trade-off. A change in behavior is red-green: write the failing test, run it, quote the failing output, make the fix, run green, report.
- A spec is a GitHub issue in the repo (`gh issue create`); tickets are its sub-issues, labeled ready-for-agent. Where a skill would save a spec, ADR, or plan under docs/, the spec becomes an issue, the decision goes in the issue or PR, and the plan goes in the session scratchpad, uncommitted. CONTEXT.md entries are updated in the same PR, with no review needed.
- YAGNI.
- Library docs come from ctx7 or find-docs, never from memory.
- Subagents get the least capable model that can do the role, always set explicitly. Full reports go to files; returns are five lines or fewer.
- Merging into a repo's default branch needs the user's explicit go-ahead.
- Contributors' work is credited (Co-authored-by) and simplified while integrating. Nothing is asked of them, and departures are explained in the PR.

## Where skills overlap
- Finishing a branch: push it, open a PR into the default branch, or into the branch below in a stack (`gh stack submit` for a stack, else `gh pr create`), and report the link. The push-and-PR option is the user's standing answer to the superpowers:finishing-a-development-branch menu.
- After superpowers:writing-plans, the execution method is chosen, not asked: subagent-driven by default, inline for one or two small tasks. Bounded work, and a plan the user has already approved, executes in the same turn. An architectural or multi-ticket plan ends with the plan and the chosen method, ready to start on the user's OK; once approved, it runs without asking which method.
- Code review: wills-skills:review, which covers superpowers:requesting-code-review and mattpocock-skills:code-review.
- TDD: superpowers:test-driven-development is the one TDD skill to load; wills-skills:implement adds the seam rule.

## Skills
Each skill below is loaded whenever there is even a small chance it applies; each scales its own steps to the stakes.

| When | Skill |
|---|---|
| Usage questions, long or unattended runs, usage warnings | wills-skills:usage-pacing |
| Reviewing a branch, PR, or diff | wills-skills:review |
| Implementing one ticket or issue | wills-skills:implement |
| Working through a labeled backlog or several tickets, all or some | wills-skills:ticket-factory |
| Grilling an idea, speccing a feature, or breaking it into tickets | wills-skills:grill-to-tickets |
