#!/usr/bin/env bash
# Claude Code SessionStart hook: loads the second brain's "hot" context.
# Runs when a session starts, resumes, is cleared or is compacted; whatever it prints
# enters the AI's context.
#
# Usage: session-start.sh [brain-folder]     (the hook's JSON arrives on stdin)
# With no brain configured (see lib.sh) it prints nothing — the plugin may be installed
# before the brain exists.
#
# Optional variable: CONTEXT_KEEPER_MAX_BYTES, cap on what is loaded
# (default 8000; Claude Code accepts up to 10,000 characters).

set -u
. "$(dirname "$0")/lib.sh"
ck_resolve_brain "${1:-}" || exit 0
ck_load_names
MAX_BYTES="${CONTEXT_KEEPER_MAX_BYTES:-8000}"

input="$(cat 2>/dev/null || true)"
source_event="$(printf '%s' "$input" | sed -n 's/.*"source"[[:space:]]*:[[:space:]]*"\([a-z]*\)".*/\1/p' | head -n1)"

{
  ck_msg title "$BRAIN"; echo
  if [ "$source_event" = "compact" ] && [ -n "$NOW_FILE" ]; then
    ck_msg compacted "$NOW_FILE"; echo
  fi
  if [ -n "$ROOT_FILE" ]; then
    ck_msg rules "$BRAIN/$ROOT_FILE"; echo
  fi
  echo

  if [ -n "$NOW_FILE" ]; then
    echo "## $NOW_FILE"
    cat "$BRAIN/$NOW_FILE"
    echo
  fi

  if [ -n "$JOURNAL_DIR" ]; then
    latest="$(ls -1 "$BRAIN/$JOURNAL_DIR/" 2>/dev/null | grep -E '^[0-9]{4}-[0-9]{2}-[0-9]{2}\.md$' | sort | tail -n1)"
    if [ -n "$latest" ]; then
      ck_msg journal "$JOURNAL_DIR/$latest"; echo
      tail -n 25 "$BRAIN/$JOURNAL_DIR/$latest"
    fi
  fi
} | head -c "$MAX_BYTES"

exit 0
