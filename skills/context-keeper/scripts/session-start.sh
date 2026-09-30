#!/usr/bin/env bash
# Claude Code SessionStart hook. Whatever it prints enters the AI's context.
#
#   - Every time: brings the map in the root file (CLAUDE.md) up to date with the real folders.
#     If the map changed, it prints the new map, because Claude Code may have loaded the old
#     root file already.
#   - Only after a compaction: prints the now file and the latest journal entry, so the AI
#     resumes the work that was in progress. At a normal start nothing else is loaded: the root
#     file stays the only, neutral entry point and no project is favored.
#
# Usage: session-start.sh [brain-folder]     (the hook's JSON arrives on stdin)
# With no brain configured (see lib.sh) it prints nothing — the plugin may be installed
# before the brain exists.
#
# Optional variable: CONTEXT_KEEPER_MAX_BYTES, cap on what is printed
# (default 8000; Claude Code accepts up to 10,000 characters).

set -u
# On Windows the PowerShell version of this hook runs instead (see hooks/hooks.json), so the
# bash version steps aside when started as a hook there. Run by hand, it works everywhere.
if [ "${CONTEXT_KEEPER_HOOK:-}" = "1" ]; then
  case "$(uname -s 2>/dev/null)" in MINGW*|MSYS*|CYGWIN*) exit 0 ;; esac
fi

. "$(dirname "$0")/lib.sh"
ck_resolve_brain "${1:-}" || exit 0
ck_load_names
MAX_BYTES="${CONTEXT_KEEPER_MAX_BYTES:-8000}"

input="$(cat 2>/dev/null || true)"
source_event="$(printf '%s' "$input" | sed -n 's/.*"source"[[:space:]]*:[[:space:]]*"\([a-z]*\)".*/\1/p' | head -n1)"

map_report="$(bash "$(dirname "$0")/update-map.sh" "$BRAIN" 2>/dev/null)"

{
  case "$map_report" in
    *"map: updated"*)
      ck_msg title "$BRAIN"; echo
      ck_msg map "$ROOT_FILE"; echo
      tr -d '\r' < "$BRAIN/$ROOT_FILE" | awk '/<!-- context-keeper:map:start -->/{on=1; next} /<!-- context-keeper:map:end -->/{on=0} on'
      missing="$(printf '%s\n' "$map_report" | sed -n 's/^map: without description://p')"
      [ -n "$missing" ] && { ck_msg nodesc "$missing"; echo; }
      echo
      ;;
  esac

  if [ "$source_event" = "compact" ]; then
    case "$map_report" in *"map: updated"*) ;; *) ck_msg title "$BRAIN"; echo ;; esac
    if [ -n "$NOW_FILE" ]; then
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
  fi
} | head -c "$MAX_BYTES"

exit 0
