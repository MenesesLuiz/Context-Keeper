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

# 6. mari-mapa (pt-BR, hand-made brain like a typical user's: neutral Claude.md whose map is
#    outdated because folders were created by hand; tests the map in adopt mode)
P="$TARGET/mari-mapa/home"
B="$P/SegundoCerebro"
note "$B/Claude.md" "# Segundo cérebro: escopo global

Este arquivo é o ponto de partida de toda sessão. É neutro de propósito: não descreve nem favorece nenhum projeto.

## 1. Regras de conduta
1. Planejar antes de executar.
2. Idioma: português do Brasil.

## 2. Como navegar
1. Ler este arquivo.
2. Achar a pasta do assunto no mapa e ler a nota principal (Indice.md).

## 3. Mapa da estrutura

### Atual

\`\`\`
SegundoCerebro/
├── Claude.md    ← este arquivo
└── Projetos/    ← uma pasta por projeto
\`\`\`

## 4. Convenções
- Datas AAAA-MM-DD.
- Frontmatter em toda nota."
note "$B/Faculdade/Calculo-2/Indice.md" "---
tipo: area
descricao: Cálculo 2 (listas, provas e resumos)
criado: 2026-08-01
atualizado: 2026-09-20
---
# Cálculo 2"
mkdir -p "$B/Faculdade/Engenharia-de-Software"
note "$B/Projetos/Robo-Movel/Indice.md" "---
tipo: projeto
status: em-andamento
descricao: robô móvel autônomo com ESP32 e sensores ultrassônicos
criado: 2026-07-10
atualizado: 2026-09-28
---
# Robô móvel"
mkdir -p "$B/Projetos/Robo-Movel/firmware/.git"
note "$B/Projetos/Robo-Movel/firmware/README.md" "# firmware (repositório de código)"
note "$B/Projetos/Site-Cliente/Escopo.md" "# Site da padaria
Escopo combinado com o cliente."
mkdir -p "$B/Trabalho/Estagio"

# 7. ana-desktop (pt-BR, the student after setup at level 2, for testing the Claude Desktop guide:
#    a ready brain built from the skill's templates, with a map, a now file and two subjects)
P="$TARGET/ana-desktop/home"
B="$P/SegundoCerebro"
TPL="$(cd "$(dirname "$0")/.." && pwd)/skills/context-keeper/assets/templates/pt-BR"
mkdir -p "$B/Perfil" "$B/Diario" "$B/Templates"
sed -e 's/{{NOME}}/Ana/g' \
    -e 's/{{REGRAS_DE_CONDUTA}}/1. Explicar sem jargão técnico.\n2. Revisar meus textos, nunca escrever o TCC por mim.\n3. Idioma: português do Brasil./' \
    -e 's/{{CONVENCAO_DE_LINKS}}/links Markdown com caminho relativo (`[Texto](Pasta\/Nota.md)`)/' \
    -e 's/{{AUTONOMIA}}/escrever e avisar em uma linha no fim da resposta ("Registrado: <o quê> em <onde>")./' \
    -e 's/{{ESTRUTURA_PLANEJADA_OU_REMOVER_ESTA_SECAO}}/Uma pasta por disciplina dentro de `Faculdade\/`./' \
    "$TPL/CLAUDE.md" | awk '/^<!--$/ && !done {skip=1} skip && /^-->$/ {skip=0; done=1; next} !skip' > "$B/CLAUDE.md"
note "$B/AGORA.md" "---
tipo: estado
atualizado: 2026-09-29
---

# Agora

## Foco atual
- Revisar a introdução do TCC antes da reunião de quinta com a Profa. Marta.

## Pendências
- [ ] Prova 2 de Estatística em 2026-10-15.

## Último checkpoint
2026-09-29 — revisada a primeira metade da introdução do TCC."
note "$B/Faculdade/Indice.md" "---
tipo: area
descricao: graduação em Engenharia de Produção: uma pasta por disciplina
criado: 2026-08-10
atualizado: 2026-09-29
---

# Faculdade"
note "$B/Faculdade/TCC/Indice.md" "---
tipo: area
status: em-andamento
descricao: TCC sobre acessibilidade em aplicativos de transporte público
criado: 2026-09-01
atualizado: 2026-09-29
---

# TCC

## Estado atual
*Atualizado em 2026-09-29*

- **Fase:** escrita da introdução.
- **Orientadora:** Profa. Marta, reuniões às quintas.
- **Entrega final:** 2026-12-01.
- **Próximo passo:** terminar a revisão da introdução.

## Onde estão as coisas
- Rascunhos: \`Documents/Faculdade/TCC/\` (fora do cérebro; sugerido mover para esta pasta)."
note "$B/Faculdade/Estatistica/Indice.md" "---
tipo: area
status: em-andamento
descricao: disciplina de Estatística (listas e provas)
criado: 2026-08-10
atualizado: 2026-09-20
---

# Estatística

## Estado atual
- **Próxima prova:** Prova 2 em 2026-10-15."
sed -e 's/{{NOME}}/Ana/g' -e 's/{{DATA}}/2026-09-29/g' "$TPL/Preferencias.md" > "$B/Perfil/Preferencias.md"
note "$B/Diario/2026-09-29.md" "---
tipo: diario
criado: 2026-09-29
---

# 2026-09-29

## 20:10 — TCC
- **Feito:** revisada a primeira metade da introdução.
- **Próximo passo:** revisar a segunda metade."
cp "$TPL"/Decisao.md "$TPL"/Indice.md "$TPL"/Diario.md "$B/Templates/" 2>/dev/null || true
bash "$(dirname "$0")/../skills/context-keeper/scripts/update-map.sh" "$B" >/dev/null

echo "Personas created in $TARGET:"
ls -1 "$TARGET"
