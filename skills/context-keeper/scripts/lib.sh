#!/usr/bin/env bash
# Funções comuns aos scripts do context-keeper. Use com: . "$(dirname "$0")/lib.sh"
#
# Onde fica o cérebro, em ordem de prioridade:
#   1. argumento passado ao script;
#   2. variável CONTEXT_KEEPER_BRAIN;
#   3. linha "brain_path=..." em ~/.context-keeper/config (gravada pela skill ao criar o cérebro).
#
# Nomes dos arquivos (variam por idioma e em cérebros adotados):
#   lidos de <cérebro>/.context-keeper/config.json ("root", "now", "journal");
#   sem config, detecta os nomes conhecidos (CEREBRO.md/BRAIN.md, AGORA.md/NOW.md, Diario/Journal).

ck_resolve_brain() {
  BRAIN="${1:-${CONTEXT_KEEPER_BRAIN:-}}"
  if [ -z "$BRAIN" ] && [ -f "$HOME/.context-keeper/config" ]; then
    BRAIN="$(sed -n 's/^brain_path=//p' "$HOME/.context-keeper/config" | head -n1 | tr -d '\r')"
  fi
  [ -n "$BRAIN" ] && [ -d "$BRAIN" ]
}

# Valor de uma chave de texto num JSON simples: ck_json_value <arquivo> <chave>
ck_json_value() {
  sed -n "s/.*\"$2\"[[:space:]]*:[[:space:]]*\"\([^\"]*\)\".*/\1/p" "$1" 2>/dev/null | head -n1
}

# Primeiro nome da lista que existe no cérebro: ck_first_existing <-f|-d> nome...
ck_first_existing() {
  tipo="$1"; shift
  for nome in "$@"; do
    [ "$tipo" "$BRAIN/$nome" ] && { printf '%s' "$nome"; return; }
  done
}

ck_load_names() {
  cfg="$BRAIN/.context-keeper/config.json"
  ROOT_FILE=""; NOW_FILE=""; JOURNAL_DIR=""
  if [ -f "$cfg" ]; then
    ROOT_FILE="$(ck_json_value "$cfg" root)"
    NOW_FILE="$(ck_json_value "$cfg" now)"
    JOURNAL_DIR="$(ck_json_value "$cfg" journal)"
  fi
  [ -n "$ROOT_FILE" ]   || ROOT_FILE="$(ck_first_existing -f CEREBRO.md BRAIN.md Claude.md CLAUDE.md AGENTS.md)"
  [ -n "$NOW_FILE" ]    || NOW_FILE="$(ck_first_existing -f AGORA.md NOW.md)"
  [ -n "$JOURNAL_DIR" ] || JOURNAL_DIR="$(ck_first_existing -d Diario Journal)"
}
