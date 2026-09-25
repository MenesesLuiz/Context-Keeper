#!/usr/bin/env bash
# Hook Stop do Claude Code: pede um checkpoint ao segundo cérebro quando a conversa
# cresceu muito desde o último registro — antes que a compactação resuma (e perca) o contexto.
#
# Uso: checkpoint-stop.sh <pasta-do-cerebro>     (o JSON do hook chega pela entrada padrão)
# Variáveis opcionais:
#   CEREBRO_DIR               pasta do cérebro, se não for passada como argumento
#   CEREBRO_CHECKPOINT_BYTES  crescimento da transcrição que dispara o pedido (padrão 300000)
#
# Como decide:
#   - guarda, por sessão, o tamanho da transcrição no último checkpoint (.cerebro/state/);
#   - se o AGORA.md foi alterado depois disso, considera que houve checkpoint e só atualiza a base;
#   - se a transcrição cresceu mais que o limite, bloqueia a parada uma vez pedindo o checkpoint;
#   - nunca bloqueia duas vezes seguidas (stop_hook_active), para não entrar em laço.

set -u
CEREBRO="${1:-${CEREBRO_DIR:-}}"
LIMITE="${CEREBRO_CHECKPOINT_BYTES:-300000}"

[ -n "$CEREBRO" ] && [ -d "$CEREBRO" ] || exit 0

entrada="$(cat 2>/dev/null || true)"

# A IA já está continuando por causa deste hook: deixa parar.
printf '%s' "$entrada" | grep -Eq '"stop_hook_active"[[:space:]]*:[[:space:]]*true' && exit 0

campo() {
  printf '%s' "$entrada" | sed -n "s/.*\"$1\"[[:space:]]*:[[:space:]]*\"\([^\"]*\)\".*/\1/p" | head -n1
}

sessao="$(campo session_id | tr -cd 'A-Za-z0-9_-')"
# No Windows o caminho chega com barras invertidas escapadas (C:\\Users\\...).
transcricao="$(campo transcript_path | sed 's/\\\\/\//g')"
[ -n "$sessao" ] && [ -f "$transcricao" ] || exit 0

tamanho="$(wc -c < "$transcricao" | tr -d '[:space:]')"
estado="$CEREBRO/.cerebro/state"
mkdir -p "$estado" 2>/dev/null || exit 0
base_arq="$estado/$sessao.checkpoint"

# Primeira parada da sessão, ou houve checkpoint desde a última vez: só registra a base.
if [ ! -f "$base_arq" ] || [ "$CEREBRO/AGORA.md" -nt "$base_arq" ]; then
  echo "$tamanho" > "$base_arq"
  exit 0
fi

base="$(cat "$base_arq" 2>/dev/null | tr -cd '0-9')"
base="${base:-0}"

if [ $((tamanho - base)) -ge "$LIMITE" ]; then
  echo "$tamanho" > "$base_arq"
  caminho="$(printf '%s' "$CEREBRO" | sed 's/\\/\\\\/g; s/"/\\"/g')"
  printf '{"decision":"block","reason":"Checkpoint do segundo cérebro: esta conversa cresceu bastante desde o último registro. Antes de encerrar, faça um checkpoint seguindo a seção 5 de %s/CEREBRO.md (decisões, Estado atual dos assuntos tocados, AGORA.md, Preferencias e uma entrada no diário). Se nada relevante aconteceu desde o último checkpoint, diga isso em uma linha e encerre."}\n' "$caminho"
fi

# Limpa estados de sessões antigas.
find "$estado" -name '*.checkpoint' -mtime +30 -delete 2>/dev/null
exit 0
