# Manutenção do cérebro

Um cérebro sem manutenção cresce até ficar caro de ler e passa a ter informação velha que engana a IA. A manutenção mantém o contexto quente pequeno e o conteúdo confiável.

## 1. Rodar a verificação

```bash
bash scripts/brain-lint.sh <CEREBRO> [dias-para-considerar-parado]
```

O script aponta:
- `CEREBRO.md` ou `AGORA.md` maiores que o recomendado (custam tokens em toda sessão);
- notas sem frontmatter;
- notas com `atualizado:` antigo (padrão: 60 dias);
- itens parados na `Inbox/` há mais de 14 dias;
- links (Markdown ou `[[wikilinks]]`) que apontam para notas inexistentes;
- possíveis segredos (padrões como `api_key`, `senha:`, `sk-`, `ghp_`).

## 2. Revisão com julgamento (o que o script não vê)

- **Duplicatas de assunto:** duas notas falando da mesma coisa com nomes diferentes → propor fundir.
- **Decisões contraditórias:** uma decisão nova que substitui uma antiga sem que a antiga esteja marcada como `substituida`.
- **"Estado atual" desatualizado:** compare com o diário recente e com o git do projeto, se houver.
- **`Perfil/Preferencias.md` com regras conflitantes:** perguntar ao usuário qual vale.
- **Projetos parados:** propor mover para `Arquivo/` e tirar do `AGORA.md`.
- **Inbox:** para cada item, propor destino (nota existente, nota nova, arquivo ou descarte).
- **Diário antigo:** entradas de meses anteriores podem ser condensadas em `Diario/AAAA-MM-resumo.md`.

## 3. Apresentar e aplicar

Mostre um relatório curto em linguagem simples, agrupado por prioridade (o que custa tokens ou pode enganar a IA primeiro). Aplique só o que o usuário aprovar e registre a manutenção no diário.

Sugira ao usuário uma frequência (ex.: mensal) e, se a ferramenta dele tiver tarefas agendadas, ofereça agendar um lembrete.
