-- =============================================================================
-- ETAPA 2.4 - Perfis de acesso pelo principio do menor privilegio
-- Execute como administrador MySQL com privilegio CREATE ROLE e GRANT OPTION.
-- Nao execute com a credencial da aplicacao.
-- =============================================================================

CREATE ROLE IF NOT EXISTS role_claquete_administrador;
CREATE ROLE IF NOT EXISTS role_claquete_curador;
CREATE ROLE IF NOT EXISTS role_claquete_leitor;

-- Administrador: controle total somente sobre o esquema do projeto, inclusive
-- capacidade de delegar esses privilegios. Nenhum privilegio global e concedido.
GRANT ALL PRIVILEGES ON db_acervo_filmes.*
    TO role_claquete_administrador WITH GRANT OPTION;

-- Curador: manutencao do catalogo e de seus relacionamentos. Pode consultar
-- pessoas/atores/diretores para montar creditos, mas nao os altera. Nao recebe
-- acesso a USUARIO_CREDENCIAL, AUDITORIA_EVENTO ou a tabelas de usuarios.
GRANT SELECT, INSERT, UPDATE, DELETE ON db_acervo_filmes.FILME TO role_claquete_curador;
GRANT SELECT, INSERT, UPDATE, DELETE ON db_acervo_filmes.GENERO TO role_claquete_curador;
GRANT SELECT, INSERT, UPDATE, DELETE ON db_acervo_filmes.PLATAFORMA TO role_claquete_curador;
GRANT SELECT, INSERT, UPDATE, DELETE ON db_acervo_filmes.EPISODIO TO role_claquete_curador;
GRANT SELECT, INSERT, UPDATE, DELETE ON db_acervo_filmes.ELENCO TO role_claquete_curador;
GRANT SELECT, INSERT, UPDATE, DELETE ON db_acervo_filmes.DIRECAO TO role_claquete_curador;
GRANT SELECT, INSERT, UPDATE, DELETE ON db_acervo_filmes.FILME_GENERO TO role_claquete_curador;
GRANT SELECT, INSERT, UPDATE, DELETE ON db_acervo_filmes.DISPONIBILIDADE TO role_claquete_curador;
GRANT SELECT ON db_acervo_filmes.PESSOA TO role_claquete_curador;
GRANT SELECT ON db_acervo_filmes.ATOR TO role_claquete_curador;
GRANT SELECT ON db_acervo_filmes.DIRETOR TO role_claquete_curador;

-- Leitor: somente as views existentes; nenhuma tabela base e nenhum privilegio
-- de escrita sao concedidos a este perfil.
GRANT SELECT ON db_acervo_filmes.vw_catalogo_publico TO role_claquete_leitor;
GRANT SELECT ON db_acervo_filmes.vw_relatorio_consolidado TO role_claquete_leitor;

-- Inspecao dos privilegios dos tres perfis.
SHOW GRANTS FOR role_claquete_administrador;
SHOW GRANTS FOR role_claquete_curador;
SHOW GRANTS FOR role_claquete_leitor;

-- ATRIBUICAO A CONTAS DE TESTE (execute somente apos criar contas com senhas
-- locais fortes; os comandos abaixo sao exemplos e ficam propositalmente
-- comentados para nao criar credenciais no repositorio):
-- CREATE USER 'teste_admin'@'localhost' IDENTIFIED BY '<defina-localmente-uma-senha-forte>';
-- CREATE USER 'teste_curador'@'localhost' IDENTIFIED BY '<defina-localmente-uma-senha-forte>';
-- CREATE USER 'teste_leitor'@'localhost' IDENTIFIED BY '<defina-localmente-uma-senha-forte>';
-- GRANT role_claquete_administrador TO 'teste_admin'@'localhost';
-- GRANT role_claquete_curador TO 'teste_curador'@'localhost';
-- GRANT role_claquete_leitor TO 'teste_leitor'@'localhost';
-- SET DEFAULT ROLE role_claquete_administrador TO 'teste_admin'@'localhost';
-- SET DEFAULT ROLE role_claquete_curador TO 'teste_curador'@'localhost';
-- SET DEFAULT ROLE role_claquete_leitor TO 'teste_leitor'@'localhost';

-- ROTEIRO REPRODUZIVEL DE VALIDACAO (substitua somente as senhas localmente):
-- 1. Descomente e execute os comandos CREATE USER, GRANT e SET DEFAULT ROLE
--    acima usando uma conta administrativa MySQL.
-- 2. Em outro terminal, entre como leitor sem informar senha na linha de comando:
--    mysql -u teste_leitor -p db_acervo_filmes
-- 3. A consulta abaixo deve funcionar:
-- SELECT * FROM db_acervo_filmes.vw_catalogo_publico LIMIT 5;
-- SELECT * FROM db_acervo_filmes.vw_relatorio_consolidado LIMIT 5;
-- 4. Esta deve ser negada por falta de privilegio em tabela-base:
-- SELECT * FROM db_acervo_filmes.FILME;
-- 5. Para conferir a role ativa: SELECT CURRENT_ROLE();
