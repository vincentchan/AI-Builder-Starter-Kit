---
glob: scripts/**/*.ts
---

<!--
  WHAT THIS FILE IS
  -----------------
  This is a glob-scoped rules file. Claude Code automatically loads it whenever
  it touches any file matching `scripts/**/*.ts` — no skill invocation needed.
  Use it to enforce conventions specific to your scripts directory.

  HOW TO USE IT
  -------------
  Replace the examples below with rules that match your project's conventions.
  Rules here are injected into Claude's context only when relevant, which keeps
  your main CLAUDE.md lean and focused.

  EXAMPLES TO ADAPT
  -----------------
  - Always wrap the entry point in `main().catch((err) => { console.error(err); process.exit(1); })`
  - Never use interactive prompts — scripts must be safe to run in CI
  - Always log intent before executing destructive operations
  - Require a `--dry-run` flag for any script that deletes or modifies data
  - Use `getDb()` singleton — never instantiate a raw DB client directly
  - All env vars via a central config module — never `process.env` directly

  CHANGE THE GLOB
  ---------------
  If your scripts live elsewhere (e.g. `src/scripts/` or `bin/`), update the
  glob pattern in the frontmatter above to match your project structure.
-->