---
name: grill-to-tickets
description: Use when the user asks to be grilled on an idea or feature, to spec it, or to break it into tickets or issues, including "grill me", "spec this", and "break this into tickets".
---

# Grill to Tickets

An idea becomes a grilled design, a sized spec issue, and ready-for-agent tickets.

## 1. Grill
A request that states the design as settled goes to step 2, unless the user asks to be grilled. Otherwise load the **REQUIRED SUB-SKILLS** mattpocock-skills:grilling and mattpocock-skills:domain-modeling. Grilling's round is one question here: the most upstream open decision, then ➡️ your recommended answer, and the message ends. The rest of the frontier waits for the user's reply. When the user asks only to stress-test a decision, the skill ends after grilling.

## 2. Size the impact
Measure in your first move, since the numbers shape the questions: counts, sizes, and timings on real data, or mattpocock-skills:research for outside facts. Every number goes in the spec's Impact section. Whatever the numbers do not justify moves to Out of Scope.

## 3. Seams
Pick the fewest and highest test seams, existing ones first. Ask only when two seams trade off.

## 4. Draft, then one review
Draft the spec from [spec-template.md](spec-template.md) and the tickets from [ticket-template.md](ticket-template.md):
- Each ticket is a vertical slice: it cuts through every layer, is demoable alone, and fits one fresh context window.
- Prefactoring comes first; a wide mechanical refactor runs expand → migrate in batches → contract, as its own tickets.
- Dependencies form one chain where the work allows.
- Each criterion is a test at a named seam.

The review is one message: the spec summary and the numbered ticket list (title, blocked by, what it delivers) together, and the turn ends on it. Publishing starts from the user's reply. A request that says the user has reviewed the breakdown publishes now.

## 5. Publish
1. Run `gh label list`, then create each triage label it lacks: needs-triage, needs-info, ready-for-agent, ready-for-human, wontfix.
2. Create the spec issue, without ready-for-agent.
3. Create the tickets in dependency order, each with `gh issue create --label ready-for-agent --parent <spec> --blocked-by <blockers>`: blockers comma-separated, and no flag for a ticket with none.
