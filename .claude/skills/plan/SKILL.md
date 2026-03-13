---
name: plan
description: Define the approach for a feature or task before any code is written. Pressure-tests whether the right thing is being built before committing to an approach. Outputs a PLAN.md for approval — no code, no SPEC, no TODO until approved.
---

# Philosophy

Your job is not to rubber-stamp the request. Your job is to find the best version of what the user is trying to accomplish — which is sometimes the thing they asked for, sometimes a simpler version of it, and sometimes something different entirely. Do not start proposing implementation until the product direction is locked.

This skill has two phases. Phase 1 challenges the premise. Phase 2 plans the execution. Never skip Phase 1.

---

# Phase 1: Premise Challenge

## Step 1 — Codebase audit

Before forming any opinion, read context:

```
Read: CLAUDE.md, docs/SPEC.md, .claude/BACKLOG.md
Grep: search for related code, types, and existing utilities relevant to the request
Read: any files directly relevant to the request area
```

Map what already exists that touches this problem. You are looking for:
- Code that already partially or fully solves each sub-problem
- Patterns this feature should follow (or deliberately break from)
- Technical debt or known pain points in the area being touched
- Other backlog items that interact with or depend on this one

Report your findings in 3–5 bullet points before proceeding.

## Step 2 — Challenge the premise

Answer these three questions honestly. Do not skip them to be agreeable.

**Is this the right problem?**
Could a different framing yield a dramatically simpler or more impactful solution? State the actual user or business outcome this is meant to produce. Is the request the most direct path to that outcome — or is it solving a proxy problem?

**What already exists?**
Map each sub-problem in the request to existing code. What can be reused, extended, or captured from existing flows? If this plan rebuilds something that already exists, say so explicitly and explain why rebuilding is better than refactoring.

**Where does this leave us in 12 months?**
```
CURRENT STATE         THIS REQUEST            12-MONTH IDEAL
[describe]     --->   [describe delta]  --->  [describe target]
```
Does this move toward the 12-month ideal or away from it?

## Step 3 — Mode selection

Based on the audit and premise challenge, present the user with three options. Recommend one based on what you found. Be opinionated — do not hedge.

```
┌──────────────────────────────────────────────────────────────┐
│  MODE SELECTION                                              │
├──────────────────────────────────────────────────────────────┤
│  A) EXPAND    Build the more ambitious version that serves   │
│               the 12-month ideal. What would make this 10x   │
│               better for 2x the effort?                      │
│                                                              │
│  B) COMMIT    The request is right. Plan it with maximum     │
│               rigor — architecture, edge cases, error paths, │
│               test coverage. Make it bulletproof.            │
│                                                              │
│  C) REDUCE    Strip to the minimum viable version that ships │
│               value. Defer everything that can be deferred.  │
└──────────────────────────────────────────────────────────────┘
```

Default heuristics:
- Greenfield feature, no existing code in this area → recommend EXPAND
- Clear scope with multiple edge cases to nail → recommend COMMIT
- Request touches >8 files or feels over-engineered → recommend REDUCE
- Bug fix or regression → always recommend COMMIT
- User says "quick", "simple", "just" → recommend REDUCE unless the request is actually non-trivial
- Request rebuilds something that already exists → challenge this before offering modes

State your recommendation and why in 2–3 sentences. Then **stop and wait for the user to confirm the mode before proceeding to Phase 2.**

---

# Phase 2: Implementation Plan

Only run Phase 2 after the user has confirmed a mode.

Apply the chosen mode faithfully. Do not drift. If EXPAND was chosen, don't argue for less work. If REDUCE was chosen, don't sneak scope back in.

## Step 4 — Approach

Based on the confirmed mode:

- **EXPAND**: Propose the ambitious version. What's the version that serves the 12-month ideal? Describe the concrete scope expansion, then propose 1–2 implementation approaches for it.
- **COMMIT**: Propose 1–3 implementation approaches if there's meaningful ambiguity. Otherwise propose the single best approach with rationale. No scope changes.
- **REDUCE**: Define the minimum viable scope — what ships value to the user without everything else? Explicitly list what is being deferred and why. Propose the single simplest implementation approach.

For each approach, note:
- What it buys you
- What it costs you (effort, complexity, future flexibility)
- Which TypeScript/Next.js/Supabase patterns it relies on

## Step 5 — Implementation details

**Files affected**
List every file that will need to be created or modified, and what changes in each.

**Open questions**
Surface every decision the implementer will hit during execution that should be resolved now — not during coding. Think through:
- Hour 1 (setup, scaffolding): What needs to be known before starting?
- Hour 2–3 (core logic): What ambiguities will arise mid-build?
- Hour 4+ (integration, tests): What will be surprising or under-specified?

Format as actionable questions, not vague concerns.

**Effort estimate**
Small / Medium / Large with a one-line reason. If EXPAND mode changed the scope significantly, re-estimate relative to the original request.

**Risk flags**
Call out anything that could go wrong during implementation. File-level: anything touching the "Always Flag Before Touching" list in CLAUDE.md. Scope-level: decisions baked into this plan that are hard to reverse.

---

# Output: PLAN.md

Write the PLAN.md to:
- Features: `docs/features/[NNN-feature-name]/PLAN.md`
- Tasks: `docs/tasks/[NNN-task-name]/PLAN.md`

Use this format:

```
# Plan: [name]
Type: feature | task
Mode: EXPAND | COMMIT | REDUCE
Date: [DATE]

## Goal
[One sentence — the actual outcome being produced, not just what's being built]

## Premise Check
[1–3 sentences on what exists, what was challenged, and why this approach was chosen over alternatives. If EXPAND, note what changed from the original request. If REDUCE, note what was deferred and why.]

## Approach
[Chosen approach + rationale. For EXPAND, describe the expanded scope. For REDUCE, describe what was cut and deferred.]

## Files Affected
- `path/to/file.ts` — what changes and why

## Open Questions
- [ ] Question 1 — what it unblocks

## Effort
[Small / Medium / Large] — [reason]

## Risk Flags
- [flag] — [why it matters]
```

Show the PLAN.md content and ask:

> **Mode selected: [EXPAND / COMMIT / REDUCE]**
>
> Ready to proceed? Say **approved** to continue with `/feature` or `/task`, or give feedback to revise.

Do NOT write SPEC.md, TODO.md, or any code. Wait for approval.