# Claquete — backend e interface

Aplicação Spring Boot 4 / Java 21 com Spring JDBC e MySQL. Não usa JPA, Hibernate, Flyway ou geração automática de esquema.

## Pré-requisitos e execução

1. Instale Java 21, Maven e MySQL 8 compatível.
2. Em um banco de teste, execute nesta ordem:
   - `../scripts sql/topicos 1.2 a 1.5/01_ddl.sql`;
   - `../scripts sql/topicos 1.2 a 1.5/02_carga.sql`;
   - `../scripts sql/topicos 1.2 a 1.5/03_consultas.sql`;
   - `../scripts sql/topico 2.1/views.sql`;
   - `../scripts sql/topico 2.4/07_etapa2_4_credenciais.sql`, `08_etapa2_4_roles_permissoes.sql` e `09_etapa2_4_auditoria.sql`.

   Atenção: o primeiro script remove `db_acervo_filmes` se ele existir.
3. Copie `.env.example` para `.env`, preencha as variáveis e exporte-as para o processo (ou configure-as no ambiente da IDE). O Spring Boot não lê `.env` sozinho. Em macOS/Linux, no diretório `claquete-backend`, use `set -a; source .env; set +a` antes de iniciar a aplicação. As variáveis são `DB_URL`, `DB_USER`, `DB_PASSWORD` e, opcionalmente, `PORT`.
4. Para habilitar a administração de credenciais, defina também `CLAQUETE_ADMIN_USER` e `CLAQUETE_ADMIN_PASSWORD_HASH`. A segunda variável deve conter um hash BCrypt já gerado — nunca a senha em texto puro.
5. Execute `mvn spring-boot:run` e abra `http://localhost:8080/`.

## Interface web única

Os arquivos efetivamente servidos em `http://localhost:8080/` ficam em `src/main/resources/static/`. Esta é a única interface do projeto: ela preserva o layout original e chama a API por caminhos relativos, portanto não requer CORS. A antiga pasta `../front end/` contém apenas um aviso de migração e não deve receber outra cópia de HTML, CSS ou JavaScript.

A interface permite criar, listar, editar e excluir filmes, plataformas, avaliações e disponibilidades. Para disponibilidade, os três campos que formam a chave são mantidos durante a edição e somente a data final é alterada, de acordo com o contrato da API.

## API

| Recurso | Operações |
| --- | --- |
| Filmes | `GET/POST /api/filmes`, `GET/PUT/DELETE /api/filmes/{id}`; `POST /api/filmes/ficha-tecnica` |
| Plataformas | `GET/POST /api/plataformas`, `GET/PUT/DELETE /api/plataformas/{id}` |
| Avaliações | `GET/POST /api/avaliacoes`, `GET/PUT/DELETE /api/avaliacoes/{filmeId}/{usuarioId}` |
| Disponibilidade | `GET/POST /api/disponibilidade`, `GET/PUT/DELETE /api/disponibilidade/{filmeId}/{plataformaId}/{dataInicio}` |
| Credenciais | `POST /api/credenciais/{usuarioId}`, `POST /api/credenciais/{usuarioId}/verificar` |
| Pesquisa de filmes | `GET /api/pesquisas/filmes?titulo=&anoMin=&anoMax=&genero=` |
| Pesquisa de disponibilidade | `GET /api/pesquisas/disponibilidade?plataforma=&genero=&vigenteEm=AAAA-MM-DD` |
| Consultas | `GET /api/consultas/{1..15}` |
| Relatório | `GET /api/relatorios` |

Exemplo de filme (o `id` é obrigatório porque o DDL não usa auto incremento):

```json
{"id": 100, "titulo": "Novo filme", "ano": 2026, "duracao": 100, "status": "ativo"}
```

### Cadastro transacional de ficha técnica

`POST /api/filmes/ficha-tecnica` cria, na mesma transação, um registro em `FILME`, o vínculo em `FILME_GENERO` e o crédito em `ELENCO`. Informe identificadores já existentes de gênero e ator. Caso qualquer inserção viole uma regra do banco, a exceção interrompe a transação e nenhuma das três alterações é confirmada.

```json
{"id": 101, "titulo": "Filme com ficha técnica", "ano": 2026, "duracao": 100, "status": "ativo", "generoId": 1, "atorId": 2, "personagem": "Personagem principal"}
```

### Credenciais seguras

Antes de usar os endpoints de credenciais, execute `../scripts sql/topico 2.4/07_etapa2_4_credenciais.sql`. Ambos exigem HTTP Basic com o usuário configurado e a role `ADMIN_CREDENCIAIS`; pedidos sem autenticação recebem `401` e pedidos sem essa role recebem `403`. Configure `CLAQUETE_ADMIN_USER` e um hash BCrypt de custo 12 em `CLAQUETE_ADMIN_PASSWORD_HASH`, conforme [`.env.example`](.env.example); não registre a senha administrativa original. O endpoint `POST /api/credenciais/{usuarioId}` recebe `{"senha":"uma-senha-local-com-12-ou-mais-caracteres"}` e grava somente um hash BCrypt com salt individual na tabela `USUARIO_CREDENCIAL`. `POST /api/credenciais/{usuarioId}/verificar` recebe o mesmo formato e retorna somente `{"valida":true}` ou `{"valida":false}`; nunca retorna senha, hash ou salt.

## Verificação

No diretório `claquete-backend`, com Java 21 e o MySQL configurado:

```sh
mvn test
mvn spring-boot:run
```

Na interface, abra cada seção e confirme o ciclo criar, editar, listar e excluir. Use IDs existentes para filme, usuário e plataforma ao testar avaliação e disponibilidade. Em **Pesquisas**, execute os dois formulários; em **Relatório**, confirme que a lista é preenchida por `vw_relatorio_consolidado`. Erros de validação, conexão, chave estrangeira e conflito são mostrados visualmente em vez de serem ignorados.

Para demonstrar permissões e auditoria, siga os comandos em [`../scripts sql/topico 2.4/README.md`](../scripts%20sql/topico%202.4/README.md): use contas com as roles propostas e consulte `AUDITORIA_EVENTO` após alterar um filme ou uma disponibilidade. A aplicação não executa DDL nem recria o banco automaticamente.

### Registro da validação desta entrega

Em 26/10/2026, foi localizado um JDK 21 local e `mvn clean test` foi executado com sucesso: 8 testes, 0 falhas e 0 erros. Também foi executada a checagem sintática de `src/main/resources/static/script.js`. Não havia cliente nem servidor MySQL disponível neste ambiente. Portanto os CRUDs contra MySQL, as duas pesquisas contra dados reais, a view, os `GRANT`s, as transações reais e os triggers de auditoria **não foram declarados como aprovados**; devem ser executados na máquina com MySQL 8 configurado.
