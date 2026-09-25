# Context Keeper

Read in English: [README.md](README.md)

> Um plugin do Claude Code que monta, na sua máquina, um segundo cérebro **feito para a IA** — e que se alimenta sozinho.

Toda IA esquece. Depois de muitas mensagens, o contexto é compactado e os detalhes somem. Numa conversa nova, você explica tudo de novo. Muita gente tenta resolver isso com Obsidian ou Notion, mas eles foram feitos para **humanos** navegarem: a IA não sabe que o vault existe, não sabe o que ler primeiro e não sabe quando deve escrever.

O Context Keeper resolve isso. Ele entrevista você, propõe um plano (**você escolhe**) e monta:

- **Um ponto de entrada** que a IA carrega em toda sessão, em qualquer pasta.
- **Regras de alimentação**: a IA registra decisões, estado dos projetos, descobertas e as suas preferências sem você precisar pedir.
- **Automação** (Claude Code): o contexto é recarregado logo após cada compactação, e a IA é lembrada de fazer um *checkpoint* quando a conversa fica longa.

Tudo em Markdown puro, numa pasta comum do seu computador.

### E o Obsidian?

Não é necessário. A IA lê e escreve os arquivos direto do disco e não abre o Obsidian como uma pessoa faria, então para ela o Obsidian não muda nada. Por isso o padrão recomendado é **uma pasta simples**. Se você gosta do Obsidian para navegar pelas notas, a skill oferece essa opção e explica como configurar — e dá para abrir a pasta no Obsidian depois, a qualquer momento.

## Como funciona

```
       toda sessão              ao entrar num assunto          só quando precisa
 +------------------------+    +-------------------------+    +-----------------------+
 | QUENTE  (~2k tokens)   | -> | MORNA                   | -> | FRIA                  |
 | CEREBRO.md  regras     |    | Projetos/X/Indice.md    |    | Decisoes/, Pesquisa/  |
 | AGORA.md    estado     |    | "Estado atual"          |    | Diario/, Arquivo/     |
 +------------------------+    +-------------------------+    +-----------------------+
            ^                                                              |
            +--------------- checkpoint: a IA atualiza as notas <----------+
```

| Nível | O que faz | Ferramentas |
|---|---|---|
| 1 Manual | Estrutura e regras. A IA usa o cérebro quando você pede. | Qualquer uma |
| 2 Conectado | A IA carrega o cérebro sozinha em toda sessão e segue as regras de alimentação. | Claude Code, Codex, Gemini CLI, Cursor, Claude Desktop |
| 3 Automático | O nível 2, mais o contexto recarregado após a compactação e pedidos automáticos de checkpoint. | Claude Code |

## Instalação

**Claude Code (recomendado: como plugin).** Numa sessão do Claude Code:

```
/plugin marketplace add MenesesLuiz/Context-Keeper
/plugin install context-keeper@context-keeper
```

O plugin traz a skill, os atalhos `/context-keeper:checkpoint` e `/context-keeper:review` e os hooks de automação. Os hooks ficam inativos até você criar o seu cérebro.

**Claude Code (como skill avulsa).** Copie `skills/context-keeper/` para `~/.claude/skills/`. Tudo funciona, mas a automação do nível 3 exige que a skill edite o seu `~/.claude/settings.json` (com backup).

**Claude.ai / Claude Desktop.** Compacte a pasta `skills/context-keeper/` em `.zip` e envie em *Configurações → Capacidades → Skills*. Esses apps não têm hooks, então o cérebro funciona até o nível 2.

## Uso

Numa conversa, diga algo como:

- *"Quero montar um segundo cérebro para você não esquecer das coisas."*
- *"Salva no cérebro o que a gente decidiu hoje."*
- *"Importa meu vault do Obsidian para o cérebro."*
- *"Revisa meu segundo cérebro."*

A entrevista acontece em português, e o cérebro é criado com nomes em português.

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
└── .context-keeper/  configuração e estado dos hooks
```

## Privacidade

Tudo fica **no seu computador**. A skill não envia nada para lugar nenhum, faz backup de qualquer arquivo de configuração antes de alterá-lo e orienta a IA a **nunca** registrar senhas, tokens ou chaves. Se você versionar o cérebro com git, use um repositório **privado**.

## Licença

[MIT](LICENSE)

O plano de evolução está no [ROADMAP.md](ROADMAP.md) (em inglês).
