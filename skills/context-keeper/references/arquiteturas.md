# Arquiteturas: estrutura de pastas e níveis de automação

## Núcleo fixo (presente em qualquer estrutura)

```
<Cerebro>/
├── CEREBRO.md        ← QUENTE: regras, mapa e protocolo de alimentação (≤ ~150 linhas)
├── AGORA.md          ← QUENTE: foco atual, pendências, últimas decisões (≤ ~60 linhas)
├── Perfil/
│   ├── Sobre-mim.md      ← quem é o usuário
│   └── Preferencias.md   ← como ele gosta que a IA trabalhe (cresce com as correções)
├── Inbox/            ← capturas rápidas ainda não classificadas
├── Diario/           ← AAAA-MM-DD.md: uma entrada curta por sessão relevante
├── Templates/        ← modelos de nota
├── Arquivo/          ← o que foi concluído ou abandonado (nada é apagado)
└── .context-keeper/         ← sistema: config.json, scripts, estado dos hooks (o Obsidian ignora pastas com ponto)
```

Por que cada peça existe:
- **`CEREBRO.md` separado de `AGORA.md`**: as regras mudam raramente; o estado muda toda sessão. Separar evita reescrever as regras a cada checkpoint e permite injetar só o `AGORA.md` após uma compactação.
- **`Perfil/Preferencias.md`**: toda correção do tipo "não faça X" ou "prefiro Y" vai para cá. É o que faz a IA parar de repetir erros entre sessões.
- **`Diario/`**: registro cronológico e barato de escrever. Quando não se sabe onde algo deveria ficar, o diário garante que não se perde.
- **`Arquivo/`**: tirar do caminho sem apagar mantém as áreas ativas enxutas (menos tokens na busca) e preserva o histórico.

## Opção A — Por assunto (recomendada para começar)

```
├── Projetos/
│   └── <Nome-do-Projeto>/
│       ├── Indice.md      ← MORNA: visão geral + "Estado atual" + links
│       ├── Decisoes/      ← AAAA-MM-DD-titulo.md
│       └── ...            ← outras notas do projeto
├── Estudos/               ← (se usar para estudo) uma pasta por disciplina/curso
└── Pesquisa/              ← estudos úteis para mais de um projeto
```

- Boa para: quem tem poucos tipos de atividade, desenvolvedores, estudantes.
- Simples de explicar e de navegar.
- Quando uma pesquisa serve a um só projeto, fica dentro dele.

## Opção B — PARA (Projetos, Áreas, Recursos, Arquivo)

```
├── 1-Projetos/    ← têm objetivo e fim (ex.: "Lançar portfólio")
├── 2-Areas/       ← responsabilidades contínuas, sem fim (ex.: Saúde, Finanças, Carreira, Faculdade)
├── 3-Recursos/    ← temas de interesse e referência (ex.: "Arquitetura de software")
└── 4-Arquivo/     ← substitui o Arquivo/ do núcleo
```

- Boa para: quem mistura vida pessoal, trabalho e estudo; quem já conhece o método de Tiago Forte.
- A pergunta "isto tem prazo de término?" decide entre Projeto e Área — explique isso ao usuário.
- Cada Projeto e cada Área tem seu `Indice.md` com "Estado atual".

## Opção C — Adotar a estrutura existente

Para quem já tem um cérebro ou vault. Mapeie os conceitos em vez de reorganizar:
- Arquivo raiz existente (`Claude.md`, `README.md`, `Home.md`) → faz o papel do `CEREBRO.md`; proponha adicionar as seções que faltam (protocolo de alimentação, mapa).
- Nota principal de cada pasta → faz o papel do `Indice.md`; proponha a seção "Estado atual" se não existir.
- Proponha criar apenas o que falta do núcleo (normalmente `AGORA.md`, `Perfil/`, `Diario/`, `.context-keeper/`).

---

## Pasta simples ou Obsidian

**Recomendação: uma pasta simples de arquivos Markdown.** Explique ao usuário, em linguagem simples:

- A IA **não abre o Obsidian**. Ela lê e escreve os arquivos `.md` direto no disco, como qualquer outro arquivo. O cérebro funciona igual com ou sem o Obsidian.
- O Obsidian é um **visualizador para humanos**: grafo, busca, navegação por links. É útil se o usuário quiser passear pelas notas, mas é opcional.
- Dá para mudar de ideia a qualquer momento: abrir a pasta do cérebro como cofre no Obsidian não altera nada nela.

**Links.** O padrão é o link Markdown comum, com caminho relativo à nota atual:

```markdown
[Usar Postgres](Decisoes/2026-09-25-usar-postgres.md)
```

É o melhor formato para a IA, porque o caminho é exato: ela abre o arquivo sem precisar procurar pelo nome. Também funciona no GitHub, no VS Code e no próprio Obsidian.

Se o usuário escolher Obsidian e **preferir** wikilinks (`[[usar-postgres]]`), tudo bem: registre `"link_style": "wikilink"` no `config.json` e escreva a convenção no `CEREBRO.md`. O custo é que a IA precisa procurar o arquivo pelo nome antes de abri-lo.

**Se escolher Obsidian**, diga ao usuário como configurar:
- Abrir a pasta do cérebro como cofre (*Open folder as vault*).
- Para manter links Markdown comuns: *Settings → Files and links* → desativar *Use [[Wikilinks]]* e em *New link format* escolher *Relative path to file*.
- O Obsidian cria a pasta `.obsidian/`. Os scripts e a IA a ignoram.
- Evitar recursos que só o Obsidian entende como fonte de verdade (consultas do Dataview, Canvas). A IA vê o texto da consulta, não o resultado.

---

## Níveis de automação

Descreva para o usuário o que cada nível **faz** e o que **toca** no computador.

### Nível 1 — Manual
- **Faz:** cria a pasta, as regras e os modelos. A IA só usa o cérebro quando o usuário manda ("leia meu cérebro em X").
- **Toca:** nada fora da pasta do cérebro.
- **Para quem:** quer testar antes; usa IAs sem acesso a arquivos (ChatGPT web).

### Nível 2 — Conectado
- **Faz:** a IA passa a carregar o `CEREBRO.md` automaticamente em toda sessão, em qualquer pasta, e segue o protocolo de alimentação sozinha.
- **Toca:** o ponteiro `~/.context-keeper/config` e os arquivos de instrução globais das ferramentas escolhidas (ex.: `~/.claude/CLAUDE.md`, `~/.codex/AGENTS.md`, `~/.gemini/GEMINI.md`). Um backup de cada um é feito antes.
- **Limitação:** depende de a IA lembrar de salvar. Em conversas muito longas, a compactação do contexto pode acontecer antes do registro.

### Nível 3 — Automático (Claude Code)
- **Faz, além do nível 2:**
  - Ao iniciar uma sessão **e logo após cada compactação**, injeta o `AGORA.md` e a última entrada do diário no contexto — a IA "acorda" sabendo onde parou.
  - Quando a conversa cresceu muito desde o último checkpoint, pede à IA que faça um checkpoint antes de encerrar a resposta — o estado vai para o cérebro antes que a compactação o resuma.
- **Toca:** instalado como plugin, nada além do nível 2 (os hooks vêm com o plugin e leem o ponteiro `~/.context-keeper/config`). Instalado como skill avulsa, também `~/.claude/settings.json` (merge, com backup) e scripts em `<Cerebro>/.context-keeper/scripts/`.
- **Requisito:** `bash` (no Windows vem com o Git for Windows, já exigido pelo Claude Code).
- **Custo:** alguns segundos a mais por checkpoint e ~1–2 mil tokens por sessão para o contexto quente.
