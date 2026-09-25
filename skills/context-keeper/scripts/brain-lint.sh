#!/usr/bin/env bash
# Verificação de saúde do segundo cérebro. Não altera nada: só relata.
#
# Uso: brain-lint.sh [pasta-do-cerebro] [dias-para-considerar-parado]

set -u
. "$(dirname "$0")/lib.sh"
DIAS="${2:-60}"
MAX_RAIZ=150
MAX_AGORA=60
DIAS_INBOX=14

if ! ck_resolve_brain "${1:-}"; then
  echo "Uso: brain-lint.sh [pasta-do-cerebro] [dias]  (sem argumento, usa ~/.context-keeper/config)" >&2
  exit 1
fi
ck_load_names
CEREBRO="$BRAIN"
cd "$CEREBRO" || exit 1

problemas=0
secao() { echo; echo "## $1"; }
aviso() { echo "- $1"; problemas=$((problemas + 1)); }

# Lista as notas, ignorando pastas de sistema e os modelos.
notas() {
  find . -type f -name '*.md' \
    -not -path './.git/*' -not -path './.obsidian/*' -not -path './.trash/*' \
    -not -path './.context-keeper/*' -not -path './Templates/*' -not -path './Modelos/*' -print0
}

echo "# Verificação do segundo cérebro: $CEREBRO"
echo "Data: $(date +%F)"

# 1. Tamanho do contexto quente
secao "Contexto quente (carregado em toda sessão)"
raiz="$ROOT_FILE"
if [ -z "$raiz" ]; then
  aviso "Nenhum arquivo raiz encontrado (CEREBRO.md, BRAIN.md, Claude.md ou AGENTS.md)."
else
  linhas=$(wc -l < "$raiz" | tr -d ' ')
  [ "$linhas" -gt "$MAX_RAIZ" ] && aviso "$raiz tem $linhas linhas (recomendado: até $MAX_RAIZ)."
  echo "- $raiz: $linhas linhas"
fi
if [ -n "$NOW_FILE" ]; then
  linhas=$(wc -l < "$NOW_FILE" | tr -d ' ')
  [ "$linhas" -gt "$MAX_AGORA" ] && aviso "$NOW_FILE tem $linhas linhas (recomendado: até $MAX_AGORA)."
  echo "- $NOW_FILE: $linhas linhas"
else
  aviso "Não há arquivo de estado atual (AGORA.md ou NOW.md): a IA não tem onde ler onde parou."
fi

# 2. Frontmatter e notas paradas
secao "Frontmatter e notas paradas (mais de $DIAS dias)"
corte="$(date -d "-$DIAS days" +%F 2>/dev/null || date -v-"$DIAS"d +%F 2>/dev/null || echo "")"
total=0
while IFS= read -r -d '' f; do
  total=$((total + 1))
  case "$f" in "./$JOURNAL_DIR"/*|./Arquivo/*|./4-Arquivo/*|./Archive/*|"./$raiz") continue ;; esac
  if [ "$(head -n1 "$f" | tr -d '\r')" != "---" ]; then
    aviso "Sem frontmatter: ${f#./}"
    continue
  fi
  atualizado="$(grep -m1 -E '^atualizado:' "$f" | sed -E 's/^atualizado:[[:space:]]*([0-9]{4}-[0-9]{2}-[0-9]{2}).*/\1/')"
  if [ -n "$corte" ] && [ -n "$atualizado" ] && [[ "$atualizado" < "$corte" ]]; then
    aviso "Parada desde $atualizado: ${f#./}"
  fi
done < <(notas)
echo "- Notas verificadas: $total"

# 3. Inbox
secao "Inbox (itens com mais de $DIAS_INBOX dias)"
if [ -d Inbox ]; then
  while IFS= read -r -d '' f; do
    aviso "Aguardando triagem: ${f#./}"
  done < <(find ./Inbox -type f -mtime +"$DIAS_INBOX" -print0)
fi

# 4. Links quebrados
secao "Links quebrados"
existentes="$(find . -type f -not -path './.git/*' -not -path './.obsidian/*' | sed 's#.*/##; s#\.md$##' | sort -u)"
while IFS= read -r -d '' f; do
  dir="$(dirname "$f")"
  # Ignora exemplos em blocos de código e em `código inline`.
  texto="$(awk '/^[[:space:]]*```/ { dentro = !dentro; next } !dentro' "$f" | sed 's/`[^`]*`//g')"

  # Wikilinks [[Nota]]: procurados pelo nome em qualquer pasta, como o Obsidian faz.
  printf '%s\n' "$texto" | grep -o '\[\[[^]]*\]\]' 2>/dev/null | sort -u | while IFS= read -r link; do
    alvo="${link#[[}"; alvo="${alvo%]]}"
    alvo="${alvo%%|*}"; alvo="${alvo%%#*}"; alvo="${alvo##*/}"; alvo="${alvo%.md}"
    [ -z "$alvo" ] && continue
    case "$alvo" in *'{{'*) continue ;; esac
    if ! printf '%s\n' "$existentes" | grep -Fxq "$alvo"; then
      echo "- ${f#./} → [[${alvo}]]"
    fi
  done

  # Links Markdown [texto](caminho): o caminho é relativo à pasta da nota.
  printf '%s\n' "$texto" | grep -oE '\]\([^)[:space:]]+\)' 2>/dev/null | sort -u | while IFS= read -r link; do
    alvo="${link#](}"; alvo="${alvo%)}"
    case "$alvo" in http://*|https://*|mailto:*|'#'*|*'{{'*) continue ;; esac
    alvo="${alvo%%#*}"; alvo="$(printf '%s' "$alvo" | sed 's/%20/ /g')"
    [ -z "$alvo" ] && continue
    [ -e "$dir/$alvo" ] || echo "- ${f#./} → ($alvo)"
  done
done < <(notas) > "${TMPDIR:-/tmp}/brain-lint-links.$$"
if [ -s "${TMPDIR:-/tmp}/brain-lint-links.$$" ]; then
  cat "${TMPDIR:-/tmp}/brain-lint-links.$$"
  problemas=$((problemas + $(wc -l < "${TMPDIR:-/tmp}/brain-lint-links.$$")))
fi
rm -f "${TMPDIR:-/tmp}/brain-lint-links.$$"

# 5. Possíveis segredos (mostra só arquivo e linha, nunca o valor)
secao "Possíveis segredos"
grep -rnIE \
  --exclude-dir=.git --exclude-dir=.obsidian --exclude-dir=.context-keeper \
  '((api[_-]?key|secret|senha|password|passwd|token)[[:space:]]*[:=][[:space:]]*[^[:space:]{}]{8,})|(sk-[A-Za-z0-9_-]{20,})|(ghp_[A-Za-z0-9]{20,})|(AKIA[0-9A-Z]{16})' \
  . 2>/dev/null | cut -d: -f1,2 | while IFS= read -r ocorrencia; do
    echo "- Verificar: ${ocorrencia#./}"
  done

secao "Resumo"
echo "- Pontos de atenção (sem contar segredos): $problemas"
exit 0
