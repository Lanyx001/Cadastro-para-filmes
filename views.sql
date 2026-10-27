
USE db_acervo_filmes;

-- ---------------------------------------------------------------------------- --

-- 1) Visão de Relatório Consolidado
CREATE OR REPLACE VIEW vw_relatorio_consolidado AS
	SELECT f.id_filme,
		   f.titulo,
		   f.ano_lancamento,
		   f.duracao,
		   COALESCE(a.total_avaliacoes, 0) AS total_avaliacoes,
		   a.media_notas,
		   g.generos,
		   p.plataformas
	  FROM FILME f

LEFT JOIN (
    SELECT id_filme,
        COUNT(*) AS total_avaliacoes,
        ROUND(AVG(nota), 2) AS media_notas
	  FROM AVALIACAO
    GROUP BY id_filme
) a ON f.id_filme = a.id_filme

LEFT JOIN (
    SELECT fg.id_filme,
        GROUP_CONCAT(ge.nome ORDER BY ge.nome SEPARATOR ', ') AS generos
      FROM FILME_GENERO fg
		INNER JOIN GENERO ge
			ON fg.id_genero = ge.id_genero
    GROUP BY fg.id_filme
) g ON f.id_filme = g.id_filme

LEFT JOIN (
    SELECT d.id_filme,
        GROUP_CONCAT(DISTINCT pl.nome ORDER BY pl.nome SEPARATOR ', ') AS plataformas
      FROM DISPONIBILIDADE d
		INNER JOIN PLATAFORMA pl
			ON d.id_plataforma = pl.id_plataforma
    GROUP BY d.id_filme
) p ON f.id_filme = p.id_filme;

SELECT * FROM vw_relatorio_consolidado;

-- ---------------------------------------------------------------------------- --

-- 2) Visão de Segurança e Exibição Pública
CREATE OR REPLACE VIEW vw_catalogo_publico AS
	SELECT id_filme,
		   titulo,
		   ano_lancamento,
		   duracao
	  FROM FILME
	WHERE status = 'ativo';
    
SELECT * FROM vw_catalogo_publico;

GRANT SELECT ON db_acervo_filmes.vw_catalogo_publico
	TO 'usuario_publico'@'localhost'; -- Acesso de leitura a um usuário público
