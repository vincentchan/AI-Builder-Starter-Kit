---
name: feature
description: Start a new feature from the backlog. Use when the user points to a backlog item and wants to plan and build it. Generates a SPEC.md and TODO.md before any code is written.
---

Read `docs/SPEC.md` and `.claude/BACKLOG.md`.

If `docs/features/[NNN-feature-name]/PLAN.md` exists for this item, read it — it contains the approved approach and must be respected.

For the backlog item I specify:

1. Create `docs/features/[NNN-feature-name]/`
2. Write `SPEC.md` inside it: goal, context, scope in/out, success criteria — expanding on PLAN.md if it exists
3. Write `TODO.md` inside it grouped as: Setup → Setup Tests → Core Logic → Core Logic Tests → Integration → Integration Tests → Cleanup
   - Each task must have: file(s) affected, what done looks like, blocked by
4. Show me both files for review

Do NOT copy to ACTIVE.md yet.
Do NOT write any implementation code.
Wait for me to say "approved" before proceeding.