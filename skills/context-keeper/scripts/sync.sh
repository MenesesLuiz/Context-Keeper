#!/usr/bin/env bash
# Syncs the brain with its git remote (a private GitHub repository). No AI, no tokens.
#
# Usage: sync.sh [brain-folder] [pull|push|both|visibility]     (default: both)
#   pull        brings changes made on another machine (rebase, local edits kept aside meanwhile)
#   push        checks for secrets, commits everything, pulls, then pushes
#   both        pull, then push (what /context-keeper:sync runs)
#   visibility  asks GitHub, without credentials, whether the repository is public (warns if so)
#
# Safe by design:
#   - runs only when .context-keeper/config.json has "sync": { "enabled": true };
#   - never waits for a password: if git is not authenticated, it fails and says so;
#   - never resolves a conflict on its own: it undoes the attempt and reports it;
#   - never pushes a note with a possible secret (same pattern as brain-lint.sh).
# Failures go to .context-keeper/state/sync.log; the last one also to state/sync.failed, which
# the start hook reports to the AI. A later success removes sync.failed.

set -u
. "$(dirname "$0")/lib.sh"

brain_arg=""; action="both"
for a in "$@"; do
  case "$a" in pull|push|both|visibility) action="$a" ;; *) brain_arg="$a" ;; esac
done
ck_resolve_brain "$brain_arg" || exit 0
ck_load_names

state_dir="$BRAIN/.context-keeper/state"
mkdir -p "$state_dir" 2>/dev/null
log_file="$state_dir/sync.log"
fail_file="$state_dir/sync.failed"

note() { printf '%s %s\n' "$(date '+%F %T')" "$1" >> "$log_file"; }
ok()   { note "ok: $1"; rm -f "$fail_file"; echo "sync: $1"; }
fail() { note "failed: $1"; printf '%s\n' "$1" > "$fail_file"; echo "sync: failed: $1"; exit 1; }

ck_sync_enabled || { echo "sync: off (enable it in .context-keeper/config.json)"; exit 0; }
[ -d "$BRAIN/.git" ] || fail "the brain is not a git repository"

# Never hang on a credential prompt; give up on a slow network.
export GIT_TERMINAL_PROMPT=0 GCM_INTERACTIVE=never
g() {
  if command -v timeout >/dev/null 2>&1; then timeout 30 git -C "$BRAIN" "$@"; else git -C "$BRAIN" "$@"; fi
}

remote="$(git -C "$BRAIN" remote | head -n1)"
[ -n "$remote" ] || fail "no remote configured (add the GitHub repository first)"
# symbolic-ref also works before the first commit (a brand-new brain), unlike rev-parse.
branch="$(git -C "$BRAIN" symbolic-ref --short -q HEAD 2>/dev/null)"
[ -n "$branch" ] || fail "not on a branch"

do_visibility() {
  url="$(git -C "$BRAIN" remote get-url "$remote")"
  repo="$(printf '%s' "$url" | sed -nE 's#.*github\.com[:/]([^/]+/[^/.]+)(\.git)?$#\1#p')"
  [ -n "$repo" ] || { echo "sync: visibility unknown (not a GitHub address)"; return 0; }
  code="$(curl -s -o /dev/null -w '%{http_code}' --max-time 10 "https://api.github.com/repos/$repo" 2>/dev/null)"
  case "$code" in
    200) echo "sync: WARNING: github.com/$repo is PUBLIC. Make it private before syncing personal notes."; return 1 ;;
    404) echo "sync: github.com/$repo is private (or does not exist yet)" ;;
    *)   echo "sync: could not check the visibility of github.com/$repo" ;;
  esac
}

do_pull() {
  if ! g fetch --quiet "$remote" 2>/dev/null; then
    # At session start (CONTEXT_KEEPER_SYNC_SOFT=1) being offline is normal: log it and move on.
    if [ "${CONTEXT_KEEPER_SYNC_SOFT:-}" = "1" ]; then note "skipped: could not reach the remote"; echo "sync: skipped (offline)"; return 0; fi
    fail "could not reach the remote (offline, or git is not signed in to GitHub)"
  fi
  git -C "$BRAIN" rev-parse --verify --quiet "$remote/$branch" >/dev/null || { ok "remote is empty, nothing to pull"; return 0; }
  before="$(git -C "$BRAIN" rev-parse HEAD 2>/dev/null)"
  if ! g rebase --quiet --autostash "$remote/$branch" >/dev/null 2>&1; then
    g rebase --abort >/dev/null 2>&1
    fail "conflict with changes from another machine; nothing was overwritten, resolve it with git in $BRAIN"
  fi
  after="$(git -C "$BRAIN" rev-parse HEAD)"
  if [ "$before" != "$after" ]; then
    changed="$(git -C "$BRAIN" diff --name-only "$before" "$after" 2>/dev/null | head -n 10 | tr '\n' ' ')"
    ok "pulled: $changed"
  else
    ok "already up to date"
  fi
}

do_push() {
  # Files that would go up: changed, staged or new notes.
  files="$(git -C "$BRAIN" status --porcelain -uall | sed -E 's/^...//; s/.* -> //; s/^"(.*)"$/\1/' | grep -E '\.md$')"
  if [ -n "$files" ]; then
    hits="$(cd "$BRAIN" && printf '%s\n' "$files" | while IFS= read -r f; do
      [ -f "$f" ] && grep -nIE "$CK_SECRET_RE" "$f" 2>/dev/null | cut -d: -f1 | sed "s#^#$f:#"
    done)"
    [ -z "$hits" ] || fail "push blocked: possible secret in $(printf '%s' "$hits" | head -n 3 | tr '\n' ' ')- remove it and run /context-keeper:sync"
  fi
  if [ -n "$(git -C "$BRAIN" status --porcelain)" ]; then
    git -C "$BRAIN" add -A >/dev/null 2>&1
    host="$(hostname 2>/dev/null || echo "${COMPUTERNAME:-machine}")"
    git -C "$BRAIN" commit --quiet -m "context-keeper: sync $(date '+%F %H:%M') ($host)" >/dev/null 2>&1 ||
      fail "commit failed (set git user.name and user.email on this machine)"
  fi
  do_pull >/dev/null
  if git -C "$BRAIN" rev-parse --verify --quiet "$remote/$branch" >/dev/null &&
     [ "$(git -C "$BRAIN" rev-list --count "$remote/$branch..HEAD")" = "0" ]; then
    ok "nothing to push"; return 0
  fi
  g push --quiet -u "$remote" "$branch" >/dev/null 2>&1 || fail "push failed (offline, or git is not signed in to GitHub)"
  ok "pushed"
}

case "$action" in
  visibility) do_visibility ;;
  pull) do_pull ;;
  push) do_push ;;
  both) do_pull; do_push ;;
esac
exit 0
