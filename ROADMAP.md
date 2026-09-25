# Roadmap

Versão atual: **0.1.0 — em desenvolvimento**

## Decisões tomadas (2026-09-25)

- **Nome:** `context-keeper`.
- **Licença:** MIT.
- **Distribuição:** plugin do Claude Code, com marketplace no próprio repositório. A pasta da skill continua funcionando sozinha.
- **Idioma:** inglês é o idioma principal (skill, `README.md`, documentação). O `README.md` tem um link para o `README.pt-BR.md`, em português, para o público brasileiro.
- **Obsidian:** opcional. O padrão recomendado é uma pasta de Markdown simples, porque a IA lê os arquivos direto do disco.

## Plano

- [x] **Fase 1 — Plugin `context-keeper`:** manifestos, hooks no plugin, ponteiro `~/.context-keeper/config`, atalhos.
- [x] **Fase 2 — Obsidian opcional:** pergunta na entrevista, explicação, links Markdown comuns como padrão, verificador checa os dois tipos de link.
- [ ] **Fase 3 — Inglês:** skill em inglês, modelos por idioma (`pt-BR/` e `en/`), `README.md` em inglês com link para `README.pt-BR.md`.
- [ ] **Fase 4 — Testes reais:** adotar o `E:\SecondBrain` (numa cópia primeiro) e rodar os cenários de `tests/skill-evals.json`.
- [ ] **Fase 5 — Publicar:** renomear o repositório, tag `v0.1.0`, testar a instalação pelo marketplace.

## Pendências da Fase 1

- [x] Renomear o repositório no GitHub para `MenesesLuiz/Context-Keeper` e atualizar os links.
- [ ] Tornar o repositório público antes de divulgar (a instalação pelo marketplace exige acesso ao repositório).
- [ ] Testar o plugin numa sessão real com `claude --plugin-dir .`.

## Próximas versões

### 0.2 — Validar com uso real
- [ ] Rodar a skill em 3 cenários e comparar com o Claude sem a skill: usuário não técnico (caminho rápido), dev com Claude Code (nível 3), usuário com vault do Obsidian (importação). Prompts em `tests/skill-evals.json`.
- [ ] Rodar em modo *adotar* sobre um cérebro feito à mão (ex.: uma pasta com `Claude.md`).
- [ ] Medir o tamanho real do contexto quente depois de um mês de uso.
- [ ] Ajustar o limite padrão do checkpoint (`CONTEXT_KEEPER_CHECKPOINT_BYTES`) com transcrições reais.

### 0.3 — Automação mais inteligente
- [ ] Hook `UserPromptSubmit` que injeta o `Indice.md` do assunto quando o prompt cita um projeto conhecido (busca por nome das pastas).
- [ ] Hook `SessionEnd` que registra no diário que a sessão terminou sem checkpoint.
- [ ] Versões PowerShell dos scripts, para quem não tem bash.
- [ ] Manutenção agendada (lembrete mensal) com as tarefas agendadas da ferramenta.

### 0.4 — Mais ferramentas
- [ ] Servidor MCP do cérebro (ferramentas `buscar`, `ler_estado`, `registrar_decisao`, `checkpoint`), para qualquer IA compatível com MCP usar o cérebro com as mesmas regras.
- [ ] Guia testado para Cursor, Codex, Gemini CLI e Claude Desktop.
- [ ] Importadores dedicados: exportação do ChatGPT (`conversations.json`), Notion.

### Ideias
- Busca semântica local (embeddings) para cérebros grandes.
- "Perfis de cérebro" prontos: estudante, dev, pesquisador, criador de conteúdo.
- Painel HTML gerado a partir do cérebro (status dos projetos, decisões recentes).
