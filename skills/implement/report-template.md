# Implementation Report: #<n> <title>

- Branch: `<branch>` at `<head sha, read after the push>`
- Status: done | checkpointed | blocked (<why>)

## Acceptance Criteria
- [x] <criterion>: <how it's met> (or [ ] <criterion>: <why not>)

## Red Evidence
| Test | Failing output before the fix |
|---|---|
| `<test name>` | `<one quoted line>` |

## Verification
- Full suite: <package>: <passed>/<total>
- Typecheck: <result> · Lint: <result>

## Choices Made
- <where the ticket left a choice open, what was chosen, why>

## For the Reviewer
- <what to probe: concurrency, migrations, auth, data loss, anything subtle>

## PR Notes
- <reserved numbers, deploy order, stack position, expected conflicts>

## Handoff (if checkpointed)
- Done: … · Left: … · Next step: …
