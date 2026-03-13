#!/usr/bin/env bash
# .claude/hooks/post-edit-quality.sh
# Fires after every successful Edit, MultiEdit, or Write.
# Runs ESLint and TypeScript type-check on the changed file.
# Output goes to stdout — Claude reads it and can self-correct.

set -uo pipefail

FILE_PATH=$(jq -r '.tool_input.file_path // empty' 2>/dev/null)
[[ -z "$FILE_PATH" ]] && exit 0

# Only run on TypeScript/TSX files
if ! echo "$FILE_PATH" | grep -Eq '\.(ts|tsx)$'; then
  exit 0
fi

# Skip test files — vitest handles those separately
if echo "$FILE_PATH" | grep -Eq '\.(test|spec)\.(ts|tsx)$'; then
  exit 0
fi

# Skip if file no longer exists (e.g. was a temp file)
[[ ! -f "$FILE_PATH" ]] && exit 0

ISSUES=""
EXIT_CODE=0

# ─── ESLint ──────────────────────────────────────────────────────────────────
if command -v pnpm &>/dev/null && [ -f "package.json" ]; then
  ESLINT_OUT=$(pnpm exec eslint "$FILE_PATH" --format compact --max-warnings 0 2>&1) || true
  if [[ -n "$ESLINT_OUT" && "$ESLINT_OUT" != *"0 problems"* ]]; then
    ISSUES+="ESLint issues in $FILE_PATH:\n$ESLINT_OUT\n\n"
    EXIT_CODE=1
  fi
fi

# ─── TypeScript type-check ───────────────────────────────────────────────────
# Uses tsc in noEmit mode. Scoped to the changed file only for speed.
if command -v pnpm &>/dev/null && [ -f "tsconfig.json" ]; then
  TSC_OUT=$(pnpm exec tsc --noEmit --skipLibCheck 2>&1) || true
  # Filter output to lines mentioning this file to keep feedback focused
  BASENAME=$(basename "$FILE_PATH")
  TSC_FILTERED=$(echo "$TSC_OUT" | grep "$BASENAME" || true)
  if [[ -n "$TSC_FILTERED" ]]; then
    ISSUES+="TypeScript errors in $FILE_PATH:\n$TSC_FILTERED\n\n"
    EXIT_CODE=1
  fi
fi

# ─── Report ──────────────────────────────────────────────────────────────────
if [[ -n "$ISSUES" ]]; then
  echo -e "Quality check failed after editing $FILE_PATH. Please fix before moving on:\n"
  echo -e "$ISSUES"
  # Exit 1 = non-blocking error shown to user (doesn't block Claude, but Claude reads it)
  exit 1
fi

exit 0