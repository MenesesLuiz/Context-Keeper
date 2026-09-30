#!/usr/bin/env bash
# Shared helpers for the context-keeper scripts. Load with: . "$(dirname "$0")/lib.sh"
#
# Where the brain is, in order of priority:
#   1. the argument passed to the script;
#   2. the CONTEXT_KEEPER_BRAIN variable;
#   3. the "brain_path=..." line in ~/.context-keeper/config (written by the skill at setup).
#
# File names and language (they vary per language and in adopted brains):
#   read from <brain>/.context-keeper/config.json ("root", "now", "journal", "language");
#   without a config, known names are detected (BRAIN.md/CEREBRO.md, NOW.md/AGORA.md, Journal/Diario).

ck_resolve_brain() {
  BRAIN="${1:-${CONTEXT_KEEPER_BRAIN:-}}"
  if [ -z "$BRAIN" ] && [ -f "$HOME/.context-keeper/config" ]; then
    BRAIN="$(sed -n 's/^brain_path=//p' "$HOME/.context-keeper/config" | head -n1 | tr -d '\r')"
  fi
  [ -n "$BRAIN" ] && [ -d "$BRAIN" ]
}

# Value of a string key in a simple JSON file: ck_json_value <file> <key>
ck_json_value() {
  sed -n "s/.*\"$2\"[[:space:]]*:[[:space:]]*\"\([^\"]*\)\".*/\1/p" "$1" 2>/dev/null | head -n1
}

# First name in the list that exists in the brain: ck_first_existing <-f|-d> name...
ck_first_existing() {
  kind="$1"; shift
  for name in "$@"; do
    [ "$kind" "$BRAIN/$name" ] && { printf '%s' "$name"; return; }
  done
}

ck_load_names() {
  cfg="$BRAIN/.context-keeper/config.json"
  ROOT_FILE=""; NOW_FILE=""; JOURNAL_DIR=""; BRAIN_LANG=""
  if [ -f "$cfg" ]; then
    ROOT_FILE="$(ck_json_value "$cfg" root)"
    NOW_FILE="$(ck_json_value "$cfg" now)"
    JOURNAL_DIR="$(ck_json_value "$cfg" journal)"
    BRAIN_LANG="$(ck_json_value "$cfg" language)"
  fi
  [ -n "$ROOT_FILE" ]   || ROOT_FILE="$(ck_first_existing -f CLAUDE.md Claude.md BRAIN.md CEREBRO.md AGENTS.md)"
  [ -n "$NOW_FILE" ]    || NOW_FILE="$(ck_first_existing -f NOW.md AGORA.md)"
  [ -n "$JOURNAL_DIR" ] || JOURNAL_DIR="$(ck_first_existing -d Journal Diario)"
  if [ -z "$BRAIN_LANG" ]; then
    case "$NOW_FILE$ROOT_FILE$JOURNAL_DIR" in
      *AGORA*|*CEREBRO*|*Diario*) BRAIN_LANG="pt-BR" ;;
      *) BRAIN_LANG="en" ;;
    esac
    # The root is now CLAUDE.md in every language: look at its text as a last resort.
    if [ "$BRAIN_LANG" = "en" ] && [ -n "$ROOT_FILE" ] &&        grep -qiE '(^|[^a-z])(você|não|pasta|projetos|sessão)([^a-z]|$)' "$BRAIN/$ROOT_FILE" 2>/dev/null; then
      BRAIN_LANG="pt-BR"
    fi
  fi
}

# Hook messages in the brain's language: ck_msg <key> [value for %s]
ck_msg() {
  case "$BRAIN_LANG" in
    pt*)
      case "$1" in
        title)      fmt='# Segundo cérebro (%s)' ;;
        compacted)  fmt='O contexto desta sessão acabou de ser compactado. Retome pelo %s abaixo e, se precisar de detalhes, pelo índice do assunto. Se o trabalho feito antes da compactação ainda não estiver registrado, faça um checkpoint.' ;;
        rules)      fmt='Regras e protocolo de alimentação: %s' ;;
        journal)    fmt='## Última entrada do diário (%s)' ;;
        map)        fmt='O mapa do cérebro (seção Atual do %s) foi atualizado com as pastas reais. Use-o para localizar áreas e projetos:' ;;
        nodesc)     fmt='Pastas sem descrição no mapa:%s. Quando o assunto surgir, proponha ao usuário uma descrição de uma linha (campo descricao: no Indice.md da pasta).' ;;
        checkpoint) fmt='Checkpoint do segundo cérebro: esta conversa cresceu bastante desde o último registro. Antes de encerrar, faça um checkpoint seguindo o protocolo de alimentação de %s (decisões, Estado atual dos assuntos tocados, arquivo de estado atual, preferências e uma entrada no diário). Se nada relevante aconteceu desde o último checkpoint, diga isso em uma linha e encerre.' ;;
      esac ;;
    *)
      case "$1" in
        title)      fmt='# Second brain (%s)' ;;
        compacted)  fmt="This session's context was just compacted. Resume from %s below and, for details, from the subject's index note. If the work done before the compaction is not recorded yet, run a checkpoint." ;;
        rules)      fmt='Rules and feeding protocol: %s' ;;
        journal)    fmt='## Latest journal entry (%s)' ;;
        map)        fmt="The brain's map (the current map section of %s) was updated from the real folders. Use it to find areas and projects:" ;;
        nodesc)     fmt='Folders without a description in the map:%s. When the subject comes up, propose a one-line description to the user (description: field in the folder index note).' ;;
        checkpoint) fmt='Second brain checkpoint: this conversation has grown a lot since the last save. Before finishing, run a checkpoint following the feeding protocol in %s (decisions, current state of the subjects touched, the current-state file, preferences and a journal entry). If nothing relevant happened since the last checkpoint, say so in one line and stop.' ;;
      esac ;;
  esac
  printf "$fmt" "${2:-}"
}
