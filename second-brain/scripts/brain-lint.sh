#!/usr/bin/env bash
# Verificação de saúde do segundo cérebro. Não altera nada: só relata.
#
# Uso: brain-lint.sh <pasta-do-cerebro> [dias-para-considerar-parado]

set -u
CEREBRO="${1:-${CEREBRO_DIR:-}}"
DIAS="${2:-60}"
MAX_RAIZ=150
MAX_AGORA=60
DIAS_INBOX=14

if [ -z "$CEREBRO" ] || [ ! -d "$CEREBRO" ]; then
  echo "Uso: brain-lint.sh <pasta-do-cerebro> [dias]" >&2
  exit 1
fi
cd "$CEREBRO" || exit 1

problemas=0
secao() { echo; echo "## $1"; }
aviso() { echo "- $1"; problemas=$((problemas + 1)); }

# Lista as notas, ignorando pastas de sistema e os modelos.
notas() {
  find . -type f -name '*.md' \
    -not -path './.git/*' -not -path './.obsidian/*' -not -path './.trash/*' \
    -not -path './.cerebro/*' -not -path './Templates/*' -print0
}

echo "# Verificação do segundo cérebro: $CEREBRO"
echo "Data: $(date +%F)"

# 1. Tamanho do contexto quente
secao "Contexto quente (carregado em toda sessão)"
raiz=""
for nome in CEREBRO.md Claude.md CLAUDE.md AGENTS.md; do
  [ -f "$nome" ] && { raiz="$nome"; break; }
done
if [ -z "$raiz" ]; then
  aviso "Nenhum arquivo raiz encontrado (CEREBRO.md, Claude.md ou AGENTS.md)."
else
  linhas=$(wc -l < "$raiz" | tr -d ' ')
  [ "$linhas" -gt "$MAX_RAIZ" ] && aviso "$raiz tem $linhas linhas (recomendado: até $MAX_RAIZ)."
  echo "- $raiz: $linhas linhas"
fi
if [ -f AGORA.md ]; then
  linhas=$(wc -l < AGORA.md | tr -d ' ')
  [ "$linhas" -gt "$MAX_AGORA" ] && aviso "AGORA.md tem $linhas linhas (recomendado: até $MAX_AGORA)."
  echo "- AGORA.md: $linhas linhas"
else
  aviso "AGORA.md não existe: a IA não tem onde ler o estado atual."
fi

# 2. Frontmatter e notas paradas
secao "Frontmatter e notas paradas (mais de $DIAS dias)"
corte="$(date -d "-$DIAS days" +%F 2>/dev/null || date -v-"$DIAS"d +%F 2>/dev/null || echo "")"
total=0
while IFS= read -r -d '' f; do
  total=$((total + 1))
  case "$f" in ./Diario/*|./Arquivo/*|./4-Arquivo/*|"./$raiz") continue ;; esac
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
secao "Links [[...]] quebrados"
existentes="$(find . -type f -not -path './.git/*' -not -path './.obsidian/*' | sed 's#.*/##; s#\.md$##' | sort -u)"
while IFS= read -r -d '' f; do
  # Ignora exemplos em blocos de código e em `código inline`.
  awk '/^[[:space:]]*```/ { dentro = !dentro; next } !dentro' "$f" | sed 's/`[^`]*`//g' \
    | grep -o '\[\[[^]]*\]\]' 2>/dev/null | sort -u | while IFS= read -r link; do
    alvo="${link#[[}"; alvo="${alvo%]]}"
    alvo="${alvo%%|*}"; alvo="${alvo%%#*}"; alvo="${alvo##*/}"; alvo="${alvo%.md}"
    [ -z "$alvo" ] && continue
    case "$alvo" in *'{{'*) continue ;; esac
    if ! printf '%s\n' "$existentes" | grep -Fxq "$alvo"; then
      echo "- ${f#./} → [[${alvo}]]"
    fi
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
  --exclude-dir=.git --exclude-dir=.obsidian --exclude-dir=.cerebro \
  '((api[_-]?key|secret|senha|password|passwd|token)[[:space:]]*[:=][[:space:]]*[^[:space:]{}]{8,})|(sk-[A-Za-z0-9_-]{20,})|(ghp_[A-Za-z0-9]{20,})|(AKIA[0-9A-Z]{16})' \
  . 2>/dev/null | cut -d: -f1,2 | while IFS= read -r ocorrencia; do
    echo "- Verificar: ${ocorrencia#./}"
  done

secao "Resumo"
echo "- Pontos de atenção (sem contar segredos): $problemas"
exit 0
