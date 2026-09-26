#!/usr/bin/env bash
# Second brain health check. Changes nothing: it only reports.
#
# Usage: brain-lint.sh [brain-folder] [days-until-stale]
# Without a folder, uses ~/.context-keeper/config.

set -u
. "$(dirname "$0")/lib.sh"
DAYS="${2:-60}"
MAX_ROOT_LINES=150
MAX_NOW_LINES=60
INBOX_DAYS=14

if ! ck_resolve_brain "${1:-}"; then
  echo "Usage: brain-lint.sh [brain-folder] [days]  (without a folder, uses ~/.context-keeper/config)" >&2
  exit 1
fi
ck_load_names
cd "$BRAIN" || exit 1

issues=0
section() { echo; echo "## $1"; }
warn() { echo "- $1"; issues=$((issues + 1)); }

# Lists the notes, skipping system folders and templates.
notes() {
  find . -type f -name '*.md' \
    -not -path './.git/*' -not -path './.obsidian/*' -not -path './.trash/*' \
    -not -path './.context-keeper/*' -not -path './Templates/*' -print0
}

echo "# Second brain check: $BRAIN"
echo "Date: $(date +%F)"

# 1. Size of the hot context
section "Hot context (loaded in every session)"
if [ -z "$ROOT_FILE" ]; then
  warn "No root file found (BRAIN.md, CEREBRO.md, Claude.md or AGENTS.md)."
else
  lines=$(wc -l < "$ROOT_FILE" | tr -d ' ')
  [ "$lines" -gt "$MAX_ROOT_LINES" ] && warn "$ROOT_FILE has $lines lines (recommended: up to $MAX_ROOT_LINES)."
  echo "- $ROOT_FILE: $lines lines"
fi
if [ -n "$NOW_FILE" ]; then
  lines=$(wc -l < "$NOW_FILE" | tr -d ' ')
  [ "$lines" -gt "$MAX_NOW_LINES" ] && warn "$NOW_FILE has $lines lines (recommended: up to $MAX_NOW_LINES)."
  echo "- $NOW_FILE: $lines lines"
else
  warn "No now file (NOW.md or AGORA.md): the AI has nowhere to read where it stopped."
fi

# 2. Frontmatter and stale notes
section "Frontmatter and stale notes (older than $DAYS days)"
cutoff="$(date -d "-$DAYS days" +%F 2>/dev/null || date -v-"$DAYS"d +%F 2>/dev/null || echo "")"
total=0
while IFS= read -r -d '' f; do
  total=$((total + 1))
  case "$f" in "./$JOURNAL_DIR"/*|./Archive/*|./Arquivo/*|./4-Archive/*|./4-Arquivo/*|"./$ROOT_FILE") continue ;; esac
  if [ "$(head -n1 "$f" | tr -d '\r')" != "---" ]; then
    warn "No frontmatter: ${f#./}"
    continue
  fi
  updated="$(grep -m1 -E '^(updated|atualizado):' "$f" | sed -E 's/^[a-z]+:[[:space:]]*([0-9]{4}-[0-9]{2}-[0-9]{2}).*/\1/')"
  if [ -n "$cutoff" ] && [ -n "$updated" ] && [[ "$updated" < "$cutoff" ]]; then
    warn "Stale since $updated: ${f#./}"
  fi
done < <(notes)
echo "- Notes checked: $total"

# 3. Inbox
section "Inbox (items older than $INBOX_DAYS days)"
if [ -d Inbox ]; then
  while IFS= read -r -d '' f; do
    warn "Waiting for triage: ${f#./}"
  done < <(find ./Inbox -type f -mtime +"$INBOX_DAYS" -print0)
fi

# 4. Broken links
section "Broken links"
existing="$(find . -type f -not -path './.git/*' -not -path './.obsidian/*' | sed 's#.*/##; s#\.md$##' | sort -u)"
# Collected in a variable (no temp file), so the check never writes outside the brain.
links_report="$(while IFS= read -r -d '' f; do
  dir="$(dirname "$f")"
  # Skip examples inside code blocks and `inline code`.
  text="$(awk '/^[[:space:]]*```/ { inside = !inside; next } !inside' "$f" | sed 's/`[^`]*`//g')"

  # Wikilinks [[Note]]: looked up by name in any folder, like Obsidian does.
  printf '%s\n' "$text" | grep -o '\[\[[^]]*\]\]' 2>/dev/null | sort -u | while IFS= read -r link; do
    target="${link#[[}"; target="${target%]]}"
    target="${target%%|*}"; target="${target%%#*}"; target="${target##*/}"; target="${target%.md}"
    [ -z "$target" ] && continue
    case "$target" in *'{{'*) continue ;; esac
    if ! printf '%s\n' "$existing" | grep -Fxq "$target"; then
      echo "- ${f#./} → [[${target}]]"
    fi
  done

  # Markdown links [text](path): the path is relative to the note's folder.
  printf '%s\n' "$text" | grep -oE '\]\([^)[:space:]]+\)' 2>/dev/null | sort -u | while IFS= read -r link; do
    target="${link#](}"; target="${target%)}"
    case "$target" in http://*|https://*|mailto:*|'#'*|*'{{'*) continue ;; esac
    target="${target%%#*}"; target="$(printf '%s' "$target" | sed 's/%20/ /g')"
    [ -z "$target" ] && continue
    [ -e "$dir/$target" ] || echo "- ${f#./} → ($target)"
  done
done < <(notes))"
if [ -n "$links_report" ]; then
  printf '%s
' "$links_report"
  issues=$((issues + $(printf '%s
' "$links_report" | wc -l)))
fi

# 5. Possible secrets (shows only file and line, never the value)
section "Possible secrets"
grep -rnIE \
  --exclude-dir=.git --exclude-dir=.obsidian --exclude-dir=.context-keeper \
  '((api[_-]?key|secret|senha|password|passwd|token)[[:space:]]*[:=][[:space:]]*[^[:space:]{}]{8,})|(sk-[A-Za-z0-9_-]{20,})|(ghp_[A-Za-z0-9]{20,})|(AKIA[0-9A-Z]{16})' \
  . 2>/dev/null | cut -d: -f1,2 | while IFS= read -r hit; do
    echo "- Check: ${hit#./}"
  done

section "Summary"
echo "- Issues found (not counting secrets): $issues"
exit 0
