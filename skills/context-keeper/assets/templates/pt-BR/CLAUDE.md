<!--
MODELO — a skill preenche os campos {{...}} e remove este comentário.
Mantenha o arquivo final abaixo de ~150 linhas: ele é carregado em TODA sessão.
Links: o modelo usa links Markdown com caminho relativo (padrão). Se o usuário escolheu
wikilinks (Obsidian), converta [Texto](caminho/Nota.md) em [[Nota]] ao preencher.
-->
# Segundo cérebro de {{NOME}}: escopo global

Este arquivo é o ponto de partida de toda sessão. Ele define **como agir**, **como navegar** e **onde cada coisa está**. É neutro de propósito: não descreve nem favorece nenhum assunto. O contexto de cada área ou projeto fica dentro da pasta dele e só entra em jogo quando aquele assunto estiver sendo trabalhado.

## 1. Propósito

Guardar o que não cabe no código nem no histórico de conversas: decisões e seus motivos, o estado de cada trabalho, descobertas, preferências de {{NOME}} e ideias. Assim nenhuma sessão começa do zero.

- **Ler antes de agir:** este arquivo e, depois, a nota principal (`Indice.md`) do assunto em questão.
- **Registrar depois de decidir:** ver a seção 6.
- **Não duplicar:** procurar se já existe nota sobre o assunto e atualizar essa.
- **Datas absolutas:** sempre `AAAA-MM-DD`.
- **O cérebro guarda o porquê;** o código e o git guardam o como.
- **Nunca registrar segredos** (senhas, tokens, chaves). Se aparecer um, avisar {{NOME}}.
- **Texto simples, sem emojis**, nas notas e nos avisos de registro.

## 2. Regras de conduta

{{REGRAS_DE_CONDUTA}}
<!-- Exemplo:
1. Planejar antes de executar tarefas grandes; pedir aprovação.
2. Perguntar quando houver dúvida real em vez de supor.
3. Não sair do escopo pedido; sugestões extras vão como proposta.
4. Idioma: português do Brasil.
-->

Preferências detalhadas: [Preferências](Perfil/Preferencias.md).

## 3. Como navegar

1. **Começar aqui.** Ler este arquivo.
2. **Identificar o assunto** do pedido: qual área, projeto ou ideia?
3. **Achar a pasta no mapa** (seção 4). Não procurar pastas no disco: o mapa diz onde tudo está.
4. **Entrar na pasta e ler a nota principal** (`Indice.md`). Só a partir daí considerar o contexto daquele assunto.
5. **Seguir os links** da nota principal conforme a necessidade, sem ler a pasta inteira sem motivo.
6. **"No que eu estava trabalhando?"** Ler [AGORA](AGORA.md) e a última entrada do `Diario/`.
7. **Ao terminar,** atualizar as notas afetadas (seção 6).

Se o assunto não tiver pasta, registrar na `Inbox/` e propor a criação a {{NOME}}. Toda pasta nova, criada pela IA ou por {{NOME}}, entra no mapa na hora.

## 4. Mapa

### Atual

Gerado a partir das pastas reais: não editar à mão entre os marcadores. Para atualizar, usar `/context-keeper:map` ou pedir "atualiza o mapa". A descrição de cada pasta vem do campo `descricao:` do `Indice.md` dela.

<!-- context-keeper:map:start -->
```
(o mapa aparece aqui na primeira atualização)
```
<!-- context-keeper:map:end -->

### Planejada

{{ESTRUTURA_PLANEJADA_OU_REMOVER_ESTA_SECAO}}

Criar cada pasta só quando houver conteúdo para ela. Cada projeto fica numa pasta própria dentro de `Projetos/`, com o `Indice.md`, as `Decisoes/` e os arquivos do próprio projeto (o código numa subpasta).

## 5. Convenções

- Nomes de arquivo e pasta sem acento, com hífen no lugar de espaço (`Visao-Geral.md`).
- Links entre notas: {{CONVENCAO_DE_LINKS}}.
- Uma nota por assunto. Nota grande demais: dividir e ligar as partes com links.
- Frontmatter no topo de cada nota:

```yaml
---
tipo: area | projeto | decisao | pesquisa | ideia | diario
status: ideia | planejamento | em-andamento | pausado | concluido
descricao: o que é esta pasta, em uma linha neutra (só no Indice.md)
criado: AAAA-MM-DD
atualizado: AAAA-MM-DD
tags: []
---
```

Modelos de nota em `Templates/`.

## 6. Protocolo de alimentação

Filtro: *"Numa sessão nova, daqui a um mês, isto me faria agir melhor?"* Se sim, registre.

| Quando | Onde |
|---|---|
| Uma decisão foi tomada | `<assunto>/Decisoes/AAAA-MM-DD-titulo.md` |
| Algo foi concluído ou mudou de status | "Estado atual" do `Indice.md` do assunto + [AGORA](AGORA.md) |
| Uma pasta foi criada (pela IA ou por {{NOME}}) | Mapa (seção 4) + `Indice.md` com `descricao:` |
| {{NOME}} corrigiu algo ou declarou uma preferência | [Preferências](Perfil/Preferencias.md) |
| {{NOME}} disse "anota", "lembra disso" | Nota certa ou `Inbox/` |
| Os arquivos de um projeto estão fora do cérebro | "Onde estão as coisas" no `Indice.md` + sugerir mover para `Projetos/` ({{NOME}} move, nunca a IA) |
| Fim de sessão, conversa longa ou pedido de checkpoint | **Checkpoint** (abaixo) |

Não registrar: o que já está no código/git, transcrições, informação que perde valor em horas.

**Autonomia:** {{AUTONOMIA}}
<!-- Uma destas:
- Perguntar antes de escrever qualquer nota.
- Escrever e avisar em uma linha no fim da resposta: "Registrado: <o quê> em <onde>".
- Escrever sem avisar e listar tudo só no checkpoint.
-->

**Checkpoint** — atualizar, nesta ordem: (1) notas de decisão; (2) "Estado atual" dos assuntos tocados, reescrevendo a seção; (3) [AGORA](AGORA.md), mantendo-o curto; (4) [Preferências](Perfil/Preferencias.md), se houver algo novo; (5) uma entrada de 3–8 linhas em `Diario/AAAA-MM-DD.md`. Atualizar o campo `atualizado:` das notas tocadas. Se não houve nada relevante, não criar entradas vazias.

## 7. Decisões

Uma nota por decisão, a partir de `Templates/Decisao.md`: contexto, opções consideradas, escolha, motivo e consequências. Decisão substituída: marcar `status: substituida` e linkar a nova. Nunca apagar.
