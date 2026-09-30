#!/usr/bin/env bash
# Rebuilds the map section of the brain's root file (CLAUDE.md) from the real folders, so the
# AI can find any area or project by reading one file instead of exploring folders.
#
# Usage: update-map.sh [brain-folder] [--check]
#   (no flag)  rewrites only the part between the map markers and reports what changed
#   --check    changes nothing; exits 1 if the map is outdated or the markers are missing
#
# The map goes two levels deep (Area/Project/). Each line says what the folder is, taken from
# the "descricao:" or "description:" field in the frontmatter of the folder's index note
# (Indice.md, Index.md or README.md). Core folders have built-in descriptions; anything else
# shows "(sem descrição)" / "(no description)" until someone writes one.
#
# Markers in the root file (the skill adds them at setup):
#   <!-- context-keeper:map:start -->
#   <!-- context-keeper:map:end -->

set -u
. "$(dirname "$0")/lib.sh"

brain_arg=""; check=0
for a in "$@"; do
  case "$a" in --check) check=1 ;; *) brain_arg="$a" ;; esac
done
ck_resolve_brain "$brain_arg" || { echo "map: no brain found" >&2; exit 2; }
ck_load_names
[ -n "$ROOT_FILE" ] || { echo "map: no root file (CLAUDE.md) in $BRAIN" >&2; exit 2; }
root="$BRAIN/$ROOT_FILE"
START='<!-- context-keeper:map:start -->'
END='<!-- context-keeper:map:end -->'

# Built-in descriptions for core folders and files, in the brain's language.
builtin_desc() {
  case "$BRAIN_LANG" in
    pt*)
      case "$1" in
        "$ROOT_FILE") echo "este arquivo: regras, navegação e mapa" ;;
        AGORA.md|NOW.md) echo "estado atual: foco e pendências (lido sob demanda)" ;;
        AGENTS.md) echo "aponta outras IAs para o $ROOT_FILE" ;;
        Perfil|Profile) echo "quem é o usuário e como gosta que a IA trabalhe" ;;
        Diario|Journal) echo "uma entrada por sessão relevante (AAAA-MM-DD.md)" ;;
        Inbox) echo "capturas rápidas ainda não classificadas" ;;
        Templates) echo "modelos de nota" ;;
        Arquivo|Archive|4-Arquivo|4-Archive) echo "o que foi concluído ou abandonado" ;;
        Projetos|Projects|1-Projetos|1-Projects) echo "uma pasta por projeto" ;;
        Areas|2-Areas) echo "responsabilidades contínuas, sem prazo de término" ;;
        Recursos|Resources|3-Recursos|3-Resources) echo "temas de interesse e material de referência" ;;
        Pesquisa|Research) echo "estudos úteis para mais de um projeto" ;;
      esac ;;
    *)
      case "$1" in
        "$ROOT_FILE") echo "this file: rules, navigation and map" ;;
        NOW.md|AGORA.md) echo "current state: focus and open items (read on demand)" ;;
        AGENTS.md) echo "points other AIs to $ROOT_FILE" ;;
        Profile|Perfil) echo "who the user is and how they like the AI to work" ;;
        Journal|Diario) echo "one entry per relevant session (YYYY-MM-DD.md)" ;;
        Inbox) echo "quick captures not yet sorted" ;;
        Templates) echo "note templates" ;;
        Archive|Arquivo|4-Archive|4-Arquivo) echo "finished or abandoned work" ;;
        Projects|Projetos|1-Projects|1-Projetos) echo "one folder per project" ;;
        Areas|2-Areas) echo "ongoing responsibilities with no end date" ;;
        Resources|Recursos|3-Resources|3-Recursos) echo "topics of interest and reference material" ;;
        Research|Pesquisa) echo "research useful to more than one project" ;;
      esac ;;
  esac
}

no_desc() { case "$BRAIN_LANG" in pt*) echo "(sem descrição)" ;; *) echo "(no description)" ;; esac; }

# Description of a folder: its index note's frontmatter, else built-in, else empty.
folder_desc() {
  rel="$1"; name="$2"
  for idx in Indice.md Index.md README.md; do
    f="$BRAIN/$rel/$idx"
    [ -f "$f" ] || continue
    d="$(tr -d '\r' < "$f" | awk 'NR==1 && $0!="---" {exit} NR>1 && $0=="---" {exit} NR>1' \
         | sed -nE 's/^(descricao|description):[[:space:]]*//p' | head -n1 | sed -E 's/^["'\'']//; s/["'\'']$//')"
    # A template copied into the folder (e.g. Templates/Indice.md) still has its placeholder.
    case "$d" in *'{{'*) d="" ;; esac
    [ -n "$d" ] && { printf '%s' "$d"; return; }
  done
  builtin_desc "$name"
}

# Subfolders of a folder (relative path, "" for the brain root), sorted, skipping hidden,
# dependency and build folders.
subdirs() {
  for d in "$BRAIN/${1:+$1/}"*/; do
    [ -d "$d" ] || continue
    n="$(basename "$d")"
    case "$n" in node_modules|venv|dist|build|vendor|target|__pycache__) continue ;; esac
    printf '%s\n' "$n"
  done | sort
}

# Collect the rows: label (tree prefix + name) and description.
labels=(); descs=(); missing=""
add_row() { labels+=("$1"); descs+=("$2"); }

top_files=""
for f in "$ROOT_FILE" "$NOW_FILE" AGENTS.md; do
  [ -n "$f" ] && [ -f "$BRAIN/$f" ] && top_files="$top_files$f"$'\n'
done
top_files="$(printf '%s' "$top_files" | awk '!seen[tolower($0)]++')"
top_dirs="$(subdirs "")"
items="$(printf '%s\n%s\n' "$top_files" "$top_dirs" | sed '/^$/d')"
count="$(printf '%s\n' "$items" | sed '/^$/d' | wc -l | tr -d ' ')"

i=0
while IFS= read -r item; do
  [ -n "$item" ] || continue
  i=$((i + 1))
  if [ "$i" -eq "$count" ]; then branch="└── "; pad="    "; else branch="├── "; pad="│   "; fi
  if [ -d "$BRAIN/$item" ]; then
    d="$(folder_desc "$item" "$item")"
    [ -n "$d" ] || { d="$(no_desc)"; missing="$missing $item/"; }
    add_row "$branch$item/" "$d"
    children="$(subdirs "$item")"
    ccount="$(printf '%s\n' "$children" | sed '/^$/d' | wc -l | tr -d ' ')"
    j=0
    while IFS= read -r child; do
      [ -n "$child" ] || continue
      j=$((j + 1))
      if [ "$j" -eq "$ccount" ]; then cb="└── "; else cb="├── "; fi
      d="$(folder_desc "$item/$child" "$child")"
      [ -n "$d" ] || { d="$(no_desc)"; missing="$missing $item/$child/"; }
      add_row "$pad$cb$child/" "$d"
    done <<< "$children"
  else
    add_row "$branch$item" "$(builtin_desc "$item")"
  fi
done <<< "$items"

# Render with the descriptions aligned. Tree characters take 3 bytes each, so lengths are
# measured with each of them counted as one column.
cols() { printf '%s' "$1" | sed 's/├/x/g; s/└/x/g; s/│/x/g; s/─/x/g' | LC_ALL=C wc -c | tr -d ' '; }
width=0
for l in "${labels[@]}"; do
  n="$(cols "$l")"; [ "$n" -gt "$width" ] && width=$n
done
block="$START"$'\n''```'$'\n'"$(basename "$BRAIN")/"
for k in "${!labels[@]}"; do
  spaces="$(printf '%*s' $(( width - $(cols "${labels[$k]}") + 2 )) '')"
  block="$block"$'\n'"${labels[$k]}$spaces← ${descs[$k]}"
done
block="$block"$'\n''```'$'\n'"$END"

current="$(tr -d '\r' < "$root" | awk -v s="$START" -v e="$END" '$0==s{on=1} on{print} $0==e{on=0}')"
folders=$(( ${#labels[@]} ))

if [ -z "$current" ]; then
  echo "map: no map markers in $ROOT_FILE (add $START and $END where the map should go)"
  exit 1
fi
if [ "$current" = "$block" ]; then
  echo "map: up to date ($folders entries)"
  [ -n "$missing" ] && echo "map: without description:$missing"
  exit 0
fi
if [ "$check" -eq 1 ]; then
  echo "map: outdated (run update-map.sh or /context-keeper:map)"
  exit 1
fi

# Rewrite only the marked section, keeping the file's line endings.
crlf=0; grep -q $'\r' "$root" && crlf=1
tmp_new="$(tr -d '\r' < "$root" | MAPBLOCK="$block" awk -v s="$START" -v e="$END" '
  $0==s {print ENVIRON["MAPBLOCK"]; skip=1; next}
  skip && $0==e {skip=0; next}
  !skip {print}')"
if [ "$crlf" -eq 1 ]; then
  printf '%s\n' "$tmp_new" | sed 's/$/\r/' > "$root"
else
  printf '%s\n' "$tmp_new" > "$root"
fi
echo "map: updated ($folders entries)"
[ -n "$missing" ] && echo "map: without description:$missing"
exit 0
