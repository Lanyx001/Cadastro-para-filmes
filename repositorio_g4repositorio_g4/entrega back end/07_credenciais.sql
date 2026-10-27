-- =============================================================================
-- ETAPA 2.4 - Estrutura minima para credenciais seguras
-- Banco: MySQL 8+ | Esquema: db_acervo_filmes
-- Execute depois de 01_ddl.sql. Este script nao armazena senhas em texto puro.
-- =============================================================================

USE db_acervo_filmes;

CREATE TABLE IF NOT EXISTS USUARIO_CREDENCIAL (
    id_usuario INT NOT NULL,
    hash_senha VARCHAR(100) NOT NULL,
    atualizado_em DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT pk_usuario_credencial PRIMARY KEY (id_usuario),
    CONSTRAINT fk_credencial_usuario FOREIGN KEY (id_usuario)
        REFERENCES USUARIO (id_usuario)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- Verificacao estrutural: ha somente o hash BCrypt, nunca uma coluna de senha.
SHOW COLUMNS FROM USUARIO_CREDENCIAL;
SHOW CREATE TABLE USUARIO_CREDENCIAL;
