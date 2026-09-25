#!/usr/bin/env bash
# Hook SessionStart do Claude Code: injeta o contexto "quente" do segundo cérebro.
# Roda ao abrir, retomar, limpar e compactar a sessão; o que for impresso entra no contexto da IA.
#
# Uso: session-start.sh <pasta-do-cerebro>     (o JSON do hook chega pela entrada padrão)
# Variáveis opcionais:
#   CEREBRO_DIR        pasta do cérebro, se não for passada como argumento
#   CEREBRO_MAX_BYTES  limite do que é injetado (padrão 8000, ~2 mil tokens)

set -u
CEREBRO="${1:-${CEREBRO_DIR:-}}"
MAX_BYTES="${CEREBRO_MAX_BYTES:-8000}"

# Sem cérebro configurado, não atrapalha a sessão.
[ -n "$CEREBRO" ] && [ -d "$CEREBRO" ] || exit 0

entrada="$(cat 2>/dev/null || true)"
origem="$(printf '%s' "$entrada" | sed -n 's/.*"source"[[:space:]]*:[[:space:]]*"\([a-z]*\)".*/\1/p' | head -n1)"

{
  echo "# Segundo cérebro ($CEREBRO)"
  if [ "$origem" = "compact" ]; then
    echo "O contexto desta sessão acabou de ser compactado. Retome pelo AGORA.md abaixo e, se precisar de detalhes, pelo Indice.md do assunto. Se o trabalho feito antes da compactação ainda não estiver registrado, faça um checkpoint."
  fi
  echo "Regras e protocolo de alimentação: $CEREBRO/CEREBRO.md"
  echo

  if [ -f "$CEREBRO/AGORA.md" ]; then
    echo "## AGORA.md"
    cat "$CEREBRO/AGORA.md"
    echo
  fi

  ultimo="$(ls -1 "$CEREBRO/Diario/" 2>/dev/null | grep -E '^[0-9]{4}-[0-9]{2}-[0-9]{2}\.md$' | sort | tail -n1)"
  if [ -n "$ultimo" ]; then
    echo "## Última entrada do diário ($ultimo)"
    tail -n 25 "$CEREBRO/Diario/$ultimo"
  fi
} | head -c "$MAX_BYTES"

exit 0
