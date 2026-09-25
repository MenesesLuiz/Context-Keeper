---
name: second-brain
description: Monta, alimenta e mantém um "segundo cérebro" local para a IA — uma pasta de notas Markdown que a IA lê no início de cada sessão e atualiza sozinha, para não perder contexto entre conversas nem depois de compactações. Conduz uma entrevista com o usuário, propõe um plano de ação com opções para ele escolher e só então cria a estrutura, as regras e as automações (hooks do Claude Code, arquivos de instrução para Cursor/Codex/Gemini). Use sempre que o usuário falar em segundo cérebro, second brain, memória persistente ou de longo prazo para IA, "a IA esquece tudo", perder contexto, contexto entre sessões, organizar notas para o Claude, migrar do Obsidian/Notion para algo que a IA use, ou pedir para salvar/registrar/fazer checkpoint do que foi decidido "no cérebro" — mesmo que não diga "segundo cérebro" explicitamente.
---

# Segundo Cérebro para IA

Esta skill cria um segundo cérebro **feito para a IA ler e escrever**, não só para o humano navegar. A diferença para um vault comum do Obsidian é que aqui existem três coisas que o Obsidian sozinho não dá:

1. **Um ponto de entrada fixo** que a IA carrega automaticamente toda sessão.
2. **Regras de alimentação**: quando e o que a IA deve registrar, sem o usuário precisar pedir.
3. **Automação**: gatilhos que recarregam o contexto depois de uma compactação e lembram a IA de salvar o estado antes que ele se perca.

As notas continuam sendo Markdown puro com `[[wikilinks]]` e frontmatter, então o Obsidian segue funcionando como visualizador opcional.

## Princípios (leia antes de qualquer modo)

Estes princípios explicam as escolhas da skill. Quando surgir um caso que as instruções não cobrem, decida a partir deles.

- **O usuário escolhe, a IA propõe.** Nada é criado antes de o usuário aprovar um plano. Arquivos fora da pasta do cérebro (configurações de ferramentas, `~/.claude/settings.json` etc.) só são tocados com consentimento explícito e depois de um backup.
- **Memória em camadas, para caber no contexto.** O que é carregado sempre precisa ser pequeno; o resto é buscado sob demanda.
  - *Quente* (carregada toda sessão, idealmente menos de ~2.000 tokens no total): `CEREBRO.md` (regras e mapa) e `AGORA.md` (foco atual, pendências).
  - *Morna* (carregada ao entrar num assunto): o `Indice.md` de cada projeto/área, com a seção "Estado atual".
  - *Fria* (lida só quando necessário): decisões, pesquisas, diário antigo, arquivo.
- **O cérebro guarda o porquê; o código e o git guardam o como.** Não copiar para o cérebro o que já está no código, no README ou no histórico do git.
- **O cérebro precisa funcionar sem esta skill.** Todas as regras de alimentação ficam escritas dentro do próprio `CEREBRO.md`, para que qualquer IA (ou esta mesma, sem a skill instalada) saiba operar o cérebro.
- **Atualizar em vez de duplicar.** Antes de criar uma nota, procurar se já existe uma sobre o assunto.
- **Datas absolutas** (`AAAA-MM-DD`), nunca "ontem" ou "semana que vem" — a nota será lida meses depois.
- **Nunca guardar segredos** (senhas, tokens, chaves de API, dados de cartão). Se o usuário colar um, avisar e não registrar.

## Escolher o modo

Identifique o que o usuário quer e siga a seção correspondente:

| Pedido do usuário | Modo |
|---|---|
| Criar/montar um segundo cérebro, "quero que a IA lembre das coisas" | **1. Criar** |
| Já tem um cérebro (desta skill ou feito à mão, ex.: uma pasta com `Claude.md`) e quer adaptar | **1. Criar**, começando pela etapa de diagnóstico em modo *adotar* |
| "Salva isso no cérebro", "faz um checkpoint", fim de uma sessão longa | **2. Checkpoint** |
| Importar notas do Obsidian/Notion, documentos, um repositório, uma conversa | **3. Alimentar** |
| "Revisa/organiza meu cérebro", notas desatualizadas, cérebro bagunçado | **4. Manutenção** |
| Mudar nível de automação, adicionar outra ferramenta de IA | **5. Ajustar** |

---

## Modo 1 — Criar

O fluxo tem seis etapas. Não pule a aprovação do plano (etapa 3): é ela que garante que o usuário é quem decide.

### Etapa 1: Diagnóstico silencioso

Antes de perguntar qualquer coisa, descubra o que der para descobrir sozinho — cada pergunta evitada é atrito a menos para o usuário:

- Sistema operacional e pasta do usuário.
- Ferramentas de IA instaladas: existe `~/.claude/`? `~/.claude/CLAUDE.md`? `~/.codex/`? `~/.gemini/`? Cursor?
- Já existe um cérebro? Procure por pastas com `CEREBRO.md`, `Claude.md`, `AGENTS.md` ou `.cerebro/config.json` em lugares óbvios (Documentos, Desktop, raiz de discos). Se o usuário mencionar um, leia o arquivo raiz dele.
- Existe um vault do Obsidian (pasta com `.obsidian/`)?
- Há `bash` disponível (necessário para os scripts de automação; no Windows vem com o Git for Windows, que o Claude Code já exige)?

Se encontrar um cérebro existente, entre em **modo adotar**: o objetivo passa a ser preservar o que o usuário já fez, mapear a estrutura dele para os conceitos desta skill (ex.: o `Claude.md` dele faz o papel do `CEREBRO.md`) e propor só o que falta. Nunca sobrescreva notas existentes.

### Etapa 2: Entrevista

Leia `references/entrevista.md` para o banco de perguntas completo. Pontos essenciais:

- Ofereça dois caminhos logo no início: **rápido** (5 perguntas, o resto com padrões sensatos) ou **completo** (todos os blocos). Usuários comuns geralmente preferem o rápido.
- Faça no máximo 3–4 perguntas por rodada. Se a ferramenta `AskUserQuestion` (ou equivalente de múltipla escolha) estiver disponível, use-a — clicar é mais fácil do que digitar.
- Não pergunte o que o diagnóstico já respondeu; apenas confirme ("Vi que você usa o Claude Code e o Cursor, certo?").
- Adapte a linguagem ao nível técnico do usuário. Para quem não é técnico, evite termos como "hook", "frontmatter", "JSON" sem explicar em uma frase.
- Conduza a entrevista no idioma do usuário; o cérebro será criado nesse idioma.

### Etapa 3: Plano de ação (o usuário escolhe)

Com as respostas, monte o plano usando `references/plano-template.md` e `references/arquiteturas.md`. O plano precisa conter:

1. Resumo do que você entendeu (perfil, usos, ferramentas).
2. **Opções para o usuário escolher**, com sua recomendação marcada e o motivo:
   - a estrutura de pastas (ex.: *Por assunto* vs. *PARA*), mostrada como árvore;
   - o nível de automação (1 Manual, 2 Conectado, 3 Automático), explicando em linguagem simples o que cada um faz e o que ele toca no computador.
3. A lista exata de arquivos que serão criados **dentro** do cérebro.
4. A lista exata de arquivos **fora** do cérebro que serão alterados (com a informação de que haverá backup).
5. O conteúdo inicial que será semeado (perfil, projetos atuais, importação).
6. O que o usuário precisará fazer manualmente (ex.: colar uma regra nas configurações do Cursor).
7. Como desfazer tudo.

Apresente o plano e **espere a aprovação** (ou as escolhas) do usuário. Ajuste e reapresente quantas vezes for necessário.

### Etapa 4: Execução

Depois da aprovação, execute nesta ordem, informando o progresso:

1. **Estrutura**: crie as pastas escolhidas. Crie só as pastas que terão conteúdo agora ou que fazem parte do núcleo (`Inbox/`, `Diario/`, `Templates/`, `.cerebro/`) — pastas vazias confundem a IA e o usuário.
2. **Arquivos-núcleo** a partir de `assets/templates/`:
   - `CEREBRO.md` ← `assets/templates/CEREBRO.md`, preenchido com as regras de conduta, o idioma, o mapa real e o protocolo de alimentação no nível de autonomia escolhido. Mantenha-o abaixo de ~150 linhas: ele é carregado toda sessão.
   - `AGORA.md` ← `assets/templates/AGORA.md`.
   - `Perfil/Sobre-mim.md` e `Perfil/Preferencias.md` ← respostas da entrevista.
   - `Templates/` ← copie os modelos de nota (projeto, decisão, pesquisa, diário, ideia).
   - `.cerebro/config.json` ← registre caminho, idioma, estrutura, nível, ferramentas integradas, data de criação e a versão da skill. Os modos 4 e 5 leem este arquivo para saber o que foi montado.
3. **Integrações** conforme o nível escolhido — siga `references/integracoes.md`. Para o nível 3, copie os scripts de `scripts/` para `.cerebro/scripts/` dentro do cérebro (assim o cérebro não depende da skill continuar instalada) e faça o *merge* do trecho de hooks em `~/.claude/settings.json` sem apagar o que já existe. Faça backup do arquivo antes (`settings.json.bak-AAAA-MM-DD`).
4. **Versionamento** (se escolhido): `git init` na pasta do cérebro, `.gitignore` com `.cerebro/state/`, primeiro commit. Se o usuário quiser um remoto, recomende repositório **privado**.

### Etapa 5: Semear o conteúdo inicial

Um cérebro vazio não ajuda ninguém. Semeie com o que já é valioso:

- Uma nota `Indice.md` para cada projeto/assunto ativo que o usuário citou, com a seção "Estado atual" preenchida com o que ele contou.
- `AGORA.md` com o foco atual e as pendências mencionadas.
- Se o usuário pediu importação (Obsidian, pasta de documentos, README de projetos), siga o **Modo 3**.
- A primeira entrada em `Diario/` registrando a criação do cérebro e as escolhas feitas. Salve também o plano aprovado em `.cerebro/plano-de-criacao.md` para referência futura.

### Etapa 6: Validar e ensinar

1. Rode `bash scripts/brain-lint.sh <pasta-do-cerebro>` e corrija o que ele apontar.
2. Se instalou hooks, rode o script de início de sessão manualmente (`echo '{}' | bash <cerebro>/.cerebro/scripts/session-start.sh <cerebro>`) e confira se a saída é o contexto esperado e é curta.
3. Entregue ao usuário um **guia de uso de uma tela**: onde fica o cérebro, o que acontece automaticamente, as 3–4 frases úteis ("salva no cérebro", "o que tem no AGORA?", "revisa o cérebro") e como abrir no Obsidian se quiser.
4. Sugira um teste real: abrir uma sessão nova e perguntar "no que eu estava trabalhando?".

---

## Modo 2 — Checkpoint

O checkpoint é o que impede a perda de contexto: ele transforma o que está só na conversa em notas. Siga `references/alimentacao.md` (seção *Checkpoint*). Em resumo:

1. Leia o `CEREBRO.md` e o `AGORA.md` para saber onde as coisas ficam.
2. Revise a conversa desde o último checkpoint e extraia apenas o que vale guardar: decisões (com o motivo), mudanças de estado, pendências, descobertas, preferências novas do usuário.
3. Atualize — nesta ordem — as notas de decisão, o "Estado atual" do `Indice.md` do assunto, o `AGORA.md` e uma entrada curta no `Diario/AAAA-MM-DD.md`.
4. Informe ao usuário em 2–4 linhas o que foi registrado e onde.

Se a conversa não produziu nada que valha guardar, diga isso em vez de criar notas vazias.

## Modo 3 — Alimentar (importar)

Leia `references/importar.md`. A ideia central: **importar não é copiar**. Um vault do Obsidian com 2.000 notas copiado inteiro vira ruído. Faça uma triagem, proponha o que entra (resumido, reorganizado e com frontmatter), o que vira só um link para a fonte original e o que fica de fora — e deixe o usuário aprovar antes.

## Modo 4 — Manutenção

Leia `references/manutencao.md`. Rode `scripts/brain-lint.sh`, apresente o relatório em linguagem simples e proponha as correções (consolidar duplicatas, arquivar o que está parado, encolher o `CEREBRO.md`/`AGORA.md` se cresceram demais, esvaziar a `Inbox/`). Aplique só o que o usuário aprovar.

## Modo 5 — Ajustar

Leia `.cerebro/config.json` para saber o estado atual, pergunte o que o usuário quer mudar, mostre o plano da mudança (o que entra, o que sai, que arquivos serão tocados), aplique após aprovação e atualize o `config.json`.

---

## Arquivos de referência

| Arquivo | Quando ler |
|---|---|
| `references/entrevista.md` | Etapa 2 do Modo 1 |
| `references/arquiteturas.md` | Etapa 3 do Modo 1 (estruturas de pastas e níveis de automação) |
| `references/plano-template.md` | Etapa 3 do Modo 1 (formato do plano) |
| `references/integracoes.md` | Etapa 4 do Modo 1 e Modo 5 (Claude Code, Claude Desktop, Cursor, Codex, Gemini, ChatGPT) |
| `references/alimentacao.md` | Ao escrever o protocolo no `CEREBRO.md` e no Modo 2 |
| `references/importar.md` | Modo 3 |
| `references/manutencao.md` | Modo 4 |
| `assets/templates/*` | Modelos dos arquivos criados no cérebro |
| `assets/hooks/claude-settings.json` | Trecho de hooks para `~/.claude/settings.json` (nível 3) |
| `scripts/session-start.sh` | Hook: injeta o contexto quente no início da sessão e após compactação |
| `scripts/checkpoint-stop.sh` | Hook: pede um checkpoint quando a conversa cresceu muito desde o último |
| `scripts/brain-lint.sh` | Verificação de saúde do cérebro |
