-- =============================================================================
-- ETAPA 2.3 - Experimento de concorrencia (Lock Wait)
-- Banco: MySQL 8+ | Esquema: db_acervo_filmes
--
-- Abra DUAS conexoes independentes para o mesmo banco. Execute o bloco de
-- preparacao uma vez; depois siga os blocos das sessoes na ordem indicada.
-- Nao execute o bloco da Sessao B na mesma conexao da Sessao A.
-- =============================================================================

-- =============================================================================
-- PREPARACAO (executar uma unica vez, antes das duas sessoes)
-- =============================================================================
USE db_acervo_filmes;

SET @filme_lock_id = 900003;
-- A collation explicita evita conflito caso a conexao use utf8mb4_0900_ai_ci
-- enquanto o esquema use utf8mb4_unicode_ci.
SET @titulo_lock = CONVERT('[ETAPA 2.3] Filme de demonstracao - LOCK WAIT' USING utf8mb4)
    COLLATE utf8mb4_unicode_ci;

DELETE FROM FILME
WHERE id_filme = @filme_lock_id
  AND titulo = @titulo_lock;

INSERT INTO FILME
    (id_filme, titulo, ano_lancamento, duracao, status, id_filme_sequencia)
VALUES
    (@filme_lock_id, @titulo_lock, 2026, 120, 'ativo', NULL);

SELECT id_filme, titulo, duracao, status
FROM FILME
WHERE id_filme = @filme_lock_id;

-- =============================================================================
-- SESSAO A - Execute primeiro e MANTENHA a transacao aberta apos o SELECT.
-- =============================================================================
-- USE db_acervo_filmes;
-- SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
-- START TRANSACTION;
-- UPDATE FILME
-- SET duracao = 121
-- WHERE id_filme = 900003;
-- SELECT CONNECTION_ID() AS conexao_a, @@transaction_isolation AS isolamento_a,
--        id_filme, duracao
-- FROM FILME
-- WHERE id_filme = 900003;
--
-- Pare aqui: nao execute COMMIT ainda. O UPDATE retém bloqueio exclusivo da
-- linha 900003 ate o fim da transacao.

-- =============================================================================
-- SESSAO B - Execute enquanto a Sessao A estiver parada no ponto acima.
-- =============================================================================
-- USE db_acervo_filmes;
-- SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
-- SET SESSION innodb_lock_wait_timeout = 60;
-- START TRANSACTION;
-- SELECT CONNECTION_ID() AS conexao_b, @@transaction_isolation AS isolamento_b;
-- UPDATE FILME
-- SET duracao = duracao + 1
-- WHERE id_filme = 900003;
--
-- Resultado esperado neste momento: o cliente da Sessao B fica aguardando a
-- liberacao do bloqueio; o prompt nao retorna enquanto a Sessao A nao concluir
-- ou enquanto nao atingir o timeout configurado de 60 segundos.

-- =============================================================================
-- FINALIZACAO - Volte a Sessao A e execute. Em seguida, finalize a Sessao B.
-- =============================================================================
-- SESSAO A:
-- COMMIT;
--
-- SESSAO B: logo apos o COMMIT da Sessao A, o UPDATE pendente deve concluir.
-- SELECT id_filme, duracao
-- FROM FILME
-- WHERE id_filme = 900003;
-- -- Resultado esperado: duracao = 122 (121 confirmado por A, mais 1 de B).
-- COMMIT;

-- =============================================================================
-- LIMPEZA (execute somente depois de ambas as sessoes confirmarem)
-- =============================================================================
-- USE db_acervo_filmes;
-- DELETE FROM FILME
-- WHERE id_filme = 900003
--   AND titulo = CONVERT('[ETAPA 2.3] Filme de demonstracao - LOCK WAIT' USING utf8mb4)
--       COLLATE utf8mb4_unicode_ci;
-- SELECT COUNT(*) AS filme_auxiliar_apos_limpeza
-- FROM FILME
-- WHERE id_filme = 900003;
