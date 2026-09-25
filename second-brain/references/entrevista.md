# Banco de perguntas da entrevista

Objetivo: coletar o mínimo necessário para propor um plano bom. Cada pergunta abaixo diz **por que existe** — se a resposta já é conhecida (pelo diagnóstico ou por algo que o usuário disse), pule-a.

Regras de condução:
- 3–4 perguntas por rodada, no máximo.
- Sempre que possível, ofereça opções clicáveis com uma recomendada, mais a opção de responder livremente.
- Explique termos técnicos em uma frase quando o usuário não for técnico.
- No fim, resuma as respostas em uma lista e peça confirmação antes de montar o plano.

---

## Caminho rápido (5 perguntas)

Use quando o usuário escolher "rápido". O resto recebe os padrões da tabela no fim deste arquivo.

1. **Para que você mais usa IA?** (múltipla escolha: programação, estudos/faculdade, trabalho/escritório, criação de conteúdo, pesquisa, vida pessoal/organização)
2. **Quais projetos ou assuntos estão ativos agora?** (texto livre: "liste 1 a 5, uma linha cada")
3. **Quais IAs você usa?** (confirmar o que o diagnóstico encontrou: Claude Code, Claude Desktop/claude.ai, Cursor, Codex, Gemini CLI, ChatGPT, outra)
4. **Onde salvar o cérebro?** (sugerir um caminho concreto; avisar se estiver dentro de OneDrive/Dropbox, que sincroniza — ótimo para backup, mas conflitos podem acontecer se duas máquinas editarem ao mesmo tempo)
5. **Quanto a IA pode fazer sozinha?** (Nível 1 Manual / 2 Conectado / 3 Automático — ver `arquiteturas.md`; recomendar o 3 para quem usa Claude Code, o 2 para os demais)

---

## Caminho completo

### Bloco A — Quem é você
*Por quê:* vira `Perfil/Sobre-mim.md`. É o contexto que toda IA deveria ter e nunca tem.

- Como prefere ser chamado?
- O que você faz (profissão, curso, área)?
- Nível técnico: não técnico / uso ferramentas / programo.
- Idioma do cérebro e das respostas.

### Bloco B — Para que o cérebro vai servir
*Por quê:* define as áreas de primeiro nível e a estrutura (ver `arquiteturas.md`).

- Usos principais (múltipla escolha, como no rápido).
- Projetos/assuntos ativos agora, com uma linha de status cada.
- Há áreas contínuas, sem prazo de término (ex.: saúde, finanças, carreira, uma disciplina da faculdade)? *Isso indica se a estrutura PARA vale a pena.*
- Com que frequência começa assuntos novos? *Muitos assuntos novos → a Inbox e a triagem ganham importância.*

### Bloco C — Ferramentas
*Por quê:* define as integrações.

- Quais IAs usa, e qual é a principal?
- Usa Obsidian, Notion, Google Docs, OneNote ou similar? Quer importar algo de lá? *Dispara o Modo 3.*
- Trabalha em mais de um computador? *Afeta a sincronização e os caminhos absolutos nos hooks.*

### Bloco D — Local, privacidade e backup
*Por quê:* evita perda de dados e vazamento.

- Onde salvar a pasta?
- Vai guardar informação sensível (saúde, finanças, dados de clientes)? *Se sim: reforçar a regra de não guardar segredos, recomendar não sincronizar com nuvem pública e, se usar git, só repositório privado.*
- Quer versionar com git (histórico de todas as mudanças, possibilidade de desfazer)? *Recomendar para usuários técnicos.*

### Bloco E — Autonomia da IA
*Por quê:* vira o protocolo de alimentação dentro do `CEREBRO.md`.

- Nível de automação (1/2/3).
- Quando a IA quiser registrar algo, ela deve:
  - **perguntar antes** de escrever;
  - **escrever e avisar** em uma linha (recomendado);
  - **escrever em silêncio** e só mostrar no checkpoint.
- A IA pode criar pastas novas sozinha, ou deve propor antes? (recomendado: propor)

### Bloco F — Como você gosta de trabalhar com IA
*Por quê:* vira as "Regras de conduta" e `Perfil/Preferencias.md` — o tipo de coisa que o usuário se cansa de repetir.

- Prefere que a IA planeje e peça aprovação antes de executar, ou que execute direto?
- Respostas curtas ou detalhadas?
- Algo que a IA faz e te irrita? Algo que ela deveria sempre fazer?

### Bloco G — Material existente
*Por quê:* um cérebro que já nasce com conteúdo útil convence o usuário a continuar usando.

- Há anotações, documentos ou repositórios que deveriam alimentar o cérebro desde o início? Onde?
- Há conversas antigas importantes com IA (exportações do ChatGPT/Claude)? *Podem ser triadas no Modo 3.*

---

## Padrões para o caminho rápido

| Item | Padrão |
|---|---|
| Idioma | O da conversa |
| Estrutura | *Por assunto* se houver até ~3 áreas; *PARA* se houver áreas contínuas + projetos |
| Autonomia ao escrever | Escrever e avisar |
| Criar pastas | Propor antes |
| Conduta | Planejar e pedir aprovação para tarefas grandes; executar direto as pequenas |
| Git | Sim para usuários técnicos; não para os demais |
| Local | `~/SegundoCerebro` (Windows: `%USERPROFILE%\SegundoCerebro`) |
