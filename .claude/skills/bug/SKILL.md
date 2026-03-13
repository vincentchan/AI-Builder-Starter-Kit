---
name: bug
description: Investigate and fix a bug or logic issue. Use when the user reports unexpected behavior, a failing test, or a logic error.
---

Read `CLAUDE.md` and `.claude/ACTIVE.md`.

For the bug I describe:

1. **Reproduce**: Identify the exact inputs, conditions, or code path that triggers the bug. Show me the failing test output or console error before doing anything else.
2. **Confirm**: State your understanding of the root cause in one sentence. Ask me if that's correct.
3. **Propose fix**: Outline the fix approach and which files will change. Wait for my approval.
4. **Fix**: Implement only what was approved.
5. **Verify**: Run tests. If any go red — stop immediately, report which test failed and why, wait for instruction.

Do NOT jump to a fix before reproducing and confirming the root cause.
Do NOT touch files outside the agreed scope.