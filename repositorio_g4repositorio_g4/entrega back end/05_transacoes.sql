-- =============================================================================
-- ETAPA 2.3 - Controle transacional: COMMIT e ROLLBACK
-- Banco: MySQL 8+ | Esquema: db_acervo_filmes
--
-- Execute depois de 01_ddl.sql e 02_carga.sql. O script usa somente registros
-- auxiliares identificados por titulo reservado e os remove ao fim de cada caso.
-- =============================================================================

USE db_acervo_filmes;

-- Confirma que as tabelas usadas oferecem suporte transacional (InnoDB).
SELECT table_name, engine
FROM information_schema.tables
WHERE table_schema = DATABASE()
  AND table_name IN ('FILME', 'FILME_GENERO', 'ELENCO');

-- A carga deve conter pelo menos um genero e um ator para o caso de sucesso.
SELECT (SELECT COUNT(*) FROM GENERO) AS generos_disponiveis,
       (SELECT COUNT(*) FROM ATOR) AS atores_disponiveis;

-- =============================================================================
-- CENARIO 1 - Cadastro atomico de filme, genero e elenco com COMMIT
-- Resultado esperado: apos o COMMIT, as tres tabelas mostram um vinculo do
-- filme auxiliar. A limpeza posterior remove apenas esse filme e, por cascata,
-- os seus vinculos em FILME_GENERO e ELENCO.
-- =============================================================================

SET @filme_commit_id = 900001;
SET @titulo_commit = CONVERT('[ETAPA 2.3] Filme de demonstracao - COMMIT' USING utf8mb4)
    COLLATE utf8mb4_unicode_ci;

-- Limpeza idempotente de eventual execucao anterior, limitada ao titulo reservado.
DELETE FROM FILME
WHERE id_filme = @filme_commit_id
  AND titulo = @titulo_commit;

-- Os identificadores relacionados sao obtidos da carga existente; nao ha ID de
-- ator ou genero presumido pelo roteiro.
SELECT id_genero INTO @genero_teste
FROM GENERO
ORDER BY id_genero
LIMIT 1;

SELECT id_pessoa INTO @ator_teste
FROM ATOR
ORDER BY id_pessoa
LIMIT 1;

START TRANSACTION;

INSERT INTO FILME
    (id_filme, titulo, ano_lancamento, duracao, status, id_filme_sequencia)
VALUES
    (@filme_commit_id, @titulo_commit, 2026, 110, 'ativo', NULL);

INSERT INTO FILME_GENERO (id_filme, id_genero)
VALUES (@filme_commit_id, @genero_teste);

INSERT INTO ELENCO (id_filme, id_pessoa_ator, personagem)
VALUES (@filme_commit_id, @ator_teste, 'Personagem de demonstracao transacional');

-- Verificacao ainda dentro da transacao: deve retornar uma linha completa.
SELECT f.id_filme, f.titulo, g.nome AS genero, p.nome AS ator, e.personagem
FROM FILME AS f
JOIN FILME_GENERO AS fg ON fg.id_filme = f.id_filme
JOIN GENERO AS g ON g.id_genero = fg.id_genero
JOIN ELENCO AS e ON e.id_filme = f.id_filme
JOIN PESSOA AS p ON p.id_pessoa = e.id_pessoa_ator
WHERE f.id_filme = @filme_commit_id;

COMMIT;

-- Verificacao apos o COMMIT: a mesma linha permanece visivel e consistente.
SELECT f.id_filme, f.titulo, g.nome AS genero, p.nome AS ator, e.personagem
FROM FILME AS f
JOIN FILME_GENERO AS fg ON fg.id_filme = f.id_filme
JOIN GENERO AS g ON g.id_genero = fg.id_genero
JOIN ELENCO AS e ON e.id_filme = f.id_filme
JOIN PESSOA AS p ON p.id_pessoa = e.id_pessoa_ator
WHERE f.id_filme = @filme_commit_id;

-- Limpeza do dado auxiliar apos registrar a evidencia do COMMIT.
START TRANSACTION;
DELETE FROM FILME
WHERE id_filme = @filme_commit_id
  AND titulo = @titulo_commit;
COMMIT;

SELECT COUNT(*) AS filme_auxiliar_apos_limpeza
FROM FILME
WHERE id_filme = @filme_commit_id;

-- =============================================================================
-- CENARIO 2 - Falha controlada e ROLLBACK
-- A segunda insercao em FILME_GENERO repete a mesma chave primaria composta
-- (id_filme, id_genero), causando erro 1062. Um manipulador captura o erro,
-- executa ROLLBACK e devolve uma verificacao, sem interromper o cliente antes
-- do rollback. A rotina temporaria e removida no final.
-- =============================================================================

SET @filme_rollback_id = 900002;
SET @titulo_rollback = CONVERT('[ETAPA 2.3] Filme de demonstracao - ROLLBACK' USING utf8mb4)
    COLLATE utf8mb4_unicode_ci;

DELETE FROM FILME
WHERE id_filme = @filme_rollback_id
  AND titulo = @titulo_rollback;

SELECT id_genero INTO @genero_rollback
FROM GENERO
ORDER BY id_genero
LIMIT 1;

DROP PROCEDURE IF EXISTS etapa_2_3_demonstrar_rollback;

DELIMITER $$
CREATE PROCEDURE etapa_2_3_demonstrar_rollback()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Falha controlada tratada; ROLLBACK executado.' AS resultado,
               (SELECT COUNT(*) FROM FILME
                 WHERE id_filme = @filme_rollback_id) AS filmes_restantes,
               (SELECT COUNT(*) FROM FILME_GENERO
                 WHERE id_filme = @filme_rollback_id) AS vinculos_restantes;
    END;

    START TRANSACTION;

    -- Alteracao valida, que seria persistida se a operacao inteira tivesse sucesso.
    INSERT INTO FILME
        (id_filme, titulo, ano_lancamento, duracao, status, id_filme_sequencia)
    VALUES
        (@filme_rollback_id, @titulo_rollback, 2026, 111, 'ativo', NULL);

    INSERT INTO FILME_GENERO (id_filme, id_genero)
    VALUES (@filme_rollback_id, @genero_rollback);

    -- Falha reproduzivel: viola pk_filme_genero na mesma transacao.
    INSERT INTO FILME_GENERO (id_filme, id_genero)
    VALUES (@filme_rollback_id, @genero_rollback);

    -- Este ponto nao e alcancado quando a falha controlada ocorre.
    COMMIT;
END$$
DELIMITER ;

CALL etapa_2_3_demonstrar_rollback();
DROP PROCEDURE etapa_2_3_demonstrar_rollback;

-- Verificacao independente final: ambos os valores devem ser zero.
SELECT COUNT(*) AS filme_apos_rollback
FROM FILME
WHERE id_filme = @filme_rollback_id;

SELECT COUNT(*) AS vinculo_apos_rollback
FROM FILME_GENERO
WHERE id_filme = @filme_rollback_id;
