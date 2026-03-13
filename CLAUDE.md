# Project Working Agreement

## What We're Building



## Tech Stack


## Code Conventions

- **Imports:** External packages → `@/lib/*` → relative
- **DB access:** Via `createClient()` from `@/lib/supabase/server` (server) or `@/lib/supabase/client` (browser)
- **Error handling (scripts):** `main().catch((err) => { console.error(...); process.exit(1); })`
- **Error handling (lib):** Catch and log at API boundary; callers decide whether to throw
- **Naming:** `kebab-case` files, `camelCase` functions/vars, `PascalCase` components/types
- **Supabase:** Always `const { data, error } = await supabase.from("table")...` — destructure both
- **Components:** Under 50 lines, props-only, no data fetching inside components
- **Pages:** Server components, parallel fetching via `Promise.all()`

## Non-Negotiables

- **Never run destructive scripts without confirmation.** 
- **Never commit API keys.** 
- **Tests must stay green.** Don't mark tasks done if red. Don't merge if red.
- **Refactoring untested code requires flagging first.** Many files have zero coverage — call it out before touching them.

## Always Flag Before Touching

Stop and explicitly flag before making any changes to these files:



## Working Process

- Always read `docs/SPEC.md` and `.claude/ACTIVE.md` at the start of a session
- Never write code for anything not listed in `.claude/ACTIVE.md`
- Never modify `docs/SPEC.md` without my explicit instruction
- When the spec is ambiguous: stop, flag it, offer 2–3 options, wait for my decision
- After completing each task: run `/simplify`, mark it `[x]` in ACTIVE.md, confirm tests pass, then check in with me before the next task
- Use plan mode for any task estimated as medium or large effort
- If staying in the same task, at 50% context usage: run `/compact`, then re-read `CLAUDE.md` and `.claude/ACTIVE.md` before continuing
- If switching to a new task, run `/clear` to reset context mid-session 
- For `/feature`: create a git worktree (`git worktree add .worktrees/<feature-name> -b feature/<feature-name>`), work in isolation, PR to merge to main
- For `/task`: work on `main` directly — one task session at a time, or use a worktree for parallel sessions
- On session restart: check for existing worktrees with `git worktree list` and resume from the active one
- Before any refactor touching untested files: create a checkpoint

## ACTIVE.md Structure

Every `/feature` and `/task` must populate ACTIVE.md using this exact structure:

```md
# Active: [name]
Type: feature | task | bug
Branch: feature/xxx (or main)
Spec: @docs/features/xxx/SPEC.md (or @docs/tasks/xxx/TODO.md)

## Tasks
- [ ] Task 1 — files affected: x, y
- [ ] Task 2

## Done Criteria
- [ ] Tests green
- [ ] /simplify run
- [ ] No regressions in [specific areas]
```

## Skills Available

- `/start` — session kickoff
- `/plan` — plan a backlog item before committing to build it
- `/feature` — plan and build a new feature (run after `/plan` approval)
- `/task` — refactors, new pages, content changes, non-feature work (run after `/plan` approval)
- `/test` — reverse TDD on existing untested code
- `/bug` — investigate and fix bugs or logic issues
- `/done` — archive, changelog, clear active work
- `/review` — audit current diff for convention violations before merging
- `/audit-refactor` — codebase refactor priority list
- `/audit-tests` — test coverage gap report
- `/prd` — generate feature documentation after shipping (features only)
- `/retro` — weekly product retrospective (what shipped, backlog health, momentum)