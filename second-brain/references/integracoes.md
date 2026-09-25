# Integrações por ferramenta

Regra geral para qualquer arquivo fora do cérebro:
1. Se o arquivo existe, **leia-o** e faça backup (`<arquivo>.bak-AAAA-MM-DD`).
2. **Acrescente** o bloco do cérebro, delimitado por marcadores, sem apagar o que já existe:
   ```
   <!-- segundo-cerebro:inicio -->
   ...
   <!-- segundo-cerebro:fim -->
   ```
   Os marcadores permitem que o Modo 5 atualize ou remova o bloco depois.
3. Registre o arquivo alterado em `.cerebro/config.json` → `integracoes`.

Os caminhos e menus das ferramentas mudam com frequência. Se algo abaixo não bater com o que você encontrar no computador do usuário, confira a documentação atual da ferramenta antes de seguir.

Use `/` nos caminhos mesmo no Windows (ex.: `E:/SecondBrain`), porque os scripts rodam em bash.

---

## Claude Code

### Nível 2 — ponteiro global
Em `~/.claude/CLAUDE.md` (carregado em toda sessão, em qualquer pasta):

```markdown
<!-- segundo-cerebro:inicio -->
# Segundo cérebro
Meu segundo cérebro fica em `<CEREBRO>`. As regras de uso estão abaixo; siga-as em toda sessão.
@<CEREBRO>/CEREBRO.md
<!-- segundo-cerebro:fim -->
```

A linha `@caminho` importa o arquivo para o contexto. Para conferir se funcionou, o usuário pode rodar `/memory` numa sessão nova do Claude Code e ver o `CEREBRO.md` na lista.

> Observação: sem esse ponteiro global, o `CEREBRO.md` só é carregado quando o Claude Code é aberto dentro da própria pasta do cérebro — um erro comum em cérebros montados à mão.

### Nível 3 — hooks
1. Copie `scripts/*.sh` da skill para `<CEREBRO>/.cerebro/scripts/`.
2. Faça o merge de `assets/hooks/claude-settings.json` em `~/.claude/settings.json`, trocando `<CEREBRO>` pelo caminho real. Se já existirem hooks nos mesmos eventos, **acrescente** entradas ao array em vez de substituir.
3. Teste:
   ```bash
   echo '{"source":"startup"}' | bash "<CEREBRO>/.cerebro/scripts/session-start.sh" "<CEREBRO>"
   ```
   A saída deve ser curta e conter o `AGORA.md`.

O que cada hook faz:
- **SessionStart** (`session-start.sh`): roda ao abrir, retomar, limpar ou **compactar** a sessão. O que ele imprime entra no contexto da IA. Após uma compactação, acrescenta um aviso para a IA retomar pelo `AGORA.md`.
- **Stop** (`checkpoint-stop.sh`): roda quando a IA termina uma resposta. Se a transcrição cresceu mais que o limite (padrão ~300 KB) desde o último checkpoint, pede que a IA faça um checkpoint antes de parar. Tem proteção contra laço (`stop_hook_active`) e só dispara de novo após novo crescimento. O limite é ajustável pela variável `CEREBRO_CHECKPOINT_BYTES`.

---

## Claude Desktop (app de chat) e claude.ai

- **Claude Desktop:** ative a extensão de sistema de arquivos (Filesystem) nas configurações de extensões e dê acesso à pasta do cérebro. Depois, nas preferências pessoais do perfil (ou nas instruções de um Projeto), cole:
  > Tenho um segundo cérebro em `<CEREBRO>`. No início de cada conversa, leia `CEREBRO.md` e `AGORA.md` de lá e siga as regras do `CEREBRO.md`.
- **claude.ai na web:** não acessa arquivos locais. Opção possível: criar um Projeto e enviar `CEREBRO.md`, `AGORA.md` e `Perfil/` como conhecimento do projeto — mas é uma cópia estática, que precisa ser reenviada quando mudar. Deixe essa limitação clara para o usuário.

## Cursor

- **Global:** Cursor Settings → Rules → *User Rules*: cole o mesmo texto do Claude Desktop (a IA do Cursor lê arquivos pelo caminho absoluto). Esse passo é manual — liste-o no plano como tarefa do usuário.
- **Por projeto:** o Cursor também lê `AGENTS.md` na raiz do projeto e regras em `.cursor/rules/`. Só crie arquivos em repositórios do usuário se ele pedir.

## OpenAI Codex CLI

Arquivo global `~/.codex/AGENTS.md`: acrescente o bloco com marcadores apontando para `<CEREBRO>/CEREBRO.md` e pedindo que a IA o leia no início da sessão.

## Gemini CLI

Arquivo global `~/.gemini/GEMINI.md`: mesmo bloco do Codex.

## GitHub Copilot

Instruções são por repositório (`.github/copilot-instructions.md`). Só configure se o usuário pedir, repositório por repositório.

## ChatGPT (web/app)

Não lê arquivos locais. Opções, todas manuais:
- Colar o conteúdo de `Perfil/Sobre-mim.md` e `Perfil/Preferencias.md` nas instruções personalizadas.
- Em conversas importantes, colar o `AGORA.md` no início e, ao fim, pedir um resumo no formato de checkpoint para colar no cérebro (ou pedir a outra IA com acesso aos arquivos que registre).

Seja honesto com o usuário: nessas ferramentas o cérebro funciona no nível 1.
