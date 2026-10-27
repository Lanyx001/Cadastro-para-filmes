# 🎬 Sistema de Gestão de Acervo Cinematográfico e Streaming

## 📌 Objetivo

O projeto consiste no desenvolvimento de um banco de dados relacional para gerenciar um acervo cinematográfico e suas relações com plataformas de exibição e streaming.

O sistema permite organizar filmes, episódios e gêneros, cadastrar atores e diretores, registrar o elenco e a direção das produções, controlar períodos de disponibilidade em plataformas e armazenar avaliações feitas pelos usuários.

O projeto foi desenvolvido para a disciplina de **Laboratório de Banco de Dados**, utilizando scripts SQL para criação da estrutura, inserção de dados e realização de consultas.

---

## 👥 Integrantes do Grupo

| Nome | Matrícula | GitHub |
|---|---|---|
| João Pedro Souza Pereira | UC25200260 | joaopsouza-dev |
| Kenzo Matsunaga | UC25200299 | kenzomats |
| Giulia de Melo | UC25200440 | Giu_ |
| Kaylane Martins | UC25200185 | Lanyx001 |

---

## 🚀 Funcionalidades do Banco de Dados

### 1. Gestão do acervo cinematográfico
- Cadastro de filmes com título, ano de lançamento, duração e status.
- Relacionamento entre filmes para representar sequências.
- Cadastro de episódios vinculados a filmes.
- Associação de filmes a diferentes gêneros.
- Identificação de filmes ativos e desativados.

### 2. Gestão de pessoas e ficha técnica
- Cadastro de pessoas e suas datas de nascimento.
- Especialização de pessoas como atores e diretores.
- Associação de atores a filmes, incluindo o personagem interpretado.
- Associação de diretores às produções.
- Possibilidade de uma mesma pessoa atuar e dirigir.

### 3. Plataformas e disponibilidade
- Cadastro de plataformas de exibição.
- Suporte aos tipos Streaming, Cinema, Canal TV e Mídia Física.
- Registro das datas de início e término da disponibilidade de filmes.
- Possibilidade de manter contratos sem data de término definida.

### 4. Usuários e avaliações
- Cadastro de usuários com e-mail único.
- Registro de notas entre 0,0 e 10,0.
- Armazenamento de comentários e datas das avaliações.
- Preservação do histórico de filmes desativados, sem necessidade de excluir seus registros.

---

## 🛠️ Tecnologias Utilizadas

- **SGBD:** MySQL 8.0 ou superior.
- **Linguagem:** SQL.
- **Modelagem e documentação:** documentos do modelo conceitual, modelo lógico e dicionário de dados.
- **Ferramentas de execução:** MySQL Workbench, DBeaver ou terminal MySQL.
- **Controle de versão:** Git e GitHub.

Os scripts utilizam recursos específicos do MySQL, como `AUTO_INCREMENT`, `ENGINE=InnoDB`, `FOREIGN_KEY_CHECKS` e restrições `CHECK`.

---

## 📂 Estrutura do Projeto

A estrutura abaixo considera os scripts SQL e os documentos armazenados na raiz do repositório.

catalogo-filmes/
├── 📁 docs/
│    ├── dicionario-dados.pdf
│    ├── mer-conceitual.pdf
│    ├── modelo-logico.pdf
│    └── relatorio-etapa1.pdf
├── 📁 sql/
│    ├── 📜 01_ddl.sql             
│    ├── 📜 02_carga.sql          
│    └── 📜 03_consultas.sql
├── 📄 README.md     

---

## ⚙️ Como Executar o Projeto

### Pré-requisitos

MySQL Server 8.0+ ou MariaDB 10.4+
MySQL Workbench, DBeaver ou CLI do MySQL 

### Ordem de execução

Os scripts devem ser executados na seguinte ordem:

#### 1. `01_ddl.sql` — Criação da estrutura

Cria o banco de dados `db_acervo_filmes` e suas tabelas, chaves primárias, chaves estrangeiras, restrições de integridade e índices auxiliares.

As principais tabelas são:

`PESSOA`, `ATOR`, `DIRETOR`, `FILME`, `GENERO`, `PLATAFORMA`, `USUARIO`, `EPISODIO`, `ELENCO`, `DIRECAO`, `FILME_GENERO`, `DISPONIBILIDADE` e `AVALIACAO`.

**Atenção:** o script utiliza `DROP DATABASE IF EXISTS db_acervo_filmes`. Portanto, a execução exclui o banco anterior com esse nome e recria sua estrutura. Dados existentes nesse banco serão perdidos.

#### 2. `02_carga.sql` — Inserção dos dados

Insere dados fictícios para permitir a execução e a demonstração das consultas.

A carga contempla, entre outros registros:

- 10 gêneros;
- 8 plataformas;
- 25 usuários;
- 45 pessoas;
- 42 filmes;
- 15 episódios;
- 105 avaliações.

Também são inseridos dados de atores, diretores, elenco, direção, gêneros associados e períodos de disponibilidade.

O script inclui casos de teste, como filmes desativados, pessoas que atuam e dirigem, contratos sem data final e avaliações sem comentário.

**Atenção:** o script utiliza `TRUNCATE TABLE` e desativa temporariamente a verificação de chaves estrangeiras durante a limpeza. A execução remove os dados existentes nas tabelas afetadas antes de inserir a carga novamente.

#### 3. `03_consultas.sql` — Consultas e relatórios

Executa 15 consultas SQL organizadas em três grupos. Elas demonstram filtros, ordenações, junções entre tabelas, agregações e subconsultas.

### Consultas básicas — 1 a 5

1. Contar os filmes cujos títulos começam com A ou O.
2. Listar filmes que possuem uma sequência cadastrada.
3. Consultar filmes com duração entre 60 e 120 minutos.
4. Listar filmes ativos lançados entre 2000 e 2020.
5. Listar plataformas dos tipos Streaming ou Cinema.

**Principais recursos:** `COUNT`, `LIKE`, `IS NOT NULL`, `BETWEEN`, `IN`, `WHERE` e `ORDER BY`.

### Consultas com junções e agregações — 6 a 10

6. Contar os registros de disponibilidade associados a cada plataforma.
7. Identificar plataformas cuja média de duração dos filmes associados é superior a 130 minutos.
8. Listar filmes e suas avaliações, incluindo filmes sem avaliações.
9. Apresentar os gêneros associados a cada filme ativo.
10. Listar plataformas e filmes associados ao gênero Ficção Científica.

**Principais recursos:** `INNER JOIN`, `LEFT JOIN`, `GROUP BY`, `HAVING`, `AVG`, `ROUND`, `GROUP_CONCAT` e `DISTINCT`.

### Consultas avançadas — 11 a 15

11. Contar filmes com períodos de disponibilidade que se sobrepõem ao intervalo de 2020 a 2021.
12. Listar usuários que avaliaram filmes com mais de 150 minutos e registraram um comentário não nulo.
13. Identificar filmes cuja média de avaliação é superior à média geral das avaliações.
14. Listar atores que nunca participaram de filmes associados ao gênero Terror.
15. Classificar plataformas pelo total de horas de filmes cuja média de avaliação seja igual ou superior a 8,0.

**Principais recursos:** `EXISTS`, `NOT EXISTS`, subconsultas correlacionadas, `AVG`, `SUM`, `COUNT(DISTINCT)` e cálculos de duração em horas.

### Observações sobre os resultados

- Na consulta 6, o comando `COUNT(d.id_filme)` conta registros de disponibilidade, e não necessariamente títulos distintos. Um filme com mais de um período registrado para a mesma plataforma pode ser contado mais de uma vez.
- A consulta 10 identifica associações entre plataformas, filmes e o gênero Ficção Científica, mas não filtra as datas para confirmar se a disponibilidade está vigente na data da execução.
- A consulta 15 conta títulos distintos na coluna correspondente, mas o cálculo de horas utiliza os registros de disponibilidade. Caso existam vários períodos para o mesmo filme na mesma plataforma, a duração poderá ser somada mais de uma vez.

Essas observações descrevem o comportamento do SQL implementado; não representam filtros adicionais que o script ainda não executa.

---

## 📄 Documentação do Projeto

Os documentos complementares do projeto são:

- **MER conceitual:** `mer-conceitual.pdf`
- **Modelo lógico:** `modelo-logico.pdf`
- **Dicionário de dados:** `dicionario-dados.pdf`
- **Relatório da primeira etapa:** `relatorio-etapa1.pdf`
- **Relatório da segunda etapa:** `relatorio-etapa2.pdf`

Esses documentos complementam a compreensão das entidades, dos relacionamentos, dos atributos e das regras de negócio representadas no banco de dados.

---

## 🎓 Disciplina

Trabalho desenvolvido para a disciplina de **Laboratório de Banco de Dados (2026/2)**, sob orientação do professor **Samuel Novais Moura Júnior**, na Universidade Católica de Brasília (UCB).

---

## 🤖 Declaração de Uso de Inteligência Artificial

Ferramentas de inteligência artificial generativa foram utilizadas como apoio à revisão textual, à organização da documentação e à análise dos scripts SQL. A validação das informações técnicas, das regras de negócio e da versão final entregue permanece sob responsabilidade dos integrantes do grupo.

---

## 📝 Licença

Projeto acadêmico sem fins comerciais, desenvolvido para fins didáticos.
