# 🧠 Segundo Cérebro para IA

> Uma skill que monta, na sua máquina, um segundo cérebro **feito para a IA** — e que se alimenta sozinho.

Toda IA esquece. Depois de muitas mensagens, o contexto é compactado e os detalhes somem. Numa conversa nova, você explica tudo de novo. Muita gente tenta resolver isso com Obsidian ou Notion, mas eles foram feitos para **humanos** navegarem: a IA não sabe que o vault existe, não sabe o que ler primeiro e não sabe quando deve escrever.

Esta skill resolve isso. Ela entrevista você, propõe um plano (**você escolhe**) e monta:

- **Um ponto de entrada** que a IA carrega em toda sessão, em qualquer pasta.
- **Regras de alimentação**: a IA registra decisões, estado dos projetos, descobertas e as suas preferências sem você precisar pedir.
- **Automação** (Claude Code): o contexto é reinjetado logo após cada compactação, e a IA é lembrada de fazer um *checkpoint* quando a conversa fica longa.

Tudo em Markdown puro, compatível com o Obsidian — que continua funcionando como visualizador, se você quiser.

## Como funciona

```
         toda sessão                ao entrar num assunto          só quando precisa
   ┌──────────────────────┐      ┌───────────────────────┐     ┌──────────────────────┐
   │  QUENTE  (~2k tokens)│ ───▶ │  MORNA                │ ──▶ │  FRIA                │
   │  CEREBRO.md  regras  │      │  Projetos/X/Indice.md │     │  Decisoes/, Pesquisa/│
   │  AGORA.md    estado  │      │  "Estado atual"       │     │  Diario/, Arquivo/   │
   └──────────────────────┘      └───────────────────────┘     └──────────────────────┘
            ▲                                                             │
            └────────────── checkpoint: a IA atualiza as notas ◀──────────┘
```

| Nível | O que faz | Ferramentas |
|---|---|---|
| 1 · Manual | Estrutura + regras. A IA usa o cérebro quando você pede. | Qualquer uma |
| 2 · Conectado | A IA carrega o cérebro sozinha em toda sessão e segue o protocolo de alimentação. | Claude Code, Codex, Gemini CLI, Cursor, Claude Desktop |
| 3 · Automático | + contexto reinjetado após compactação + pedido automático de checkpoint. | Claude Code |

## Instalação

**Claude Code** — copie a pasta `second-brain/` para a sua pasta de skills:

```bash
git clone https://github.com/<seu-usuario>/<este-repo>.git
cp -r <este-repo>/second-brain ~/.claude/skills/
```

**Claude.ai / Claude Desktop** — compacte a pasta `second-brain/` em `.zip` e envie em *Configurações → Capacidades → Skills*.

## Uso

Numa conversa, diga algo como:

- *"Quero montar um segundo cérebro para você não esquecer das coisas."*
- *"Salva no cérebro o que a gente decidiu hoje."*
- *"Importa meu vault do Obsidian para o cérebro."*
- *"Revisa meu segundo cérebro."*

## O que é criado

```
SegundoCerebro/
├── CEREBRO.md        regras, mapa e protocolo de alimentação
├── AGORA.md          foco atual, pendências, últimas decisões
├── Perfil/           quem você é e como gosta que a IA trabalhe
├── Projetos/<X>/     Indice.md (Estado atual) + Decisoes/
├── Inbox/            capturas rápidas
├── Diario/           uma entrada por sessão relevante
├── Templates/        modelos de nota
├── Arquivo/          o que foi concluído (nada é apagado)
└── .cerebro/         config, scripts dos hooks, estado
```

## Privacidade

Tudo fica **no seu computador**. A skill não envia nada para lugar nenhum, faz backup de qualquer arquivo de configuração antes de alterá-lo e orienta a IA a **nunca** registrar senhas, tokens ou chaves. Se você versionar o cérebro com git, use um repositório **privado**.

## Estrutura do repositório

```
second-brain/
├── SKILL.md                 fluxo principal e modos
├── references/              entrevista, arquiteturas, plano, integrações, alimentação, importação, manutenção
├── assets/templates/        modelos dos arquivos do cérebro
├── assets/hooks/            trecho de hooks para o Claude Code
└── scripts/                 session-start.sh, checkpoint-stop.sh, brain-lint.sh
```

Veja o [ROADMAP.md](ROADMAP.md) para o que vem a seguir.
