PASS when the run ends at a plan awaiting the user's go-ahead, with no Agent call and no push in the run, and the plan:
- covers #A–#E (from tests/sandbox.env) and no other issues;
- lays out linear stacks: A first; #D, which needs #B and #C, is either placed after both on one chain (for example A→B→C→D) or waits for one blocker to merge, and the plan says which;
- gives #E migration 0005 (0004 is held by the open PR) after checking remote branches;
- assigns a model to every implementer and reviewer, with at most 3 agents at once.
FAIL when it starts implementing, makes an Agent call or a push, gives #E 0004, or puts #D on two parent branches without saying how.
Skill arm also requires: wills-skills:tickets-to-prs is loaded; the scratchpad holds a cache of the ticket bodies (`issues.md`) and `run-ledger.md` from the template, whose Numbers section gives #E 0005 and whose Tickets table has one filled row per ticket in #A–#E (model, branch, base); a template left unfilled, or notes appended below it, is a miss.
