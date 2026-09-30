#!/usr/bin/env bash
# Claude Code Stop hook: asks for a second brain checkpoint when the context has grown a lot
# since the last save — before compaction summarizes (and loses) it.
#
# Usage: checkpoint-stop.sh [brain-folder]     (the hook's JSON arrives on stdin)
# Optional variable: CONTEXT_KEEPER_CHECKPOINT_TOKENS, context growth that triggers the
# request (default 50000).
#
# How it measures: the context size in tokens reported by the last response in the transcript
# ("usage": input + cache read + cache creation). Transcript bytes are a poor proxy (tool output
# and metadata inflate them), so they are used only as an estimate when no usage is found.
#
# How it decides:
#   - keeps, per session, the context size at the last checkpoint (.context-keeper/state/);
#   - if the now file (NOW.md/AGORA.md) changed after that, assumes a checkpoint happened and
#     only moves the baseline; after a compaction the context shrinks and the baseline follows;
#   - if the context grew more than the limit, asks for a checkpoint once;
#   - never asks twice in a row (stop_hook_active), so it cannot loop.

set -u
. "$(dirname "$0")/lib.sh"
ck_resolve_brain "${1:-}" || exit 0
ck_load_names
LIMIT="${CONTEXT_KEEPER_CHECKPOINT_TOKENS:-50000}"

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

# Context size in tokens from the last "usage" block; fallback: ~30 transcript bytes per token.
usage="$(tail -c 400000 "$transcript" | grep -o '"usage":{[^}]*}' | tail -n1)"
token_field() {
  value="$(printf '%s' "$usage" | sed -n "s/.*\"$1\":\([0-9]*\).*/\1/p")"
  printf '%s' "${value:-0}"
}
if [ -n "$usage" ]; then
  size=$(( $(token_field input_tokens) + $(token_field cache_read_input_tokens) + $(token_field cache_creation_input_tokens) ))
else
  size=$(( $(wc -c < "$transcript" | tr -d '[:space:]') / 30 ))
fi
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

# The context shrank (compaction or /clear): follow it down.
if [ "$size" -lt "$baseline" ]; then
  echo "$size" > "$baseline_file"
  exit 0
fi

if [ $((size - baseline)) -ge "$LIMIT" ]; then
  echo "$size" > "$baseline_file"
  root_path="$(printf '%s' "$BRAIN/${ROOT_FILE:-BRAIN.md}" | sed 's/\\/\\\\/g; s/"/\\"/g')"
  message="$(ck_msg checkpoint "$root_path")"
  printf '{"hookSpecificOutput":{"hookEventName":"Stop","additionalContext":"%s"}}\n' "$message"
fi

# Clean up state from old sessions.
find "$state_dir" -name '*.checkpoint' -mtime +30 -delete 2>/dev/null
exit 0
