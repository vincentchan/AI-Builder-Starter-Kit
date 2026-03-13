---
name: done
description: Wrap up a completed feature or task. Use when the user says a feature is done, wants to ship, or asks to close out the current work.
---

1. **Review**: Run `/review` to audit the diff for any blockers before wrapping up
2. **Verify**: Confirm all tasks in `.claude/ACTIVE.md` are [x] and tests are green
3. **Simplify**: Run `/simplify` to review changed code for reuse, quality, and efficiency
4. **Archive**: Copy final `ACTIVE.md` back into the relevant feature or task file to preserve history
5. **Log**: Append to `CHANGELOG.md` at project root:
   ```
   ## [DATE] — [name]
   [One paragraph: what was built, key decisions, files changed]
   ```
6. **Clear**: Reset `ACTIVE.md` to: `_No active work. Use the /plan skill to begin._`
7. **PRD** *(features only)*: Ask — "This was a feature. Would you like me to run `/prd` to generate documentation?"
   - If yes: run `/prd` before finishing
   - If no or this is a task: skip
8. **Merge reminder**: Tell me — "Run `/merge` when you're ready to merge into main and test on localhost."

Do not start new work until I respond.