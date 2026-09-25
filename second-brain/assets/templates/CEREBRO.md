<!--
MODELO — a skill preenche os campos {{...}} e remove este comentário.
Mantenha o arquivo final abaixo de ~150 linhas: ele é carregado em TODA sessão.
-->
# Segundo Cérebro de {{NOME}}

Este arquivo é o ponto de partida de toda sessão. Ele diz **como agir**, **onde as coisas ficam** e **quando registrar**. O estado atual do trabalho fica em [[AGORA]].

## 1. Para que serve

Guardar o que não cabe no código nem no histórico de conversas: decisões e seus motivos, o estado de cada trabalho, descobertas, preferências de {{NOME}} e ideias. Assim nenhuma sessão começa do zero.

- **Ler antes de agir:** este arquivo, depois o [[AGORA]], depois o `Indice.md` do assunto em questão.
- **Registrar depois de decidir:** ver seção 5.
- **Não duplicar:** procurar se já existe nota sobre o assunto e atualizar essa.
- **Datas absolutas:** sempre `AAAA-MM-DD`.
- **O cérebro guarda o porquê;** o código e o git guardam o como.
- **Nunca registrar segredos** (senhas, tokens, chaves). Se aparecer um, avisar {{NOME}}.

## 2. Regras de conduta

{{REGRAS_DE_CONDUTA}}
<!-- Exemplo:
1. Planejar antes de executar tarefas grandes; pedir aprovação.
2. Perguntar quando houver dúvida real em vez de supor.
3. Não sair do escopo pedido; sugestões extras vão como proposta.
4. Idioma: português do Brasil.
-->

Preferências detalhadas: [[Preferencias]].

## 3. Como navegar

1. Ler este arquivo e o [[AGORA]].
2. Identificar o assunto do pedido.
3. Abrir o `Indice.md` da pasta do assunto e ler a seção "Estado atual".
4. Seguir os `[[links]]` conforme a necessidade, sem ler pastas inteiras sem motivo.
5. Se o assunto não tiver pasta, registrar na `Inbox/` e propor a criação a {{NOME}}.

## 4. Mapa

```
{{ARVORE_DE_PASTAS}}
```

Convenções: nomes de arquivo sem acento e com hífen (`Visao-Geral.md`); links `[[Nome-da-Nota]]`; frontmatter no topo de cada nota:

```yaml
---
tipo: projeto | area | decisao | pesquisa | ideia | diario
status: ideia | planejamento | em-andamento | pausado | concluido
criado: AAAA-MM-DD
atualizado: AAAA-MM-DD
tags: []
---
```

Modelos de nota em `Templates/`.

## 5. Protocolo de alimentação

Filtro: *"Numa sessão nova, daqui a um mês, isto me faria agir melhor?"* Se sim, registre.

| Quando | Onde |
|---|---|
| Uma decisão foi tomada | `<assunto>/Decisoes/AAAA-MM-DD-titulo.md` + "Últimas decisões" do [[AGORA]] |
| Algo foi concluído ou mudou de status | "Estado atual" do `Indice.md` do assunto |
| {{NOME}} corrigiu algo ou declarou uma preferência | [[Preferencias]] |
| {{NOME}} disse "anota", "lembra disso" | Nota certa ou `Inbox/` |
| Uma pesquisa gerou conclusões | Nota de pesquisa do assunto |
| Fim de sessão, conversa longa ou pedido de checkpoint | **Checkpoint** (abaixo) |

Não registrar: o que já está no código/git, transcrições, informação que perde valor em horas.

**Autonomia:** {{AUTONOMIA}}
<!-- Uma destas:
- Perguntar antes de escrever qualquer nota.
- Escrever e avisar em uma linha no fim da resposta: "🧠 Registrado: <o quê> em <onde>".
- Escrever sem avisar e listar tudo só no checkpoint.
-->

**Checkpoint** — atualizar, nesta ordem: (1) notas de decisão; (2) "Estado atual" dos assuntos tocados, reescrevendo a seção; (3) [[AGORA]], mantendo-o curto; (4) [[Preferencias]], se houver algo novo; (5) uma entrada de 3–8 linhas em `Diario/AAAA-MM-DD.md`. Atualizar o campo `atualizado:` das notas tocadas. Se não houve nada relevante, não criar entradas vazias.

## 6. Decisões

Uma nota por decisão, a partir de `Templates/Decisao.md`. Decisão substituída: marcar `status: substituida` e linkar a nova. Nunca apagar.
