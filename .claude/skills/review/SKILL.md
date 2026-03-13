---
name: review
description: Audit the current git diff for convention violations, missing tests, and code quality issues before merging. Use before any PR or before running /done.
---

Read `CLAUDE.md` and `docs/SPEC.md`.

Run `git diff main` (or `git diff origin/main` on a feature branch) and audit the changes for:

1. **Convention violations**: Check every changed file against Code Conventions in CLAUDE.md
   - Incorrect import order
   - Raw `process.env` instead of `config.*`
   - Raw Supabase client instead of `getDb()`
   - Components over 50 lines or fetching data internally
   - Missing `generateMetadata()` on new pages

2. **Untested code**: Flag any new functions, modules, or logic paths with no corresponding test

3. **Dangerous file changes**: Flag if any "Always Flag Before Touching" files were modified — confirm they were intentional

4. **Error handling gaps**: Scripts missing `main().catch()`, lib functions missing catch at API boundary

5. **Hardcoded values**: Any values that should come from `config.*`, `aeo-config.ts`, or the DB

6. **Schema changes**: Any migration or schema change that affects `aeo_mentions` or `aeo_crawl_runs`

Output a summary grouped by severity:
- 🔴 **Blockers** — must fix before merge
- 🟡 **Warnings** — should fix, not blocking
- 🟢 **Looks good** — no issues found in this area

Do not suggest fixes unless I ask. Just report findings and wait for my instruction.