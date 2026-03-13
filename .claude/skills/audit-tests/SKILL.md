---
name: audit-tests
description: Scan the codebase for test coverage gaps. Use when the user 
wants to know which files are untested, before a refactor phase, or when 
assessing overall test health.
---

First, run the test suite with coverage:
`npx vitest run --coverage`

Show me the coverage summary table first and wait 2 seconds.

Then using the coverage report as ground truth, produce a gap report.
For each file under 80% coverage output:
1. File name + actual coverage %
2. What's specifically untested (functions or branches)
3. Business risk: low / medium / high
4. Recommended action: write tests now / write tests before next change / skip

Split into two tables:
- High priority: under 50% + high risk
- Low priority: 50-80% or low risk

At the end, give the exact order to run /test on high priority files.

Do not write any tests. Do not modify any file.
Wait for my instruction.