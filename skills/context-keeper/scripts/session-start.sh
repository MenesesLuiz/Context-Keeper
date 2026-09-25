#!/usr/bin/env bash
# Hook SessionStart do Claude Code: injeta o contexto "quente" do segundo cérebro.
# Roda ao abrir, retomar, limpar e compactar a sessão; o que for impresso entra no contexto da IA.
#
# Uso: session-start.sh [pasta-do-cerebro]     (o JSON do hook chega pela entrada padrão)
# Sem cérebro configurado (ver lib.sh), não imprime nada — o plugin pode estar instalado
# antes de o cérebro existir.
#
# Variável opcional: CONTEXT_KEEPER_MAX_BYTES, limite do que é injetado
# (padrão 8000; o Claude Code aceita até 10.000 caracteres).

set -u
. "$(dirname "$0")/lib.sh"
ck_resolve_brain "${1:-}" || exit 0
ck_load_names
MAX_BYTES="${CONTEXT_KEEPER_MAX_BYTES:-8000}"

entrada="$(cat 2>/dev/null || true)"
origem="$(printf '%s' "$entrada" | sed -n 's/.*"source"[[:space:]]*:[[:space:]]*"\([a-z]*\)".*/\1/p' | head -n1)"

{
  echo "# Segundo cérebro ($BRAIN)"
  if [ "$origem" = "compact" ]; then
    echo "O contexto desta sessão acabou de ser compactado. Retome pelo ${NOW_FILE:-estado atual} abaixo e, se precisar de detalhes, pelo Indice.md do assunto. Se o trabalho feito antes da compactação ainda não estiver registrado, faça um checkpoint."
  fi
  [ -n "$ROOT_FILE" ] && echo "Regras e protocolo de alimentação: $BRAIN/$ROOT_FILE"
  echo

  if [ -n "$NOW_FILE" ]; then
    echo "## $NOW_FILE"
    cat "$BRAIN/$NOW_FILE"
    echo
  fi

  if [ -n "$JOURNAL_DIR" ]; then
    ultimo="$(ls -1 "$BRAIN/$JOURNAL_DIR/" 2>/dev/null | grep -E '^[0-9]{4}-[0-9]{2}-[0-9]{2}\.md$' | sort | tail -n1)"
    if [ -n "$ultimo" ]; then
      echo "## Última entrada do diário ($JOURNAL_DIR/$ultimo)"
      tail -n 25 "$BRAIN/$JOURNAL_DIR/$ultimo"
    fi
  fi
} | head -c "$MAX_BYTES"

exit 0
