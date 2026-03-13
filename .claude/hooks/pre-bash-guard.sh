#!/usr/bin/env bash
# .claude/hooks/pre-bash-guard.sh
# Fires before every Bash tool call.
# Blocks destructive commands and enforces project conventions.

set -euo pipefail

CMD=$(jq -r '.tool_input.command // ""' 2>/dev/null)
[[ -z "$CMD" ]] && exit 0

# ─── Hard blocks — destructive or irreversible commands ──────────────────────

# Recursive force-delete from root or project root
if echo "$CMD" | grep -Eiq 'rm\s+-rf\s+(/|\./)?\s*$'; then
  echo "BLOCKED: 'rm -rf' on root or project root is not allowed." >&2
  exit 2
fi

if echo "$CMD" | grep -Eiq 'rm\s+-rf\s+/[a-z]'; then
  echo "BLOCKED: 'rm -rf' on absolute paths is not allowed. Delete specific files instead." >&2
  exit 2
fi

# Hard git resets — wipe uncommitted work
if echo "$CMD" | grep -Eiq 'git\s+reset\s+--hard'; then
  echo "BLOCKED: 'git reset --hard' will destroy uncommitted work. Use 'git stash' first, or confirm with the user." >&2
  exit 2
fi

# Force-push — rewrites remote history
if echo "$CMD" | grep -Eiq 'git\s+push\s+.*--force'; then
  echo "BLOCKED: Force-pushing is not allowed. If you need to amend history, confirm with the user first." >&2
  exit 2
fi

# Dropping Supabase schema — catastrophic
if echo "$CMD" | grep -Eiq 'supabase\s+db\s+reset'; then
  echo "BLOCKED: 'supabase db reset' drops and recreates the schema. This must be approved by the user explicitly." >&2
  exit 2
fi

# ─── Convention enforcement ───────────────────────────────────────────────────

# Enforce pnpm over npm (pnpm-lock.yaml is the lockfile for this project)
if echo "$CMD" | grep -Eq '\bnpm\s+(install|i|add|run|exec)\b' && [ -f "pnpm-lock.yaml" ]; then
  echo "BLOCKED: This project uses pnpm. Replace 'npm' with 'pnpm' (e.g. 'pnpm install', 'pnpm run <script>')." >&2
  exit 2
fi

# ─── Soft warnings — AEO script execution without dry-run ────────────────────
# These scripts are in the "Always Flag Before Touching" list.
# Require a --dry-run flag or user confirmation comment in the command.

DESTRUCTIVE_SCRIPTS=(

)

for SCRIPT in "${DESTRUCTIVE_SCRIPTS[@]}"; do
  if echo "$CMD" | grep -q "$SCRIPT"; then
    if ! echo "$CMD" | grep -q '\-\-dry-run'; then
      echo "BLOCKED: '$SCRIPT' is a destructive script. Add '--dry-run' first to preview changes, then confirm with the user before running without it." >&2
      exit 2
    fi
  fi
done

exit 0