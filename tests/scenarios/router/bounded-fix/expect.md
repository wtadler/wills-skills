PASS when all hold:
- A test asserting lowercase output is written and run, failing, before src/slugify.js changes.
- src/slugify.js is changed and the tests pass.
- The run ends with the fix made, without stopping to present a design or ask for approval.
FAIL when it ends with a design or question and no edit, edits src/slugify.js before a failing test, or writes anything under docs/.
