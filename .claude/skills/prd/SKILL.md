---
name: prd
description: Generate a concise, human-readable PRD for a completed feature. Use after /done to document what was built, why, and how — for future reference, onboarding, and handoff. Features only, not tasks.
---

Read `docs/features/[NNN-feature-name]/SPEC.md`, `docs/features/[NNN-feature-name]/TODO.md`, the relevant `CHANGELOG.md` entry, and the changed files in the feature branch or diff.

Generate `docs/features/[NNN-feature-name]/PRD.md` following these principles:

**PRD philosophy:**
- Written for a new engineer who needs to understand what exists and why — well enough to re-implement it from scratch without reading the code
- Concise over comprehensive. If a section doesn't add insight, omit it.
- Document decisions and trade-offs, not just outcomes
- **Prefer tables over prose for anything involving comparisons, permissions, states, mappings, or multi-property descriptions**
- Target length: 600–1000 words for a standard feature, up to 1500 for a complex one with a state machine or significant data model changes
- Never pad with obvious information that can be inferred from reading the code

---

**Structure:**

## Overview
2–3 sentences. What this feature does, who it's for, and why it was built.

## Problem *(omit if obvious from overview)*
What gap or pain point this solves. One short paragraph.

## User Stories
Cover all delivered functionality comprehensively — primary flows, alternative paths, edge cases, error states, empty states, and every role that interacts with the feature. An engineer must be able to re-implement the feature from these stories alone.

**Format — Option B (default, for features with fewer than 10 stories):**

Group by role in a single table. The Story column contains the full statement without the role prefix. The Acceptance Criteria column lists all ACs as bullet points.

| Role | Story | Acceptance Criteria |
|---|---|---|
| Applicant | I want to see which tiers are available for my jurisdiction so that I can start the correct application. | • `/apply` shows all tiers with eligibility badges (available, in_progress, locked, approved, rejected, submitted)<br>• Jurisdiction picker allows switching between available jurisdictions<br>• Locked tiers display a message explaining the prerequisite tier requirement |
| System | I want to enforce one application per user/jurisdiction/tier so that duplicate submissions are prevented. | • POST returns 409 with `existing_id` if a duplicate exists<br>• Unique constraint on (applicant_id, jurisdiction, tier) enforced at DB level |

**Format — Option C (for features with 10+ stories):**

Use numbered story headers so they can be referenced in tickets and QA reports. Each story gets its own AC table.

### S1 — [Short story title]
As a [role], I want to [action] so that [outcome].

| | Acceptance Criteria |
|---|---|
| AC1 | [specific, testable condition] |
| AC2 | [specific, testable condition] |
| AC3 | [specific, testable condition] |

### S2 — [Short story title]
...and so on, one section per story.

**Acceptance criteria rules (apply to both formats):**
- 2–4 per story
- Specific and testable — not "it works correctly" but "the field saves within 800ms"
- Describe observable behaviour, not implementation details
- Cover the failure case if non-obvious (e.g. "If the session expires mid-form, the user is redirected to /login and the form state is restored after re-authentication")

## User Flow

### [Primary flow name]
Numbered steps describing what the user experiences — not how the system implements it. Implementation details belong in Key Decisions, not here.

1. User navigates to / sees [entry point]
2. User [action]
3. System [observable response]
4. ...until goal is complete

### [Alternative / error flow name] *(add one sub-section per meaningful alternate path)*
Document flows for:
- The primary happy path
- Key error states (failed submission, validation errors, network failure)
- Empty states (what does the UI show with no data?)
- Each role's distinct entry point if they differ

Keep each flow to 5–12 steps. Omit flows identical to existing patterns elsewhere in the product.

## Permissions
If more than one role interacts with this feature, include a table:

| Action | admin | analyst | senior_reviewer | applicant | Notes |
|---|---|---|---|---|---|
| [action] | ✅ | ❌ | ❌ | ❌ | [any nuance] |

If a role attempts a disallowed action, document what happens (redirect, 403, hidden UI, etc.).

## What Was Built
Bullet list of delivered capabilities in user-facing language. Each bullet completes: "Users can now..."

Use a table if there are component/hook/utility outputs worth listing:

| Type | Name | Purpose |
|---|---|---|
| Component | `FieldRenderer` | Renders all 12 field types from config |
| Hook | `useApplication` | Data fetching and auto-save |

## Key Decisions
The 3–6 most important design or technical decisions, and the reasoning behind each. This is the highest-value section — document the *why*, not just the *what*.

| Decision | Why | Trade-off |
|---|---|---|
| Used X instead of Y | Because Z | [acknowledged downside] |

## States & Transitions *(omit if no state machine)*
If the feature introduces stateful objects (applications, cases, documents), document using a table:

| Status | Description | Editable by user? | Who can trigger? |
|---|---|---|---|
| `draft` | ... | Yes | Applicant |

Follow with transition rules:

| From | To | Triggered by | Conditions |
|---|---|---|---|
| `draft` | `submitted` | Applicant clicks Submit | All required fields populated |

## Route & API Reference *(omit if unchanged)*
Only new or modified routes and endpoints:

| Method | Endpoint | Access | Description |
|---|---|---|---|
| GET | `/api/applications/:id` | applicant (own), analyst | Get application with data and documents |

## Data Model Changes *(omit if none)*
Only tables, columns, or types that were added or changed:

| Table / Type | Change | Notes |
|---|---|---|
| `applications` | Added `config_version_id` FK | Locks application to published config at creation |
| `application_status` enum | New: 8 lifecycle states | See States & Transitions |

## Scope

| In scope | Out of scope |
|---|---|
| [what's included] | [what was explicitly excluded and why] |

## Known Limitations & Future Considerations
Flag priority explicitly:

| Limitation | Priority | Notes |
|---|---|---|
| Required field validation at submit is missing | 🔴 Pre-launch blocker | Currently no server-side enforcement |
| No PDF export | 🟡 Post-launch | Nice to have, not blocking |
| No email notifications on status change | 🟡 Post-launch | Planned in a future notification feature |

Priority key: 🔴 Pre-launch blocker · 🟡 Post-launch · 🟢 Icebox

---

**Tone and style:**
- Past tense for what was built ("was added", "allows users to")
- Present tense for user stories and flows ("User selects...", "System returns...")
- Avoid implementation jargon in user-facing sections (flows, stories)
- Use tables by default for: permissions, states, transitions, API endpoints, data model changes, decisions, scope, and limitations
- Use prose only for: overview, problem, and narrative descriptions within flows
- Do not reproduce the entire data model or full API list — only what changed or is directly relevant

Show me the PRD draft before writing to disk.
Wait for my approval or edits, then write `docs/features/[NNN-feature-name]/PRD.md`.