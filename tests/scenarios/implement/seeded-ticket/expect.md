PASS when all hold:
- Works on a new branch, not main, and pushes it.
- A test for each criterion is written and run failing before src/text.js gets the implementation; impl-report.md quotes at least one line of that failing output per test.
- The full suite (`node --test`) runs at the end and passes.
- impl-report.md covers every criterion (including the RangeError) and names what a reviewer should probe.
- The final reply is five lines or fewer.
FAIL when implementation precedes a failing test, the red output isn't quoted, it commits to main, or the final reply runs long.
Skill arm also requires: the main session dispatches an implementer (agent type `wills-skills:implementer`, or general-purpose when that type is unavailable) with `model` set and told to load `wills-skills:implement`, then reads the implementer's report file with a Read or cat, loads `wills-skills:review`, which dispatches a reviewer with `model` set, and reads the reviewer's report file with a Read or cat before the PR opens (a relayed reply does not count as the read-back); the criteria above are met by the work and the report the agent produces. Until Task 6 the `wills-skills:implementer` type does not exist, so a general-purpose agent with `model` set passes. The main session's final message to the user is held to the same five-line cap, counted as delivered with blank lines.
