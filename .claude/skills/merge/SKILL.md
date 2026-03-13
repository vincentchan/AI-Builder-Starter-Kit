---
name: merge
description: Merge a completed feature branch into main, remove the worktree and branch, and confirm localhost is on main. Use after /done when working solo or when no formal PR review is needed. Do not use if a PR review is required.
---

Read `.claude/ACTIVE.md` to confirm active work has been cleared. If ACTIVE.md still contains tasks, stop and tell me to run /done first.

Then run the following steps, pausing for confirmation before any destructive or irreversible git operation:

1. **Verify branch state**
   - Run `git worktree list` to confirm the feature worktree exists
   - Run `git status` inside the worktree to confirm no uncommitted changes
   - If uncommitted changes exist: stop, report what's uncommitted, wait for instruction

2. **Run tests**
   - Run the full test suite from the feature branch: `npx vitest run`
   - If any tests fail: stop, report which tests failed and why, wait for instruction
   - Do not proceed with a red test suite

3. **Show diff summary**
   - Run `git diff main...feature/<feature-name> --stat`
   - Show me: files changed, insertions, deletions
   - Wait for me to confirm I want to proceed

4. **Merge** *(after confirmation)*
   - `git checkout main`
   - `git pull origin main` (to ensure main is up to date)
   - `git merge --no-ff feature/<feature-name> -m "feat: merge feature/<feature-name>"`
   - If merge conflicts: stop, list the conflicting files, wait for instruction

5. **Push**
   - Ask: "Push to origin/main?" — wait for explicit yes before pushing
   - If yes: `git push origin main`

6. **Clean up**
   - `git worktree remove .worktrees/<feature-name>`
   - `git branch -d feature/<feature-name>`
   - Confirm: "Worktree and branch removed."

7. **Confirm state**
   - Run `git branch` and confirm current branch is `main`
   - Run `git log --oneline -3` to show the merge commit
   - Tell me: "You are now on main. Ready to test on localhost."

Do not run any step without first completing the previous one successfully.
Do not push without my explicit confirmation in step 5.