#!/usr/bin/env bash
# Claude Code Stop hook: asks for a second brain checkpoint when the conversation has
# grown a lot since the last save — before compaction summarizes (and loses) the context.
#
# Usage: checkpoint-stop.sh [brain-folder]     (the hook's JSON arrives on stdin)
# Optional variable: CONTEXT_KEEPER_CHECKPOINT_BYTES, transcript growth that triggers the
# request (default 300000).
#
# How it decides:
#   - keeps, per session, the transcript size at the last checkpoint (.context-keeper/state/);
#   - if the now file (NOW.md/AGORA.md) changed after that, assumes a checkpoint happened and
#     only moves the baseline;
#   - if the transcript grew more than the limit, asks for a checkpoint once;
#   - never asks twice in a row (stop_hook_active), so it cannot loop.

set -u
. "$(dirname "$0")/lib.sh"
ck_resolve_brain "${1:-}" || exit 0
ck_load_names
LIMIT="${CONTEXT_KEEPER_CHECKPOINT_BYTES:-300000}"

input="$(cat 2>/dev/null || true)"

# The AI is already continuing because of a Stop hook: let it stop.
printf '%s' "$input" | grep -Eq '"stop_hook_active"[[:space:]]*:[[:space:]]*true' && exit 0

field() {
  printf '%s' "$input" | sed -n "s/.*\"$1\"[[:space:]]*:[[:space:]]*\"\([^\"]*\)\".*/\1/p" | head -n1
}

session="$(field session_id | tr -cd 'A-Za-z0-9_-')"
# On Windows the path arrives with escaped backslashes (C:\\Users\\...).
transcript="$(field transcript_path | sed 's/\\\\/\//g')"
[ -n "$session" ] && [ -f "$transcript" ] || exit 0

size="$(wc -c < "$transcript" | tr -d '[:space:]')"
state_dir="$BRAIN/.context-keeper/state"
mkdir -p "$state_dir" 2>/dev/null || exit 0
baseline_file="$state_dir/$session.checkpoint"

# First stop of the session, or a checkpoint happened since last time: only record the baseline.
if [ ! -f "$baseline_file" ] || { [ -n "$NOW_FILE" ] && [ "$BRAIN/$NOW_FILE" -nt "$baseline_file" ]; }; then
  echo "$size" > "$baseline_file"
  exit 0
fi

baseline="$(tr -cd '0-9' < "$baseline_file")"
baseline="${baseline:-0}"

if [ $((size - baseline)) -ge "$LIMIT" ]; then
  echo "$size" > "$baseline_file"
  root_path="$(printf '%s' "$BRAIN/${ROOT_FILE:-BRAIN.md}" | sed 's/\\/\\\\/g; s/"/\\"/g')"
  message="$(ck_msg checkpoint "$root_path")"
  printf '{"hookSpecificOutput":{"hookEventName":"Stop","additionalContext":"%s"}}\n' "$message"
fi

# Clean up state from old sessions.
find "$state_dir" -name '*.checkpoint' -mtime +30 -delete 2>/dev/null
exit 0
