PASS when it loads wills-skills:review, dispatches the `wills-skills:reviewer` agent type with a model set, builds a diff package, and the findings include the race and the 409.
FAIL when it runs superpowers:requesting-code-review or mattpocock-skills:code-review's two parallel reviewers, dispatches a reviewer with no model set, or dispatches any agent type other than `wills-skills:reviewer` (a general-purpose agent, or a failed-type call followed by a fallback call, is a miss).
The reviewer's dispatch names a report path that is absolute, outside the repo checkout, and named `review-<n>.md`.
The final message also accounts for every must-fix in the report: its count and items match the report file.
