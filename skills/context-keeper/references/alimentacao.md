# Protocolo de alimentação

Este é o coração do segundo cérebro: as regras que fazem a IA registrar informação valiosa sem o usuário pedir. Uma versão resumida deste protocolo vai **dentro do `CEREBRO.md`** de cada cérebro (ver o modelo em `assets/templates/CEREBRO.md`), adaptada ao nível de autonomia escolhido.

## O que vale guardar

A pergunta-filtro é: **"Se eu abrir uma sessão nova daqui a um mês, sem esta conversa, essa informação me faria agir melhor?"**

Vale guardar:
- **Decisões e o motivo delas**, incluindo as alternativas descartadas. O motivo é o que mais se perde e o que mais evita retrabalho.
- **Estado de cada trabalho**: o que foi feito, o que falta, onde parou, o que está bloqueado.
- **Descobertas**: algo que deu trabalho para descobrir (a causa de um bug estranho, uma limitação de uma API, um dado de pesquisa com fonte).
- **Preferências e correções do usuário**: "não use X", "prefiro respostas curtas", "sempre rode os testes antes".
- **Contexto de pessoas e fatos estáveis**: quem é quem, prazos, restrições.
- **Ideias soltas** que o usuário mencionou de passagem (vão para a `Inbox/`).

Não vale guardar:
- O que já está no código, no README ou no git (o *como*).
- Transcrições ou resumos longos da conversa — guarde a conclusão, não o caminho.
- Informação temporária que perde valor em horas.
- **Segredos** de qualquer tipo.

## Gatilhos: quando escrever

| Gatilho | Onde registrar |
|---|---|
| Uma decisão foi tomada | `Decisoes/AAAA-MM-DD-titulo.md` do assunto + uma linha em "Últimas decisões" do `AGORA.md` |
| Uma tarefa/etapa foi concluída ou mudou de status | "Estado atual" do `Indice.md` do assunto |
| O usuário corrigiu a IA ou declarou uma preferência | `Perfil/Preferencias.md` |
| O usuário disse "anota", "lembra disso", "guarda isso" | Nota certa, se for óbvio; senão `Inbox/` |
| Uma pesquisa produziu conclusões | Nota de pesquisa no assunto (ou em `Pesquisa/` se servir a vários) |
| Assunto novo surgiu | `Inbox/` + propor pasta nova ao usuário |
| Fim de sessão, contexto longo, ou o hook pediu | **Checkpoint** completo (abaixo) |

## Níveis de autonomia ao escrever

O usuário escolheu um destes na entrevista; escreva no `CEREBRO.md` só o escolhido:
- **Perguntar antes:** "Posso registrar a decisão X em `Y`?" — e só escrever após o sim.
- **Escrever e avisar (padrão):** escrever e dizer em uma linha no fim da resposta: `🧠 Registrado: decisão X em Projetos/Y/Decisoes/...`.
- **Silencioso:** escrever sem avisar; listar tudo apenas no checkpoint.

## Checkpoint

O checkpoint consolida a sessão no cérebro. É o que salva o contexto antes de uma compactação ou do fim da conversa.

1. Leia `CEREBRO.md` e `AGORA.md` (se não estiverem no contexto).
2. Revise a conversa desde o último checkpoint e liste: decisões, mudanças de estado, pendências novas ou resolvidas, descobertas, preferências.
3. Atualize, nesta ordem:
   1. notas de decisão (novas ou com status alterado);
   2. "Estado atual" do `Indice.md` de cada assunto tocado — reescreva a seção, não acumule histórico nela (o histórico vai para o diário);
   3. `AGORA.md` — foco, pendências e últimas decisões; mantenha curto, removendo o que ficou velho;
   4. `Perfil/Preferencias.md`, se houver algo novo;
   5. `Diario/AAAA-MM-DD.md` — acrescente uma entrada de 3–8 linhas: assunto, o que foi feito, decisões (com link), próximo passo.
4. Atualize o campo `atualizado:` do frontmatter das notas tocadas.
5. Diga ao usuário, em 2–4 linhas, o que foi registrado.

Se nada relevante aconteceu desde o último checkpoint, não crie entradas vazias — apenas diga que não há o que registrar.

## Formato do "Estado atual"

Mantenha sempre esta forma, para ser lida rápido por qualquer IA:

```markdown
## Estado atual
*Atualizado em AAAA-MM-DD*

- **Fase:** <ideia | planejamento | em andamento | pausado | concluído>
- **Feito recentemente:** <1–3 itens>
- **Próximo passo:** <a próxima ação concreta>
- **Bloqueios / dúvidas em aberto:** <itens ou "nenhum">
```
