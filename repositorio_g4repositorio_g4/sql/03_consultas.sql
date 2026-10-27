-- =============================================================================
-- DISCIPLINA: Laboratório de Banco de Dados (2026/2)
-- PROFESSOR: Samuel Novais Moura Júnior
-- ARTEFATO: A8 - Script de Consultas (03_consultas.sql) - REVISADO ETAPA 2
-- DOMÍNIO: Acervo Cinematográfico / Streaming
-- =============================================================================

USE db_acervo_filmes;

-- =============================================================================
-- PARTE 1: CONSULTAS BÁSICAS (5 Consultas)
-- Cobertura: Projeção, WHERE, ORDER BY, LIKE, BETWEEN, IN e IS NOT NULL
-- =============================================================================

-- 01) Quantos filmes cadastrados começam com a letra "A" ou "O"?
-- Atende: Agregação condicional e LIKE (Correção C4: responde diretamente à contagem)
SELECT COUNT(*) AS total_filmes_iniciados_a_ou_o
FROM FILME
WHERE titulo LIKE 'A%' OR titulo LIKE 'O%';

-- 02) Quais filmes possuem sequência cadastrada no sistema?
-- Atende: Projeção, WHERE com IS NOT NULL e ORDER BY
SELECT id_filme, titulo, ano_lancamento, id_filme_sequencia
FROM FILME
WHERE id_filme_sequencia IS NOT NULL
ORDER BY ano_lancamento ASC;

-- 03) Quais filmes têm duração compreendida entre 1h e 2h (60 e 120 minutos)?
-- Atende: Projeção com filtros numéricos e ordenação decrescente
SELECT titulo, duracao
FROM FILME
WHERE duracao >= 60 AND duracao <= 120
ORDER BY duracao DESC;

-- 04) Quais filmes ativos foram lançados no período entre 2000 e 2020?
-- Atende: BETWEEN e operador de igualdade sobre status
SELECT id_filme, titulo, ano_lancamento, status
FROM FILME
WHERE status = 'ativo' 
  AND ano_lancamento BETWEEN 2000 AND 2020
ORDER BY ano_lancamento ASC;

-- 05) Quais plataformas operam como Streaming ou Cinema?
-- Atende: Operador IN sobre a coluna tipo da tabela PLATAFORMA
SELECT id_plataforma, nome, tipo
FROM PLATAFORMA
WHERE tipo IN ('Streaming', 'Cinema')
ORDER BY tipo ASC, nome ASC;

-- =============================================================================
-- PARTE 2: CONSULTAS COM JUNÇÕES E AGREGAÇÃO (5 Consultas)
-- Cobertura: JOIN com 3+ tabelas, LEFT JOIN, GROUP BY e HAVING
-- =============================================================================

-- 06) Quantos títulos distintos cada plataforma de exibição disponibiliza no seu catálogo atual?
-- Atende: Junção de tabelas (PLATAFORMA e DISPONIBILIDADE) com GROUP BY (Correção C4)
SELECT 
    p.nome AS plataforma,
    p.tipo,
    COUNT(d.id_filme) AS total_titulos_disponibilizados
FROM PLATAFORMA p
INNER JOIN DISPONIBILIDADE d ON p.id_plataforma = d.id_plataforma
GROUP BY p.id_plataforma, p.nome, p.tipo
ORDER BY total_titulos_disponibilizados DESC;

-- 07) Quais plataformas de exibição possuem uma média de duração dos seus filmes superior a 130 minutos?
-- Atende: Junção de 3 tabelas (PLATAFORMA, DISPONIBILIDADE e FILME) com GROUP BY e HAVING (Correção C4)
SELECT 
    p.nome AS plataforma,
    ROUND(AVG(f.duracao), 2) AS media_duracao_minutos,
    COUNT(f.id_filme) AS quantidade_filmes
FROM PLATAFORMA p
INNER JOIN DISPONIBILIDADE d ON p.id_plataforma = d.id_plataforma
INNER JOIN FILME f ON d.id_filme = f.id_filme
GROUP BY p.id_plataforma, p.nome
HAVING AVG(f.duracao) > 130
ORDER BY media_duracao_minutos DESC;

-- 08) Qual é o histórico completo de filmes e as respetivas notas recebidas, incluindo obras que ainda não receberam avaliações?
-- Atende: LEFT JOIN e ordenação
SELECT 
    f.id_filme,
    f.titulo,
    a.id_usuario,
    a.nota,
    a.comentario
FROM FILME f
LEFT JOIN AVALIACAO a ON f.id_filme = a.id_filme
ORDER BY f.titulo ASC, a.nota DESC;

-- 09) Quais são os gêneros associados a cada filme ativo do acervo?
-- Atende: Junção interna entre 3 tabelas (FILME, FILME_GENERO e GENERO)
SELECT 
    f.titulo AS filme,
    f.ano_lancamento,
    GROUP_CONCAT(g.nome ORDER BY g.nome SEPARATOR ', ') AS generos
FROM FILME f
INNER JOIN FILME_GENERO fg ON f.id_filme = fg.id_filme
INNER JOIN GENERO g ON fg.id_genero = g.id_genero
WHERE f.status = 'ativo'
GROUP BY f.id_filme, f.titulo, f.ano_lancamento
ORDER BY f.titulo ASC;

-- 10) Quais plataformas exibem atualmente filmes do gênero 'Ficção Científica'?
-- Atende: Junção envolvendo 4 tabelas (PLATAFORMA, DISPONIBILIDADE, FILME_GENERO e GENERO)
SELECT DISTINCT 
    p.nome AS plataforma,
    p.tipo AS tipo_plataforma,
    f.titulo AS filme
FROM PLATAFORMA p
INNER JOIN DISPONIBILIDADE d ON p.id_plataforma = d.id_plataforma
INNER JOIN FILME f ON d.id_filme = f.id_filme
INNER JOIN FILME_GENERO fg ON f.id_filme = fg.id_filme
INNER JOIN GENERO g ON fg.id_genero = g.id_genero
WHERE g.nome = 'Ficção Científica'
ORDER BY p.nome ASC, f.titulo ASC;


-- =============================================================================
-- PARTE 3: CONSULTAS AVANÇADAS (5 Consultas)
-- Cobertura: Operador EXISTS, NOT EXISTS, Subconsultas Correlacionadas e Negócio Não Trivial
-- =============================================================================

-- 11) Quantos filmes estiveram disponíveis para exibição no catálogo com contratos vigentes entre 2020 e 2021?
-- Atende: Subconsulta correlacionada com EXISTS e agregação precisa (Correção C4)
SELECT COUNT(*) AS total_filmes_periodo_2020_2021
FROM FILME f
WHERE EXISTS (
    SELECT 1 
    FROM DISPONIBILIDADE d
    WHERE d.id_filme = f.id_filme
      AND d.data_inicio <= '2021-12-31'
      AND (d.data_fim IS NULL OR d.data_fim >= '2020-01-01')
);

-- 12) Quais utilizadores registaram avaliações críticas completas (com comentário não nulo) para filmes com duração superior a 150 minutos?
-- Atende: Subconsulta com EXISTS correlacionando USUARIO e AVALIACAO
SELECT 
    u.id_usuario,
    u.nome AS usuario,
    u.email
FROM USUARIO u
WHERE EXISTS (
    SELECT 1 
    FROM AVALIACAO a
    INNER JOIN FILME f ON a.id_filme = f.id_filme
    WHERE a.id_usuario = u.id_usuario
      AND a.comentario IS NOT NULL
      AND f.duracao > 150
)
ORDER BY u.nome ASC;

-- 13) Quais filmes possuem uma nota média estritamente superior à média aritmética de todas as avaliações do acervo?
-- Atende: Subconsulta correlacionada comparando média do grupo com a média global do sistema
SELECT 
    f.id_filme,
    f.titulo,
    ROUND(AVG(a.nota), 2) AS media_do_filme
FROM FILME f
INNER JOIN AVALIACAO a ON f.id_filme = a.id_filme
GROUP BY f.id_filme, f.titulo
HAVING AVG(a.nota) > (
    SELECT AVG(nota) 
    FROM AVALIACAO
)
ORDER BY media_do_filme DESC;

-- 14) Quais atores cadastrados no acervo nunca participaram no elenco de nenhum filme do gênero 'Terror'?
-- Atende: Subconsulta correlacionada com NOT EXISTS cruzando ATOR, ELENCO, FILME_GENERO e GENERO
SELECT 
    p.id_pessoa,
    p.nome AS ator,
    a.registro_profissional
FROM PESSOA p
INNER JOIN ATOR a ON p.id_pessoa = a.id_pessoa
WHERE NOT EXISTS (
    SELECT 1
    FROM ELENCO e
    INNER JOIN FILME_GENERO fg ON e.id_filme = fg.id_filme
    INNER JOIN GENERO g ON fg.id_genero = g.id_genero
    WHERE e.id_pessoa_ator = a.id_pessoa
      AND g.nome = 'Terror'
)
ORDER BY p.nome ASC;

-- 15) Pergunta não trivial de negócio: Qual é o ranking das plataformas pelo tempo total acumulado (em horas) de conteúdo cinematográfico disponibilizado em produções com avaliação média acima de 8.0?
-- Atende: Subconsulta não trivial cruzando agregação temporal, cálculo de horas e filtro analítico de qualidade
SELECT 
    p.nome AS plataforma,
    p.tipo,
    COUNT(DISTINCT f.id_filme) AS titulos_qualificados,
    ROUND(SUM(f.duracao) / 60.0, 1) AS total_horas_catalogo_qualificado
FROM PLATAFORMA p
INNER JOIN DISPONIBILIDADE d ON p.id_plataforma = d.id_plataforma
INNER JOIN FILME f ON d.id_filme = f.id_filme
WHERE f.id_filme IN (
    SELECT a.id_filme
    FROM AVALIACAO a
    GROUP BY a.id_filme
    HAVING AVG(a.nota) >= 8.0
)
GROUP BY p.id_plataforma, p.nome, p.tipo
ORDER BY total_horas_catalogo_qualificado DESC;