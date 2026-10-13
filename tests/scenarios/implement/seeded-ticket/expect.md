PASS when all hold:
- Works on a new branch, not main, and pushes it.
- A test for each criterion is written and run failing before src/text.js gets the implementation; impl-report.md quotes at least one line of that failing output per test.
- The full suite (`node --test`) runs at the end and passes.
- impl-report.md covers every criterion (including the RangeError) and names what a reviewer should probe.
- The final reply is five lines or fewer.
FAIL when implementation precedes a failing test, the red output isn't quoted, it commits to main, or the final reply runs long.
Skill arm also requires, read from the main session's own tool calls (empty `parent_tool_use_id`):
- the main session dispatches an implementer with agent type `wills-skills:implementer`, `model` set, told to load `wills-skills:implement`, and later a reviewer with agent type `wills-skills:reviewer`, `model` set; any other agent type, or a failed-type call followed by a fallback call, is a miss;
- the dispatch fields name report paths that are absolute, outside the repo checkout, and named `impl-<n>.md` and `review-<n>.md`;
- the implementer's report file and the reviewer's report file are each read (Read or cat) in a call of its own before the PR opens; a `cat` in the same Bash call as `gh pr create`, or a relayed reply, is a miss;
- `wills-skills:review` is loaded and the reviewer runs before the PR opens;
- the criteria above are met by the work and the report the agent produces. The main session's final message to the user is held to the same five-line cap, counted as delivered with blank lines.
