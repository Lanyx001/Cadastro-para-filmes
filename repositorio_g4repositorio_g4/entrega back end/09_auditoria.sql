-- =============================================================================
-- ETAPA 2.4 - Auditoria de FILME e DISPONIBILIDADE
-- Banco: MySQL 8+ | Esquema: db_acervo_filmes
-- =============================================================================

USE db_acervo_filmes;

CREATE TABLE IF NOT EXISTS AUDITORIA_EVENTO (
    id_evento BIGINT AUTO_INCREMENT,
    ocorrido_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    entidade VARCHAR(50) NOT NULL,
    operacao VARCHAR(10) NOT NULL,
    chave_registro JSON NOT NULL,
    dados_anteriores JSON NULL,
    dados_novos JSON NULL,
    CONSTRAINT pk_auditoria_evento PRIMARY KEY (id_evento),
    CONSTRAINT ck_auditoria_operacao CHECK (operacao IN ('INSERT', 'UPDATE', 'DELETE'))
) ENGINE=InnoDB;

-- Atualiza a restricao tambem em bancos que executaram uma versao anterior
-- deste script, na qual a auditoria ainda nao registrava insercoes.
ALTER TABLE AUDITORIA_EVENTO DROP CHECK ck_auditoria_operacao;
ALTER TABLE AUDITORIA_EVENTO
    ADD CONSTRAINT ck_auditoria_operacao
    CHECK (operacao IN ('INSERT', 'UPDATE', 'DELETE'));

DROP TRIGGER IF EXISTS tr_aud_filme_au;
DROP TRIGGER IF EXISTS tr_aud_disponibilidade_ai;
DROP TRIGGER IF EXISTS tr_aud_disponibilidade_au;
DROP TRIGGER IF EXISTS tr_aud_disponibilidade_ad;

DELIMITER $$

-- Registra apenas mudancas relevantes: titulo, ano, duracao, status e sequencia.
CREATE TRIGGER tr_aud_filme_au
AFTER UPDATE ON FILME
FOR EACH ROW
BEGIN
    IF NOT (OLD.titulo <=> NEW.titulo)
       OR NOT (OLD.ano_lancamento <=> NEW.ano_lancamento)
       OR NOT (OLD.duracao <=> NEW.duracao)
       OR NOT (OLD.status <=> NEW.status)
       OR NOT (OLD.id_filme_sequencia <=> NEW.id_filme_sequencia) THEN
        INSERT INTO AUDITORIA_EVENTO
            (entidade, operacao, chave_registro, dados_anteriores, dados_novos)
        VALUES
            ('FILME', 'UPDATE', JSON_OBJECT('id_filme', NEW.id_filme),
             JSON_OBJECT('titulo', OLD.titulo, 'ano_lancamento', OLD.ano_lancamento,
                         'duracao', OLD.duracao, 'status', OLD.status,
                         'id_filme_sequencia', OLD.id_filme_sequencia),
             JSON_OBJECT('titulo', NEW.titulo, 'ano_lancamento', NEW.ano_lancamento,
                         'duracao', NEW.duracao, 'status', NEW.status,
                         'id_filme_sequencia', NEW.id_filme_sequencia));
    END IF;
END$$

-- MySQL exige um trigger para cada evento. A chave de DISPONIBILIDADE e
-- composta por id_filme, id_plataforma e data_inicio; por isso UPDATE guarda
-- as chaves antiga e nova, alem de data_fim.
CREATE TRIGGER tr_aud_disponibilidade_ai
AFTER INSERT ON DISPONIBILIDADE
FOR EACH ROW
BEGIN
    INSERT INTO AUDITORIA_EVENTO
        (entidade, operacao, chave_registro, dados_anteriores, dados_novos)
    VALUES
        ('DISPONIBILIDADE', 'INSERT',
         JSON_OBJECT('id_filme', NEW.id_filme, 'id_plataforma', NEW.id_plataforma,
                     'data_inicio', NEW.data_inicio),
         NULL,
         JSON_OBJECT('id_filme', NEW.id_filme, 'id_plataforma', NEW.id_plataforma,
                     'data_inicio', NEW.data_inicio, 'data_fim', NEW.data_fim));
END$$

CREATE TRIGGER tr_aud_disponibilidade_au
AFTER UPDATE ON DISPONIBILIDADE
FOR EACH ROW
BEGIN
    IF NOT (OLD.id_filme <=> NEW.id_filme)
       OR NOT (OLD.id_plataforma <=> NEW.id_plataforma)
       OR NOT (OLD.data_inicio <=> NEW.data_inicio)
       OR NOT (OLD.data_fim <=> NEW.data_fim) THEN
        INSERT INTO AUDITORIA_EVENTO
            (entidade, operacao, chave_registro, dados_anteriores, dados_novos)
        VALUES
            ('DISPONIBILIDADE', 'UPDATE',
             JSON_OBJECT('anterior', JSON_OBJECT('id_filme', OLD.id_filme,
                         'id_plataforma', OLD.id_plataforma, 'data_inicio', OLD.data_inicio),
                         'novo', JSON_OBJECT('id_filme', NEW.id_filme,
                         'id_plataforma', NEW.id_plataforma, 'data_inicio', NEW.data_inicio)),
             JSON_OBJECT('id_filme', OLD.id_filme, 'id_plataforma', OLD.id_plataforma,
                         'data_inicio', OLD.data_inicio, 'data_fim', OLD.data_fim),
             JSON_OBJECT('id_filme', NEW.id_filme, 'id_plataforma', NEW.id_plataforma,
                         'data_inicio', NEW.data_inicio, 'data_fim', NEW.data_fim));
    END IF;
END$$

CREATE TRIGGER tr_aud_disponibilidade_ad
AFTER DELETE ON DISPONIBILIDADE
FOR EACH ROW
BEGIN
    INSERT INTO AUDITORIA_EVENTO
        (entidade, operacao, chave_registro, dados_anteriores, dados_novos)
    VALUES
        ('DISPONIBILIDADE', 'DELETE',
         JSON_OBJECT('id_filme', OLD.id_filme, 'id_plataforma', OLD.id_plataforma,
                     'data_inicio', OLD.data_inicio),
         JSON_OBJECT('id_filme', OLD.id_filme, 'id_plataforma', OLD.id_plataforma,
                     'data_inicio', OLD.data_inicio, 'data_fim', OLD.data_fim),
         NULL);
END$$
DELIMITER ;

-- Confirma a existencia da tabela e dos triggers do esquema corrente.
SHOW CREATE TABLE AUDITORIA_EVENTO;
SELECT trigger_name, event_manipulation, action_timing, event_object_table
FROM information_schema.triggers
WHERE trigger_schema = DATABASE()
  AND trigger_name IN ('tr_aud_filme_au', 'tr_aud_disponibilidade_au',
                       'tr_aud_disponibilidade_ai', 'tr_aud_disponibilidade_ad')
ORDER BY trigger_name;

-- Para consultar os eventos apos um teste real:
-- SELECT id_evento, ocorrido_em, entidade, operacao, chave_registro,
--        dados_anteriores, dados_novos
-- FROM AUDITORIA_EVENTO
-- ORDER BY id_evento DESC;
