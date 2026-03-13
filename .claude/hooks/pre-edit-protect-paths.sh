#!/usr/bin/env bash
# .claude/hooks/pre-edit-protect-paths.sh
# Fires before every Edit, MultiEdit, or Write.
# Exit 2 + message on stderr = blocked (Claude reads the reason and adjusts).
# Exit 0 = allow.

set -euo pipefail

FILE_PATH=$(jq -r '.tool_input.file_path // empty' 2>/dev/null)
[[ -z "$FILE_PATH" ]] && exit 0

# ─── Hard blocks — Claude cannot edit these without explicit user instruction ───

# Environment files — should never be written by Claude
if echo "$FILE_PATH" | grep -Eq '(^|/)\.env($|\.)'; then
  echo "BLOCKED: .env files must not be edited by Claude. Edit manually or ask the user to update them." >&2
  exit 2
fi

# Package lockfile — only package managers should touch this
if echo "$FILE_PATH" | grep -Eq '(^|/)pnpm-lock\.yaml$'; then
  echo "BLOCKED: pnpm-lock.yaml is managed by pnpm. Run 'pnpm install' instead of editing directly." >&2
  exit 2
fi

# Supabase migration files — irreversible and schema-critical
if echo "$FILE_PATH" | grep -Eq '(^|/)supabase/migrations/'; then
  echo "BLOCKED: Migration files are irreversible. Create a new migration file instead of editing an existing one." >&2
  exit 2
fi

# ─── Soft warnings — Claude must explain itself before editing these ──────────
# These are the "Always Flag Before Touching" files from CLAUDE.md.
# Exit 2 forces Claude to surface the intent to the user before proceeding.
# Remove a file from this list once Claude has been given explicit approval.

CRITICAL_FILES=(

)

BASENAME=$(basename "$FILE_PATH")
for CRITICAL in "${CRITICAL_FILES[@]}"; do
  if [[ "$BASENAME" == "$CRITICAL" ]]; then
    echo "BLOCKED: '$CRITICAL' is a flagged critical file. State your exact intent and confirm with the user before editing." >&2
    exit 2
  fi
done

exit 0