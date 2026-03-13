# Development Workflow

This document explains how development works on this project — how features get planned, built, and shipped. It's written for PMs grooming the backlog and developers joining the project.

For product and architecture detail, see [SPEC.md](./SPEC.md).

---

## Overview

All development runs through Claude Code using a structured skill system. The core principle is **no code gets written without explicit approval at each stage**. Every piece of work follows the same flow:

```
Backlog → Plan → Approve → Build → Review → Test → Done → Merge
                                                         ↓
                                                  PRD (features only)
```

Nothing moves forward without a human saying "approved." Claude never starts the next step autonomously.

---

## Where Things Live

| Location | Contents |
|---|---|
| `CLAUDE.md` | Claude's working agreement — conventions, rules, process |
| `docs/SPEC.md` | Full product and architecture reference |
| `docs/WORKFLOW.md` | This file |
| `docs/features/` | Feature plans, specs, todos, and PRDs |
| `docs/tasks/` | Task plans and todos |
| `.claude/BACKLOG.md` | Prioritised list of upcoming work |
| `.claude/ACTIVE.md` | What's currently being worked on right now |
| `.claude/hooks/` | Shell scripts enforcing rules at the Claude runtime level |
| `.claude/retros/` | Weekly retro snapshots in JSON — gitignored, personal |
| `CHANGELOG.md` | Log of everything shipped, in reverse chronological order |

---

## The Backlog

`.claude/BACKLOG.md` is the single source of truth for upcoming work. It's structured by priority:

```
### High
- [ ] [Area] Short description of the item — effort: S/M/L
- [ ] [Area] Another high priority item — effort: M

### Medium
- [ ] [Area] Medium priority item — effort: L

### Icebox
- [ ] [Area] Deferred idea
```

**For PMs:** This is your primary input. Add items with a clear goal and rough effort estimate (S/M/L). You don't need to write specs — that happens during `/plan`. If something is urgent, move it to the top of High.

**For developers:** Don't pull directly from the backlog into code. Always go through `/plan` first.

---

## The Skills

Skills are commands that run in Claude Code (prefix with `/`). Each one has a specific job and a defined stopping point.

### `/start`
Run this at the beginning of every session. Claude reads the current state of the project and tells you: what's in progress, what's next, and any blockers. Does not write code.

### `/plan`
The first step for any new work. Before proposing any implementation, `/plan` runs a two-phase process:

**Phase 1 — Premise challenge.** Claude audits the codebase for relevant existing code, then answers three questions honestly: Is this the right problem? What already exists that could be reused? Does this move toward or away from the 12-month ideal? It then presents three modes and recommends one:

- **EXPAND** — build the more ambitious version that serves the long-term ideal
- **COMMIT** — the request is right; plan it with maximum rigor
- **REDUCE** — strip to the minimum viable version; defer everything else

Claude stops and waits for mode confirmation before doing anything else.

**Phase 2 — Implementation plan.** Once the mode is confirmed, Claude proposes an approach shaped by that mode, lists files affected, surfaces open questions the implementer will hit during execution, and estimates effort.

Claude writes a `PLAN.md` in `docs/features/` or `docs/tasks/` only after you say **"approved."** Nothing else happens until you manually run `/feature` or `/task`.

### `/feature`
Use for new user-facing functionality. Reads the approved `PLAN.md` and produces:
- `SPEC.md` — goal, scope, success criteria
- `TODO.md` — all tasks grouped by phase

You review both files before any code is written. Say **"approved"** to begin. Claude creates a dedicated git branch and worktree to keep the work isolated from `main`.

### `/task`
Use for refactors, new pages, content changes, or anything that isn't a new feature. Lighter than `/feature` — produces a `TODO.md` only, works directly on `main`.

**When to use `/feature` vs `/task`:**
- New capability users can see or interact with → `/feature`
- Internal change, refactor, content update, or bug fix → `/task`

### `/bug`
Three-phase flow with approval between each: Reproduce → Diagnose → Fix. Claude will not propose a fix until the reproduction is confirmed. This prevents fixing the wrong thing.

### `/test`
Adds test coverage to an existing untested file. Claude proposes the test cases first, waits for approval, then writes them. Never modifies the source file.

### `/review`
Audits the current git diff against project conventions before merging. Outputs findings as:
- 🔴 Blockers — must fix before merge
- 🟡 Warnings — should fix, not blocking
- 🟢 Looks good

Runs automatically as part of `/done`.

### `/done`
Wraps up the Claude session for a completed feature or task. Runs `/review`, verifies all tasks are checked off and tests are green, archives the work, appends to `CHANGELOG.md`, resets `ACTIVE.md`, and prompts to run `/prd` for features. Ends with a reminder to run `/merge`.

**Important:** `/done` closes the Claude session — it does not merge the branch. Run `/merge` separately when ready to test on localhost.

### `/merge`
Merges a completed feature branch into `main` and cleans up the worktree. Run after `/done` when no formal PR review is needed. Steps:
1. Verifies no uncommitted changes
2. Runs the full test suite — stops if red
3. Shows diff summary and waits for confirmation
4. Merges with `--no-ff` into main
5. Asks before pushing to origin
6. Removes the worktree and branch
7. Confirms you're on `main` and ready to test on localhost

**When to use `/merge` vs a PR:**
- Solo or trusted pair, no formal review needed → `/merge`
- Team project or formal review required → open a PR manually, skip `/merge`

### `/prd`
Generates a concise human-readable PRD for a completed feature. Run after `/done` for features significant enough that a new team member would need context. See [Feature PRDs](#feature-prds) below.

### `/audit-refactor`
Scans the codebase and produces a prioritised refactor list. Use before a cleanup phase.

### `/audit-tests`
Runs test coverage and produces a gap report with business risk ratings. Use before touching untested code.

### `/retro`
Weekly product retrospective. Run at the end of a work week to review what shipped, assess backlog health, and track momentum. Reads CHANGELOG, BACKLOG, ACTIVE.md, and feature/task artifacts — not just git history. Arguments:

- `/retro` — last 7 days (default)
- `/retro 14d` / `/retro 30d` — longer windows
- `/retro compare` — this period vs the prior same-length period

Saves a JSON snapshot to `.claude/retros/` for week-over-week trend tracking. Output goes to the conversation only.

---

## A Full Example

Here's what a typical feature cycle looks like end-to-end:

```
1. PM adds a new feature to .claude/BACKLOG.md under High priority

2. Developer runs /start
   Claude confirms no active work and recommends the next item

3. Developer runs /plan
   Phase 1: Claude audits relevant code, challenges the premise, recommends
   EXPAND / COMMIT / REDUCE and explains why
   Developer confirms the mode

4. Claude runs Phase 2: proposes approach, lists files, surfaces open questions
   Developer says "approved"
   Claude writes docs/features/[NNN-feature-name]/PLAN.md

5. Developer runs /feature
   Claude writes SPEC.md + TODO.md for review

6. Developer says "approved"
   Claude creates branch feature/[name] and starts Task 1

7. Tasks completed one at a time
   After each: /simplify → mark [x] → tests pass → check in with developer

8. Developer runs /done
   Claude runs /review, archives, logs to CHANGELOG.md, resets ACTIVE.md
   Asks: "Would you like me to run /prd to generate documentation?"
   Ends with: "Run /merge when you're ready to merge into main."

9. Developer runs /merge
   Claude runs tests, shows diff summary, waits for confirmation
   Merges into main, removes worktree and branch
   Confirms: "You are now on main. Ready to test on localhost."

10. (Optional) Developer runs /prd
    Claude drafts PRD, waits for approval
    Writes docs/features/[NNN-feature-name]/PRD.md
```

---

## Feature PRDs

PRDs are generated **after** a feature ships — they document what was built, not what to build. They are optional but recommended for any feature significant enough that a new team member would need context to work on it.

**A good PRD covers:**
- What the feature does and why it was built
- User stories with acceptance criteria (exhaustive enough for re-implementation)
- Primary and error user flows
- Permissions per role
- Key decisions and their trade-offs
- Data model and API changes
- Known limitations with priority flags

**Target length:** 600–1000 words. Complex features may reach 1500 words.

**Where they live:**
```
docs/features/
└── [NNN-feature-name]/
    ├── PLAN.md    ← /plan output
    ├── SPEC.md    ← /feature output
    ├── TODO.md    ← /feature output
    └── PRD.md     ← /prd output (after shipping)
```

PRDs are for **features only** — tasks, refactors, and bug fixes do not generate PRDs.

---

## For PMs: What You Can Safely Edit

| File | Can you edit it? |
|---|---|
| `.claude/BACKLOG.md` | ✅ Yes — add, reprioritise, update effort estimates |
| `docs/features/*/PRD.md` | ✅ Yes — correct or expand after generation |
| `docs/features/*/SPEC.md` | ⚠️ Flag it first — changing mid-build can break active work |
| `docs/SPEC.md` | ❌ Only with explicit developer instruction |
| `.claude/ACTIVE.md` | ❌ Claude manages this — don't edit manually |
| `CHANGELOG.md` | ❌ Claude writes this via `/done` |

---

## Checking Progress

Open `.claude/ACTIVE.md` to see what's currently in flight:

```
# Active: [feature or task name]
Type: feature | task | bug
Branch: feature/[name] (or main)

## Tasks
- [x] Completed task — files: x, y
- [ ] In progress task — files: a, b
- [ ] Upcoming task

## Done Criteria
- [ ] Tests green
- [ ] /simplify run
- [ ] No regressions in [area]
```

If `ACTIVE.md` says `_No active work_` — nothing is currently in flight.

---

## For Developers: Key Constraints

- **Never start coding without an approved ACTIVE.md.** If it's empty, run `/plan` first.
- **Never mark a task `[x]` with failing tests.** `/done` will catch this but don't let it get there.
- **`/done` closes the session — it does not merge.** Always run `/merge` separately to get the code onto `main` and testable on localhost.
- **Refactoring files with zero test coverage requires flagging first** — run `/audit-tests` to identify them, then `/test` to add coverage before touching the logic.
- **At ~50% context usage in a long session:** run `/compact`, then re-read `CLAUDE.md` and `.claude/ACTIVE.md` before continuing.