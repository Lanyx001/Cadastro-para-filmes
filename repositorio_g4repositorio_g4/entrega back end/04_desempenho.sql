-- =============================================================================
-- DISCIPLINA: Laboratorio de Banco de Dados (2026/2)
-- ETAPA 2.2: Otimizacao de desempenho e analise com EXPLAIN
-- BANCO: MySQL 8 / db_acervo_filmes
--
-- Execute somente apos 01_ddl.sql e 02_carga.sql. Este arquivo NAO altera
-- os scripts corrigidos da Etapa 1.
--
-- Roteiro: (1) plano-base, (2) criacao dos indices, (3) plano-otimizado.
-- Copie a saida de cada EXPLAIN para a documentacao de entrega. Os valores de
-- `type`, `rows`, `key` e `Extra` dependem da instancia e nao sao fixados aqui.
-- =============================================================================

USE db_acervo_filmes;

-- Reconstituicao controlada do cenario "antes". Estes sao exclusivamente os
-- indices desta secao; nao remova os indices que ja existem no 01_ddl.sql.
-- Alguns MySQL 8 nao suportam "DROP INDEX IF EXISTS". A verificacao via
-- INFORMATION_SCHEMA preserva a compatibilidade sem depender dessa sintaxe.
SET @sql_remover_indice = (
    SELECT IF(COUNT(*) > 0,
        'DROP INDEX idx_filme_status_ano_titulo_duracao ON FILME',
        'SELECT 1')
    FROM INFORMATION_SCHEMA.STATISTICS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'FILME'
      AND INDEX_NAME = 'idx_filme_status_ano_titulo_duracao'
);
PREPARE stmt_remover_indice FROM @sql_remover_indice;
EXECUTE stmt_remover_indice;
DEALLOCATE PREPARE stmt_remover_indice;

-- Garante uma chave de apoio para fk_disp_plataforma antes de remover o indice
-- composto. Em algumas instalacoes, o InnoDB pode ter passado a usar o indice
-- composto para sustentar essa chave estrangeira.
SET @sql_criar_apoio_fk = (
    SELECT IF(COUNT(*) = 0,
        'CREATE INDEX idx_disp_plataforma_fk_apoio ON DISPONIBILIDADE (id_plataforma)',
        'SELECT 1')
    FROM INFORMATION_SCHEMA.STATISTICS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'DISPONIBILIDADE'
      AND SEQ_IN_INDEX = 1
      AND COLUMN_NAME = 'id_plataforma'
      AND INDEX_NAME <> 'idx_disp_plataforma_inicio_fim_filme'
);
PREPARE stmt_criar_apoio_fk FROM @sql_criar_apoio_fk;
EXECUTE stmt_criar_apoio_fk;
DEALLOCATE PREPARE stmt_criar_apoio_fk;

SET @sql_remover_indice = (
    SELECT IF(COUNT(*) > 0,
        'DROP INDEX idx_disp_plataforma_inicio_fim_filme ON DISPONIBILIDADE',
        'SELECT 1')
    FROM INFORMATION_SCHEMA.STATISTICS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'DISPONIBILIDADE'
      AND INDEX_NAME = 'idx_disp_plataforma_inicio_fim_filme'
);
PREPARE stmt_remover_indice FROM @sql_remover_indice;
EXECUTE stmt_remover_indice;
DEALLOCATE PREPARE stmt_remover_indice;

SET @sql_remover_indice = (
    SELECT IF(COUNT(*) > 0,
        'DROP INDEX idx_avaliacao_data_filme_nota ON AVALIACAO',
        'SELECT 1')
    FROM INFORMATION_SCHEMA.STATISTICS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'AVALIACAO'
      AND INDEX_NAME = 'idx_avaliacao_data_filme_nota'
);
PREPARE stmt_remover_indice FROM @sql_remover_indice;
EXECUTE stmt_remover_indice;
DEALLOCATE PREPARE stmt_remover_indice;

-- Atualiza estatisticas usadas pelo otimizador antes de cada comparacao.
ANALYZE TABLE FILME, DISPONIBILIDADE, AVALIACAO;

-- =============================================================================
-- CENARIO 1 - Titulos ativos por faixa de lancamento, ordenados para listagem
-- Filtros: status e ano_lancamento. Ordenacao: ano_lancamento e titulo.
-- =============================================================================

-- ANTES: registre table, type, possible_keys, key, rows, filtered e Extra.
EXPLAIN
SELECT f.id_filme, f.titulo, f.ano_lancamento, f.duracao
FROM FILME AS f
WHERE f.status = 'ativo'
  AND f.ano_lancamento BETWEEN 2000 AND 2020
ORDER BY f.ano_lancamento, f.titulo;

-- =============================================================================
-- CENARIO 2 - Catalogo de uma plataforma em um periodo de disponibilidade
-- A data de fim nula representa contrato em aberto, conforme o esquema.
-- O filtro por plataforma reproduz uma pesquisa de catalogo por plataforma.
-- =============================================================================

SET @plataforma_id = 4;
SET @inicio_periodo = DATE('2023-01-01');
SET @fim_periodo = DATE('2024-12-31');

-- ANTES: registre o plano, sobretudo o acesso a DISPONIBILIDADE.
EXPLAIN
SELECT f.id_filme,
       f.titulo,
       d.data_inicio,
       d.data_fim
FROM DISPONIBILIDADE AS d
INNER JOIN FILME AS f ON f.id_filme = d.id_filme
WHERE d.id_plataforma = @plataforma_id
  AND d.data_inicio <= @fim_periodo
  AND (d.data_fim IS NULL OR d.data_fim >= @inicio_periodo)
ORDER BY d.data_inicio DESC, f.titulo ASC;

-- =============================================================================
-- CENARIO 3 - Media de notas por filme em um intervalo de avaliacoes
-- Filtro temporal e agregacao usada em relatorios de qualidade do catalogo.
-- =============================================================================

SET @inicio_avaliacao = TIMESTAMP('2024-01-01 00:00:00');
SET @fim_avaliacao = TIMESTAMP('2024-05-31 23:59:59');

-- ANTES: registre o plano, sobretudo o acesso a AVALIACAO.
EXPLAIN
SELECT f.id_filme,
       f.titulo,
       ROUND(AVG(a.nota), 2) AS nota_media,
       COUNT(*) AS total_avaliacoes
FROM AVALIACAO AS a
INNER JOIN FILME AS f ON f.id_filme = a.id_filme
WHERE a.data_avaliacao BETWEEN @inicio_avaliacao AND @fim_avaliacao
GROUP BY f.id_filme, f.titulo
HAVING AVG(a.nota) >= 8.0
ORDER BY nota_media DESC, total_avaliacoes DESC;

-- =============================================================================
-- INDICES SECUNDARIOS PROPOSTOS
-- =============================================================================

-- Cenario 1: igualdade em status, intervalo/ordenacao por ano e titulo;
-- duracao completa a cobertura das colunas projetadas.
CREATE INDEX idx_filme_status_ano_titulo_duracao
    ON FILME (status, ano_lancamento, titulo, duracao);

-- Cenario 2: igualdade em plataforma seguida do intervalo de inicio; data_fim
-- participa da avaliacao do contrato e id_filme atende a juncao subsequente.
CREATE INDEX idx_disp_plataforma_inicio_fim_filme
    ON DISPONIBILIDADE (id_plataforma, data_inicio, data_fim, id_filme);

-- Cenario 3: o intervalo temporal seleciona avaliacoes; id_filme suporta o
-- agrupamento/juncao e nota permite calcular a media sem buscar essa coluna na tabela.
CREATE INDEX idx_avaliacao_data_filme_nota
    ON AVALIACAO (data_avaliacao, id_filme, nota);

ANALYZE TABLE FILME, DISPONIBILIDADE, AVALIACAO;

-- =============================================================================
-- DEPOIS: execute os mesmos EXPLAINs e compare com os resultados anteriores.
-- =============================================================================

EXPLAIN
SELECT f.id_filme, f.titulo, f.ano_lancamento, f.duracao
FROM FILME AS f
WHERE f.status = 'ativo'
  AND f.ano_lancamento BETWEEN 2000 AND 2020
ORDER BY f.ano_lancamento, f.titulo;

EXPLAIN
SELECT f.id_filme,
       f.titulo,
       d.data_inicio,
       d.data_fim
FROM DISPONIBILIDADE AS d
INNER JOIN FILME AS f ON f.id_filme = d.id_filme
WHERE d.id_plataforma = @plataforma_id
  AND d.data_inicio <= @fim_periodo
  AND (d.data_fim IS NULL OR d.data_fim >= @inicio_periodo)
ORDER BY d.data_inicio DESC, f.titulo ASC;

EXPLAIN
SELECT f.id_filme,
       f.titulo,
       ROUND(AVG(a.nota), 2) AS nota_media,
       COUNT(*) AS total_avaliacoes
FROM AVALIACAO AS a
INNER JOIN FILME AS f ON f.id_filme = a.id_filme
WHERE a.data_avaliacao BETWEEN @inicio_avaliacao AND @fim_avaliacao
GROUP BY f.id_filme, f.titulo
HAVING AVG(a.nota) >= 8.0
ORDER BY nota_media DESC, total_avaliacoes DESC;

-- Evidencia adicional opcional (MySQL 8.0.18+): substitua cada SELECT acima
-- por EXPLAIN ANALYZE SELECT ... para registrar linhas reais e tempo. Nao use
-- o resultado de uma maquina como se fosse valido para outra instancia.

-- Para desfazer apenas os indices desta secao apos a demonstracao:
-- DROP INDEX idx_filme_status_ano_titulo_duracao ON FILME;
-- DROP INDEX idx_disp_plataforma_inicio_fim_filme ON DISPONIBILIDADE;
-- DROP INDEX idx_avaliacao_data_filme_nota ON AVALIACAO;
