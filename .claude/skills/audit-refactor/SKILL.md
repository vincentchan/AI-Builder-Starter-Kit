---
name: audit-refactor
description: Scan the codebase for refactor opportunities. Use when the 
user wants a prioritized list of files to clean up, or before starting 
a refactoring phase.
---

The test suite must be green before running this. Verify first.

Scan the entire codebase and produce a refactor priority list.

For each file worth refactoring output:
1. File name
2. Specific problem (duplication / mixed concerns / too long / 
   poor error handling / N+1 / hardcoded values etc.)
3. Effort: small / medium / large
4. Risk given current test coverage: low / medium / high
5. What the refactor unlocks

Output as a numbered list ordered by: small effort + low risk first, 
large effort + high risk last.

At the end, recommend an attack order based on dependencies 
(e.g. extract constants before refactoring files that use them).

Do not write any code. Do not modify any file.
Wait for my instruction before doing anything.