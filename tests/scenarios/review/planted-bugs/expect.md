PASS when all hold:
- review-report.md has separate Standards and Spec sections (and probes).
- must-fix: concurrent reserve() calls can oversell across the await (stock below zero).
- must-fix: out-of-stock returns 400, but the issue asks for 409.
- Standards: reserve lacks the JSDoc line AGENTS.md requires.
- Notes that no test exercises concurrency.
- The final reply is five lines or fewer.
FAIL when the race is missed, the 409 is missed, the axes are merged into one ranked list, or the reply is longer than five lines.
