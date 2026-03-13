---
name: retro
description: Weekly product retrospective. Analyzes what shipped, backlog health, and work patterns using project artifacts (CHANGELOG, BACKLOG, features, ACTIVE.md) and git history. Run at the end of a work week to track product momentum.
allowed-tools:
  - Bash
  - Read
  - Glob
  - Write
---

# /retro — Weekly Product Retrospective

A lightweight retrospective built around your actual workflow artifacts. Focused on product progress and momentum, not raw engineering metrics.

## Arguments

- `/retro` — default: last 7 days
- `/retro 14d` — last 14 days
- `/retro 30d` — last 30 days
- `/retro compare` — this period vs prior same-length period

Invalid argument → show usage and stop:
```
Usage: /retro [window]
  /retro        — last 7 days (default)
  /retro 14d    — last 14 days
  /retro 30d    — last 30 days
  /retro compare — compare this period vs prior period
```

---

## Instructions

Parse the argument. Default to 7 days. Run all data gathering steps in parallel where possible.

---

### Step 1 — Read project artifacts

Read these files:
- `CHANGELOG.md` — shipped features and tasks
- `.claude/BACKLOG.md` — current backlog state
- `.claude/ACTIVE.md` — what's currently in flight

Glob for feature and task folders created or modified in the window:
```bash
find docs/features -name "PLAN.md" -newer <N-days-ago-sentinel> 2>/dev/null
find docs/features -name "PRD.md" -newer <N-days-ago-sentinel> 2>/dev/null
find docs/tasks -name "TODO.md" -newer <N-days-ago-sentinel> 2>/dev/null
```

To get the date sentinel for file comparisons:
```bash
# For 7 days: date -v-7d +%Y%m%d%H%M%S (macOS) or date -d "7 days ago" +%Y%m%d%H%M%S (Linux)
# Use a temp file as the reference: touch -t <sentinel> /tmp/retro_since && find ... -newer /tmp/retro_since
touch -t $(date -v-${WINDOW}d +%Y%m%d%H%M%S 2>/dev/null || date -d "${WINDOW} days ago" +%Y%m%d%H%M%S) /tmp/retro_since 2>/dev/null || true
```

---

### Step 2 — Git summary

```bash
# Commits in window
git log --oneline --since="${WINDOW} days ago" origin/main 2>/dev/null || git log --oneline --since="${WINDOW} days ago"

# Files changed most frequently
git log --since="${WINDOW} days ago" --format="" --name-only | grep -v '^$' | sort | uniq -c | sort -rn | head -15

# Streak: consecutive days with commits (full history)
git log --format="%ad" --date=format:"%Y-%m-%d" | sort -u | awk '
  BEGIN { streak=0; prev="" }
  {
    cmd = "date -d \"" $1 " +1 day\" +%Y-%m-%d 2>/dev/null || date -v+1d -jf %Y-%m-%d " $1 " +%Y-%m-%d 2>/dev/null"
    cmd | getline next_day; close(cmd)
    if (NR==1) { streak=1; prev=$1 }
    else if ($1 == prev_expected) { streak++; prev=$1 }
    else { exit }
    prev_expected = next_day
  }
  END { print streak }
' 2>/dev/null || echo "streak unavailable"

# Simple stat for the window
git diff --shortstat $(git log --oneline --since="${WINDOW} days ago" | tail -1 | awk '{print $1}')^..HEAD 2>/dev/null | head -1
```

If zero commits in window, note it and suggest a longer window.

---

### Step 3 — Compute metrics

Extract from CHANGELOG.md entries dated within the window:
- Features shipped (entries starting with `## [feature]` or similar)
- Tasks shipped (entries starting with `## [task]` or similar)
- Bugs fixed

Count from BACKLOG.md:
- Total items remaining: High / Medium / Icebox counts
- New items added in window (if detectable from git history on BACKLOG.md)

From docs/features and docs/tasks:
- PRDs produced in window (completed features with a PRD.md)
- Features started (PLAN.md created) vs features finished (PRD.md created)

Build this summary table:

| Metric | Value |
|--------|-------|
| Features shipped | N |
| Tasks shipped | N |
| Bugs fixed | N |
| PRDs written | N |
| Features started | N |
| Commits to main | N |
| Backlog: High | N items |
| Backlog: Medium | N items |
| Backlog: Icebox | N items |
| Currently in flight | [name or "nothing"] |
| Shipping streak | N days |

---

### Step 4 — Backlog health

Analyze `.claude/BACKLOG.md`:

- **Backlog shape**: What's the ratio of High to Medium to Icebox? Is High getting cleared, or are items accumulating?
- **Staleness signal**: Are the same items sitting in High across retros? (Check prior retro JSON if available.)
- **Focus signal**: Is work concentrated in one area (AEO, Reviews, etc.) or scattered?

Flag if:
- High priority has 5+ items (backlog pressure)
- Icebox is growing while High items sit untouched

---

### Step 5 — What shipped (from CHANGELOG)

Parse CHANGELOG.md for entries in the window. For each shipped item:
- Name and type (feature / task / bug)
- One-line impact summary (infer from the changelog entry)

If CHANGELOG is empty or has no entries in the window, note that and check git log commit messages for signal.

---

### Step 6 — Hotspot analysis (lightweight)

From the most-changed files list (Step 2):

- Which areas of the codebase got the most attention? (group by top-level directory)
- Any file churned 4+ times? Flag as a potential refactor candidate.
- Is the churn concentrated (good — deep focused work) or scattered?

---

### Step 7 — Load history and compare

```bash
ls -t .claude/retros/*.json 2>/dev/null | head -5
```

If prior retros exist, read the most recent one. Show a trends table:

```
                    Last        Now         Delta
Features shipped:    2     →     3          ↑1
Tasks shipped:       5     →     2          ↓3
Commits:            18     →    24          ↑33%
Backlog High:        4     →     3          ↓1 (clearing)
Streak:             12     →    19          ↑7d
```

If no prior retros: "First retro recorded — run again next week to see trends."

---

### Step 8 — Save snapshot

```bash
mkdir -p .claude/retros
```

Save to `.claude/retros/YYYY-MM-DD-N.json`:

```json
{
  "date": "2026-03-14",
  "window": "7d",
  "metrics": {
    "features_shipped": 2,
    "tasks_shipped": 3,
    "bugs_fixed": 1,
    "prds_written": 1,
    "commits": 24,
    "backlog_high": 3,
    "backlog_medium": 5,
    "backlog_icebox": 4,
    "in_flight": "aeo-leaderboard-v2",
    "streak_days": 19
  },
  "tweetable": "Week of Mar 8: 2 features + 3 tasks shipped, 24 commits, backlog clearing. Streak: 19d"
}
```

---

### Step 9 — Write the narrative

Structure the output as follows. Keep total output to **800–1200 words**. Anchor every observation in actual commits, changelog entries, or backlog items — no generic praise.

---

**[Tweetable summary — one line, before everything else]**
```
Week of Mar 8: 2 features shipped, 3 tasks done, 24 commits. Streak: 19d. In flight: AEO leaderboard v2.
```

## Product Retro: [date range]

### This Week at a Glance
*(summary table from Step 3)*

*(2–3 sentences: what was the dominant theme this week? Was this a shipping week, a plumbing week, a planning week?)*

### Trends vs Last Retro
*(from Step 7 — skip if first retro)*

### What Shipped
*(from Step 5)*

For each item: name, type, and one sentence on why it matters.
If nothing shipped: be direct about it — what was in flight instead?

### Backlog Health
*(from Step 4)*

Is the backlog getting clearer or murkier? Are the right things prioritized? Any items that have been in High for 2+ retros without moving?

### Code Focus
*(from Step 6)*

Where did the work actually land in the codebase? Is that aligned with the current product priority?

### In Flight
What's currently active (from ACTIVE.md)? What's the expected completion?

### 3 Wins
The three most meaningful things from this window. Specific. Anchored in what actually happened. Skip anything generic.

### 2 Things to Sharpen
Not criticism — pattern recognition. What did the data reveal that's worth adjusting? Each must be anchored in a specific observation from the retro data, not a general principle.

### Next Week Focus
Based on backlog state and what's in flight: what are the 1–2 highest-leverage things to prioritize next week? Keep it concrete.

---

## Compare Mode

When running `/retro compare`:
1. Gather metrics for current window (last 7d)
2. Gather metrics for prior same-length window using `--since="14 days ago" --until="7 days ago"`
3. Show a side-by-side table: Last period | This period | Delta
4. Write a 2–3 sentence narrative on the biggest shift
5. Save only the current window to `.claude/retros/`

---

## Rules

- All narrative output goes to the conversation. The only file written is `.claude/retros/` JSON.
- If CHANGELOG is empty or sparse, fall back to git commit messages for shipped signal
- If ACTIVE.md is empty, note "nothing in flight" explicitly
- Round all percentages to nearest whole number
- If window has zero commits and no CHANGELOG entries, say so clearly and suggest `/retro 14d`
- Do not read docs/SPEC.md — this skill is self-contained