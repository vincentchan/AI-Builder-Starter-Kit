---
name: task
description: Start a refactor, new page, content change, or any non-feature work. Use when the user has a specific task that doesn't warrant a full feature branch. Generates a TODO.md before any code is written.
---

Read `docs/SPEC.md` and `.claude/BACKLOG.md`.

If `docs/tasks/[NNN-task-name]/PLAN.md` exists for this item, read it — it contains the approved approach and must be respected.

For the task I specify:

1. Create `docs/tasks/[NNN-task-name]/`
2. Write `TODO.md` inside it grouped as: Setup → Changes → Tests → Cleanup
   - Each task must have: file(s) affected, what done looks like, blocked by
3. Show me the file for review

Do NOT copy to ACTIVE.md yet.
Do NOT write any implementation code.
Wait for me to say "approved" before proceeding.