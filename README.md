# AI Builder Starter Kit

A structured workflow system for building software with [Claude Code](https://docs.anthropic.com/en/docs/claude-code). Think of it as a pit crew for your codebase — Claude does the heavy lifting, but nothing moves without you waving the flag.

This isn't a framework you install. It's a project template you clone and make your own. It gives Claude Code a working agreement, a skill system, and safety guardrails so you can build ambitious things without worrying about Claude going rogue on your codebase.

---

## Who This Is For

You're an AI builder who's tried Claude Code and thought: *"This is powerful, but I need more structure."* Maybe you've had Claude rewrite a file you didn't want touched. Maybe you've lost track of what was planned vs. what was built. Maybe you just want a repeatable process that scales beyond "chat and hope."

This kit gives you that structure. It's opinionated on purpose and simple on purpose — so you can bend it to fit your project, not the other way around.

---

## The Core Idea

Most AI coding workflows are a conversation. You ask, Claude writes, you review. It works for small tasks, but it falls apart when you're building something real. Context gets lost. Conventions drift. Nobody remembers why that function exists.

This kit turns that conversation into a **pipeline with approval gates**.

```
Backlog → Plan → Approve → Build → Review → Ship
```

At every stage, Claude stops and waits for you to say "approved" before moving on. It's like having a junior developer who's brilliant at execution but always checks in before making big decisions. You stay in the driver's seat. Claude stays productive.

The pipeline runs through **skills** — slash commands that each handle one phase of the workflow. `/plan` plans. `/feature` builds. `/review` audits. `/done` wraps up. Each skill knows exactly what to do, what to produce, and when to stop.

---

## Quick Start

**1. Clone and rename**

```bash
git clone https://github.com/your-org/ai-builder-starter-kit.git my-project
cd my-project
rm -rf .git && git init
```

**2. Fill in your project context**

Open `CLAUDE.md` and fill in the "What We're Building" and "Tech Stack" sections. This is the single most important thing you'll customize — it tells Claude what kind of project it's working on.

Open `docs/SPEC.md` and sketch out your product and architecture. Even a few bullet points help Claude make better decisions.

**3. Add your first backlog item**

Open `.claude/BACKLOG.md` and add something under High priority:

```markdown
### High
- [ ] [Auth] Add email/password sign-up flow — effort: M
```

**4. Start building**

```bash
claude
> /start
> /plan
```

Claude will challenge your premise, propose an approach, and wait for your approval. Once approved, run `/feature` or `/task` to begin.

That's it. You're in the loop.

---

## The Workflow

Here's how a piece of work flows through the system, from idea to merged code:

```
  ┌─────────────────────────────────────────────────────────┐
  │                    .claude/BACKLOG.md                    │
  │              (you add items here by priority)            │
  └──────────────────────────┬──────────────────────────────┘
                             │
                         /start
                    (read project state)
                             │
                          /plan
              ┌──────────────┼──────────────┐
              │              │              │
           EXPAND        COMMIT         REDUCE
              │              │              │
              └──────────────┼──────────────┘
                             │
                     writes PLAN.md
                     waits for "approved"
                             │
                 ┌───────────┴───────────┐
                 │                       │
             /feature                  /task
          (new capability)        (refactor, content,
           creates branch          non-feature work)
           + worktree              works on main
                 │                       │
                 └───────────┬───────────┘
                             │
                    writes SPEC.md + TODO.md
                    waits for "approved"
                             │
                       Build tasks
                   (one at a time, each:
                    code → test → mark [x]
                    → check in with you)
                             │
                          /done
                  (review → archive → changelog)
                             │
                  ┌──────────┴──────────┐
                  │                     │
               /merge               open PR
           (solo/trusted)        (team review)
                  │                     │
                  └──────────┬──────────┘
                             │
                    Code on main, tested,
                      ready to ship
```

**The key principle:** Claude never advances to the next stage without your explicit approval. You can reject a plan, ask for changes, or pivot entirely — and Claude adapts without losing context.

**Why this actually works:** Three practices woven into the pipeline keep fast-moving AI code from turning into a mess. 

- First, test-driven development — the `/test` skill and the build loop (code → test → mark done) mean nothing ships without proof it works. 
- Second, regular refactoring — `/audit-refactor` gives you a prioritized cleanup list so technical debt doesn't quietly accumulate while you're sprinting on features. 
- Third, automated code review on every single edit — the `post-edit-quality.sh` hook runs lint and type-check the moment Claude saves a file, and `/review` audits the full diff before you merge. 

Together, these three create a safety net that lets you iterate fearlessly. You can move fast *because* the guardrails catch problems before they compound — not three days later in a PR review, but right now, as the code is being written.

---

## The Skills

Skills are slash commands you run inside Claude Code. Each one handles a specific phase of the workflow. There are 13 in total, grouped by what they do.

### Session Management

| Skill | What it does | When to use it |
|-------|-------------|----------------|
| `/start` | Reads ACTIVE.md, SPEC.md, and CLAUDE.md. Reports what's in progress, what's next, and any blockers. | Beginning of every session. |

### Planning

| Skill | What it does | When to use it |
|-------|-------------|----------------|
| `/plan` | Two-phase process: challenges your premise, then proposes an implementation plan. Recommends EXPAND, COMMIT, or REDUCE mode. Writes `PLAN.md`. | Before any new work. Always. |

### Building

| Skill | What it does | When to use it |
|-------|-------------|----------------|
| `/feature` | Reads approved PLAN.md, produces SPEC.md + TODO.md, creates a git worktree and feature branch. | New user-facing functionality. |
| `/task` | Like `/feature` but lighter — produces TODO.md only, works on `main` directly. | Refactors, content changes, internal work. |
| `/bug` | Three-phase: Reproduce → Diagnose → Fix, with approval between each phase. | When something's broken. |

### Quality

| Skill | What it does | When to use it |
|-------|-------------|----------------|
| `/test` | Proposes test cases for untested code, waits for approval, writes them. Never modifies source. | Adding coverage to existing code. |
| `/review` | Audits the current diff against project conventions. 🔴 Blockers, 🟡 Warnings, 🟢 Looks good. | Before merging. Runs automatically in `/done`. |

### Shipping

| Skill | What it does | When to use it |
|-------|-------------|----------------|
| `/done` | Runs review, verifies tests, archives work, logs to CHANGELOG.md, resets ACTIVE.md. | When all tasks are checked off. |
| `/merge` | Runs tests, shows diff, merges into main, cleans up worktree and branch. | After `/done`, when no PR review is needed. |

### Documentation & Analysis

| Skill | What it does | When to use it |
|-------|-------------|----------------|
| `/prd` | Generates a human-readable PRD for a shipped feature (600–1000 words). | After `/done` for significant features. |
| `/audit-refactor` | Scans codebase, produces a prioritized refactor list. | Before a cleanup phase. |
| `/audit-tests` | Runs coverage, identifies gaps, ranks by business risk. | Before touching untested code. |
| `/retro` | Weekly retrospective: what shipped, backlog health, momentum trends. | End of each work week. |

---

## Project Structure

```
your-project/
├── CLAUDE.md                    ← The working agreement (conventions, rules, process)
├── CHANGELOG.md                 ← Auto-populated shipping log
├── docs/
│   ├── SPEC.md                  ← Product and architecture reference
│   ├── WORKFLOW.md              ← Detailed workflow documentation
│   ├── features/                ← Feature artifacts (PLAN.md, SPEC.md, TODO.md, PRD.md)
│   └── tasks/                   ← Task artifacts (PLAN.md, TODO.md)
├── .claude/
│   ├── ACTIVE.md                ← Current work-in-progress (managed by Claude)
│   ├── BACKLOG.md               ← Prioritized work queue (managed by you)
│   ├── settings.json            ← Permissions and hook configuration
│   ├── hooks/                   ← Shell scripts that enforce rules at runtime
│   │   ├── pre-edit-protect-paths.sh
│   │   ├── pre-bash-guard.sh
│   │   └── post-edit-quality.sh
│   ├── commands/                ← Skill definitions (one .md per skill)
│   └── rules/                   ← Additional rule files for Claude
├── .env.local.example           ← Environment variable template
└── .gitignore                   ← Configured for Node.js, Next.js, Supabase, Claude
```

**The files you'll touch most:**
- `CLAUDE.md` — Your project's constitution. Update it as conventions evolve.
- `.claude/BACKLOG.md` — Where all work starts. Add items, set priorities.
- `docs/SPEC.md` — Your product brain. The more detail here, the smarter Claude gets.

**The files Claude manages:**
- `.claude/ACTIVE.md` — Shows what's in flight. Read it anytime; don't edit it.
- `CHANGELOG.md` — Auto-updated by `/done` with each shipped piece of work.
- `docs/features/` and `docs/tasks/` — Artifacts from the planning and building phases.

---

## The Safety Net

Claude Code is powerful, which means it can also be powerfully wrong. This kit includes three hook scripts that act as guardrails — they run automatically before and after Claude uses certain tools.

### `pre-edit-protect-paths.sh`

Fires before every file edit. Prevents Claude from touching:

- **`.env` files** — Your secrets. Claude can't read or write them.
- **`pnpm-lock.yaml`** — Managed by your package manager, not by AI.
- **`supabase/migrations/`** — Irreversible schema changes need human hands.
- **Any file in "Always Flag Before Touching"** — A list you define in `CLAUDE.md` for sensitive files in your project.

If Claude tries to edit a protected file, it stops and asks you for permission instead of plowing ahead.

### `pre-bash-guard.sh`

Fires before every shell command. Blocks destructive operations:

- `rm -rf` on root or absolute paths
- `git reset --hard` (destroys uncommitted work)
- `git push --force` (rewrites remote history)
- `supabase db reset` (drops your schema)

Also enforces `pnpm` over `npm` if that's what your project uses.

### `post-edit-quality.sh`

Fires after every successful file edit. Runs:

- **ESLint** on TypeScript/TSX files
- **TypeScript type-check** in `noEmit` mode

If either fails, Claude reads the errors and self-corrects. It's like a real-time code review that happens on every edit, not just at PR time.

---

## Customization Guide

This kit is intentionally minimal. Here's what to customize first, in order:

### 1. `CLAUDE.md` — Start here

Fill in the empty sections:
- **"What We're Building"** — One paragraph describing your product.
- **"Tech Stack"** — List your frameworks, database, hosting, etc.
- **"Always Flag Before Touching"** — Add paths to files that are sensitive in your project (auth config, billing logic, database schemas).

The code conventions are pre-filled for a Next.js + Supabase stack. If you're using something different, update them to match.

### 2. `docs/SPEC.md` — Your product brain

The more you put here, the smarter Claude's planning becomes. Even rough bullet points under Products, Architecture, and Key Data Flow will dramatically improve `/plan` output.

### 3. `.claude/BACKLOG.md` — Your work queue

Add your first few items. Use the priority/effort format:

```markdown
### High
- [ ] [Area] Description — effort: S/M/L

### Medium
- [ ] [Area] Description — effort: S/M/L

### Icebox
- [ ] [Area] Future idea
```

### 4. Hook scripts — Your guardrails

The hooks in `.claude/hooks/` are configured for a Next.js + pnpm + Supabase project. Adjust them for your stack:

- Change `pnpm` enforcement to `yarn` or `npm` if needed.
- Add or remove protected paths in `pre-edit-protect-paths.sh`.
- Add linters or formatters to `post-edit-quality.sh`.

### 5. `.claude/rules/` — Extra conventions

Drop additional rule files here for domain-specific conventions (component patterns, API design, etc.). Claude reads them automatically.

---

## Philosophy

A few opinions baked into this kit:

**Approval gates over autonomy.** AI that writes code without checkpoints will eventually write the wrong code at the wrong time. Every skill stops and waits. This costs you a few seconds per approval and saves you hours of debugging surprise changes.

**Plans before code.** The `/plan` skill exists because the hardest bug to fix is one where you built the wrong thing. Challenging the premise before writing a line of code is the highest-leverage habit in software.

**Convention enforcement at runtime, not review time.** The hook scripts catch problems the moment they happen — not three hours later in a PR review. Claude self-corrects immediately.

**Small, composable skills.** Each skill does one thing. They combine into a pipeline but work independently. You can run `/review` without `/done`. You can run `/test` on any file, anytime. No skill depends on another to function.

**Intentionally simple.** There's no plugin system, no configuration DSL, no abstraction layers. It's markdown files and shell scripts. If you want to change how something works, you open the file and change it. That's the whole extension model.

---

## Contributing

This is a starter kit — fork it, bend it, make it yours. If you find a bug or have an improvement that would help everyone:

1. Fork the repo
2. Create a feature branch
3. Submit a PR with a clear description of what changed and why

---

## License

MIT — do whatever you want with it.
