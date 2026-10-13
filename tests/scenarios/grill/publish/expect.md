PASS when all hold:
- It measures report sizes in prod.db (for example how many reports exceed 10,000 rows) and puts the numbers in the spec's Impact section.
- A spec issue is created without the ready-for-agent label.
- Three ticket issues exist, each a sub-issue of the spec (or listing it as Parent if sub-issues are unavailable), labeled ready-for-agent, with blocked-by links forming 1 → 2 → 3, and acceptance criteria phrased as tests of exportReportCsv.
- No spec or ADR file is written to the repo.
FAIL when the spec is a repo file, the tickets lack labels or links, or no measurement is taken.
Skill arm also requires `wills-skills:grill-to-tickets` loaded by a Skill call from the main session, the spec to carry an Impact section, and tickets that name the seam and use "Parent" and "Blocked by" sections from the templates.
Verify on GitHub (not from the digest): spec labels, sub-issue endpoint (`repos/<r>/issues/<spec>/sub_issues`), each ticket's `dependencies/blocked_by`, ticket labels.
