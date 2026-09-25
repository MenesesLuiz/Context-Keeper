# Roadmap

Versão atual: **0.1.0 — rascunho inicial**

## Decisões em aberto

- [ ] **Idioma do repositório.** Hoje tudo está em pt-BR. Publicar também em inglês (README bilíngue ou skill com `references/` por idioma)?
- [ ] **Nome da skill e do repositório.** `second-brain` é genérico e já existem projetos com esse nome. Alternativas: `ai-second-brain`, `cerebro-ia`, `context-keeper`.
- [ ] **Licença.** MIT é o padrão mais comum para skills.
- [ ] **Distribuição.** Só a pasta da skill, ou também como plugin do Claude Code (marketplace), o que permitiria instalar com um comando?

## Próximas versões

### 0.2 — Validar com uso real
- [ ] Rodar a skill em 3 cenários e comparar com o Claude sem a skill: usuário não técnico (caminho rápido), dev com Claude Code (nível 3), usuário com vault do Obsidian (importação). Prompts em `evals/evals.json`.
- [ ] Rodar em modo *adotar* sobre um cérebro feito à mão (ex.: uma pasta com `Claude.md`).
- [ ] Medir o tamanho real do contexto quente depois de um mês de uso.
- [ ] Ajustar o limite padrão do checkpoint (`CEREBRO_CHECKPOINT_BYTES`) com transcrições reais.

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
