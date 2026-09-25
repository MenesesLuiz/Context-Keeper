# Importar material existente

Importar **não é copiar**. O objetivo é que o cérebro fique mais útil para a IA, não maior. Um vault inteiro copiado vira ruído: a IA gasta tokens lendo o que não importa e deixa passar o que importa.

## Fluxo

1. **Inventário (sem alterar nada).** Liste a fonte: quantidade de arquivos, pastas, datas de modificação, tamanhos. Para vaults do Obsidian, ignore `.obsidian/`, `.trash/` e anexos binários.
2. **Triagem.** Classifique cada pasta (ou nota, se forem poucas) em:
   - **Trazer e reorganizar:** notas vivas e relevantes para os assuntos ativos. Entram na estrutura nova, com frontmatter, nome sem acento e links ajustados.
   - **Resumir:** muito material sobre um tema (ex.: 40 notas de aula) vira uma nota-síntese com os pontos-chave e um link para a pasta original.
   - **Apenas apontar:** material de referência grande que raramente será usado. Entra como um link no `Indice.md` do assunto para o caminho original.
   - **Deixar de fora:** notas vazias, rascunhos abandonados, duplicatas, material sem relação com o uso declarado.
   Use a data de modificação como pista: o que não é tocado há mais de um ano normalmente é "apontar" ou "deixar de fora".
3. **Proposta.** Apresente a triagem ao usuário em uma tabela (pasta → destino → ação) e espere a aprovação.
4. **Execução.** Nunca mova nem apague a fonte original — copie para o cérebro. Ao reescrever uma nota, acrescente `fonte: <caminho original>` no frontmatter.
5. **Registro.** Entrada no diário listando o que foi importado e de onde.

## Fontes comuns

- **Obsidian:** se o cérebro usa links Markdown (padrão), converta cada `[[Nota]]` e `[[Nota|texto]]` em `[texto](caminho/relativo/Nota.md)`, apontando para onde a nota ficou na estrutura nova. Se usa wikilinks, eles podem ficar como estão. Em qualquer caso, links para notas que não serão trazidas viram texto simples ou apontam para o caminho original. Anexos (`![[imagem.png]]`) só entram se forem necessários; nesse caso, vão para uma pasta `Anexos/`.
- **Notion:** a exportação em Markdown gera nomes com IDs longos (`Pagina 3f2a...md`); limpe os nomes.
- **Repositórios de código:** não copie código. Leia o README e o histórico recente e crie o `Indice.md` do projeto com visão geral, stack e "Estado atual"; aponte para o caminho do repositório.
- **Conversas exportadas de IA:** extraia só decisões, preferências e fatos estáveis usando o filtro de `alimentacao.md`. Conversas são longas e quase todo o conteúdo é caminho, não conclusão.
- **Documentos (PDF, DOCX):** crie uma nota-síntese com os pontos que importam para o usuário e o caminho do arquivo original.
