#!/usr/bin/env bash
# Creates fictional test personas for context-keeper, each with its own simulated home folder.
# Tests must treat <target>/<persona>/home as the user's home and never look outside it.
#
# Usage: bash tests/make-personas.sh <target-folder>

set -eu
TARGET="${1:?usage: make-personas.sh <target-folder>}"
mkdir -p "$TARGET"
note() { mkdir -p "$(dirname "$1")"; printf '%s\n' "$2" > "$1"; }

# 1. ana-estudante (pt-BR, non-technical, uses the Claude desktop app, thesis in progress)
P="$TARGET/ana-estudante/home"
mkdir -p "$P/AppData/Roaming/Claude"
note "$P/AppData/Roaming/Claude/claude_desktop_config.json" '{}'
note "$P/Documents/Faculdade/TCC/rascunho-introducao.txt" "Introdução do TCC sobre acessibilidade em aplicativos de transporte público."
note "$P/Documents/Faculdade/TCC/orientador.txt" "Orientadora: Profa. Marta. Reuniões às quintas. Entrega final em 2026-12-01."
note "$P/Documents/Faculdade/Disciplinas/estatistica.txt" "Prova 2 em 2026-10-15."

# 2. rafa-dev (pt-BR, developer, Claude Code with the plugin, 4 repositories)
P="$TARGET/rafa-dev/home"
note "$P/.claude/settings.json" '{ "enabledPlugins": { "context-keeper@context-keeper": true } }'
note "$P/.codex/config.toml" 'model = "default"'
for repo in payments-api web-app infra cli-tool; do
  note "$P/code/$repo/README.md" "# $repo
Part of the Rafa's side business platform. See docs/ for details."
done

# 3. bia-obsidian (pt-BR, Obsidian vault with years of notes, not written for an AI)
P="$TARGET/bia-obsidian/home"
V="$P/Vault"
mkdir -p "$V/.obsidian"
note "$V/.obsidian/app.json" '{}'
for i in $(seq 1 12); do
  note "$V/Diario/2023-0$(( (i % 9) + 1 ))-1$(( i % 9 )).md" "Dia comum. Pensando em [[Mudança de carreira]]."
done
note "$V/Mudança de carreira.md" "Quero migrar para UX. Ver [[Cursos UX]] e [[Portfólio]]."
note "$V/Cursos UX.md" "Lista de cursos. [[Portfólio]] precisa de 3 estudos de caso."
note "$V/Portfólio.md" "Estudos de caso: app de receitas, redesign do site da ONG. ![[capa.png]]"
note "$V/Receitas/Bolo de cenoura.md" "Receita da vó."
note "$V/Leituras/Hooked.md" "Resumo do livro Hooked. Ligado a [[Cursos UX]]."
note "$V/Rascunhos/Sem título.md" ""
note "$V/Rascunhos/Sem título 1.md" ""
touch -d '2023-01-10' "$V"/Receitas/*.md "$V"/Rascunhos/*.md 2>/dev/null || true

# 4. sam-designer (en, freelance designer, Claude Desktop and Cursor, 6 clients)
P="$TARGET/sam-designer/home"
note "$P/AppData/Roaming/Claude/claude_desktop_config.json" '{}'
mkdir -p "$P/AppData/Local/Programs/cursor"
for c in Acme-Bakery Northwind Lumen-Studio Parkside-Dental Orbit-Fitness Verde-Market; do
  note "$P/Documents/Clients/$c/brief.txt" "Client: $c. Scope and agreements live in emails for now."
done

# 5. leo-adota (pt-BR, hand-made brain written for an AI, to test adopt mode end to end)
P="$TARGET/leo-adota/home"
note "$P/.claude/settings.json" '{ "enabledPlugins": { "context-keeper@context-keeper": true } }'
B="$P/Notas-IA"
note "$B/Claude.md" "# Instruções para a IA

Leia este arquivo antes de qualquer tarefa. Sempre responda em português.
Antes de mudar código, explique o plano.

Projetos: [[App-Receitas]] e [[Blog]]."
note "$B/Projetos/App-Receitas.md" "# App Receitas
App mobile de receitas. Decidimos usar Flutter em 2026-08-02 porque o Leo já conhece Dart.
Próximo passo: tela de busca."
note "$B/Projetos/Blog.md" "# Blog
Blog pessoal sobre cozinha. Parado desde julho."

echo "Personas created in $TARGET:"
ls -1 "$TARGET"
