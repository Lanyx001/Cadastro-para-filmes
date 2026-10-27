-- =============================================================================
-- DISCIPLINA: Laboratório de Banco de Dados (2026/2)
-- PROFESSOR: Samuel Novais Moura Júnior
--
-- ARTEFATO: A6 - Script Físico DDL (01_ddl.sql)
-- DOMÍNIO: Acervo Cinematográfico / Streaming
-- =============================================================================

DROP DATABASE IF EXISTS db_acervo_filmes;
CREATE DATABASE db_acervo_filmes
    DEFAULT CHARACTER SET utf8mb4
    DEFAULT COLLATE utf8mb4_unicode_ci;

USE db_acervo_filmes;

-- -----------------------------------------------------------------------------
-- 1. Superclasse: PESSOA
-- Atende: RN07, RN10
-- -----------------------------------------------------------------------------
CREATE TABLE PESSOA (
    id_pessoa INT AUTO_INCREMENT,
    nome VARCHAR(150) NOT NULL,
    data_nascimento DATE NOT NULL,
    CONSTRAINT pk_pessoa PRIMARY KEY (id_pessoa)
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 2. Subclasse: ATOR (Especialização de PESSOA)
-- Atende: RN08, RN10
-- -----------------------------------------------------------------------------
CREATE TABLE ATOR (
    id_pessoa INT NOT NULL,
    registro_profissional VARCHAR(50) NOT NULL,
    CONSTRAINT pk_ator PRIMARY KEY (id_pessoa),
    CONSTRAINT fk_ator_pessoa FOREIGN KEY (id_pessoa) 
        REFERENCES PESSOA (id_pessoa) 
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 3. Subclasse: DIRETOR (Especialização de PESSOA)
-- Atende: RN09, RN10
-- -----------------------------------------------------------------------------
CREATE TABLE DIRETOR (
    id_pessoa INT NOT NULL,
    registro_diretor VARCHAR(50) NOT NULL,
    CONSTRAINT pk_diretor PRIMARY KEY (id_pessoa),
    CONSTRAINT fk_diretor_pessoa FOREIGN KEY (id_pessoa) 
        REFERENCES PESSOA (id_pessoa) 
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 4. Entidade Principal: FILME
-- Atende: RN01, RN02, RN03, RN04, RN13, RN20
-- -----------------------------------------------------------------------------
CREATE TABLE FILME (
    id_filme INT NOT NULL, -- Foi preciso remover o AUTO_INCREMENT para a constraint ck_filme_nao_auto_sequencia funcionar
    titulo VARCHAR(150) NOT NULL,
    ano_lancamento INT NOT NULL,
    duracao INT NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'ativo',
    id_filme_sequencia INT NULL,
    CONSTRAINT pk_filme PRIMARY KEY (id_filme),
    CONSTRAINT uq_filme_titulo_ano UNIQUE (titulo, ano_lancamento), -- RN02
    CONSTRAINT ck_filme_duracao CHECK (duracao > 0),                -- RN03
    CONSTRAINT ck_filme_ano CHECK (ano_lancamento BETWEEN 1888 AND 9999), -- RN04
    CONSTRAINT ck_filme_status CHECK (status IN ('ativo', 'desativado')), -- RN20 
    CONSTRAINT ck_filme_nao_auto_sequencia CHECK (id_filme_sequencia IS NULL OR id_filme_sequencia <> id_filme), 
    CONSTRAINT fk_filme_sequencia FOREIGN KEY (id_filme_sequencia) -- RN13
        REFERENCES FILME (id_filme) 
        ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB;


-- -----------------------------------------------------------------------------
-- 5. Categoria: GENERO
-- Atende: RN05
-- -----------------------------------------------------------------------------
CREATE TABLE GENERO (
    id_genero INT AUTO_INCREMENT,
    nome VARCHAR(50) NOT NULL,
    CONSTRAINT pk_genero PRIMARY KEY (id_genero),
    CONSTRAINT uq_genero_nome UNIQUE (nome) -- RN05
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 6. Categoria: PLATAFORMA
-- Atende: RN16
-- -----------------------------------------------------------------------------
CREATE TABLE PLATAFORMA (
    id_plataforma INT AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    tipo VARCHAR(50) NOT NULL, -- ex: Streaming, Cinema, TV
    CONSTRAINT pk_plataforma PRIMARY KEY (id_plataforma), 
    CONSTRAINT ck_plataforma_tipo CHECK (tipo IN ('Streaming', 'Cinema', 'Canal TV', 'Mídia Física'))
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 7. Categoria: USUARIO
-- Atende: RN18
-- -----------------------------------------------------------------------------
CREATE TABLE USUARIO (
    id_usuario INT AUTO_INCREMENT,
    nome VARCHAR(150) NOT NULL,
    email VARCHAR(150) NOT NULL,
    CONSTRAINT pk_usuario PRIMARY KEY (id_usuario),
    CONSTRAINT uq_usuario_email UNIQUE (email) -- RN18
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 8. Entidade Fraca: EPISODIO (Dependente de FILME)
-- Atende: RN14, RN15
-- -----------------------------------------------------------------------------
CREATE TABLE EPISODIO (
    id_filme INT NOT NULL,
    numero_episodio INT NOT NULL,
    titulo VARCHAR(150) NOT NULL,
    duracao INT NOT NULL,
    CONSTRAINT pk_episodio PRIMARY KEY (id_filme, numero_episodio),
    CONSTRAINT ck_episodio_duracao CHECK (duracao > 0),
    CONSTRAINT fk_episodio_filme FOREIGN KEY (id_filme) -- RN15
        REFERENCES FILME (id_filme) 
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 9. Associativa: ELENCO (FILME <-> ATOR) com atributo próprio
-- Atende: RN11
-- -----------------------------------------------------------------------------
CREATE TABLE ELENCO (
    id_filme INT NOT NULL,
    id_pessoa_ator INT NOT NULL,
    personagem VARCHAR(100) NOT NULL, -- Atributo próprio obrigatório (RN11)
    CONSTRAINT pk_elenco PRIMARY KEY (id_filme, id_pessoa_ator),
    CONSTRAINT fk_elenco_filme FOREIGN KEY (id_filme) 
        REFERENCES FILME (id_filme) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_elenco_ator FOREIGN KEY (id_pessoa_ator) 
        REFERENCES ATOR (id_pessoa) 
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 10. Associativa: DIRECAO (FILME <-> DIRETOR)
-- Atende: RN12
-- -----------------------------------------------------------------------------
CREATE TABLE DIRECAO (
    id_filme INT NOT NULL,
    id_pessoa_diretor INT NOT NULL,
    CONSTRAINT pk_direcao PRIMARY KEY (id_filme, id_pessoa_diretor),
    CONSTRAINT fk_direcao_filme FOREIGN KEY (id_filme) 
        REFERENCES FILME (id_filme) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_direcao_diretor FOREIGN KEY (id_pessoa_diretor) 
        REFERENCES DIRETOR (id_pessoa) 
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 11. Associativa: FILME_GENERO (FILME <-> GENERO)
-- Atende: RN06
-- -----------------------------------------------------------------------------
CREATE TABLE FILME_GENERO (
    id_filme INT NOT NULL,
    id_genero INT NOT NULL,
    CONSTRAINT pk_filme_genero PRIMARY KEY (id_filme, id_genero),
    CONSTRAINT fk_fg_filme FOREIGN KEY (id_filme) 
        REFERENCES FILME (id_filme) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_fg_genero FOREIGN KEY (id_genero) 
        REFERENCES GENERO (id_genero) 
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 12. Associativa Temporal: DISPONIBILIDADE (FILME <-> PLATAFORMA)
-- Atende: RN17 (Atributos temporais na associação)
-- -----------------------------------------------------------------------------
CREATE TABLE DISPONIBILIDADE (
    id_filme INT NOT NULL,
    id_plataforma INT NOT NULL,
    data_inicio DATE NOT NULL,
    data_fim DATE NULL,
    CONSTRAINT pk_disponibilidade PRIMARY KEY (id_filme, id_plataforma, data_inicio),
    CONSTRAINT ck_disp_datas CHECK (data_fim IS NULL OR data_fim >= data_inicio),
    CONSTRAINT fk_disp_filme FOREIGN KEY (id_filme) 
        REFERENCES FILME (id_filme) 
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_disp_plataforma FOREIGN KEY (id_plataforma) 
        REFERENCES PLATAFORMA (id_plataforma) 
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 13. Associativa: AVALIACAO (FILME <-> USUARIO) com atributos próprios
-- Atende: RN19
-- -----------------------------------------------------------------------------
CREATE TABLE AVALIACAO (
    id_filme INT NOT NULL,
    id_usuario INT NOT NULL,
    nota DECIMAL(3,1) NOT NULL,
    comentario TEXT NULL,
    data_avaliacao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_avaliacao PRIMARY KEY (id_filme, id_usuario),
    CONSTRAINT ck_avaliacao_nota CHECK (nota BETWEEN 0.0 AND 10.0),
    CONSTRAINT fk_aval_filme FOREIGN KEY (id_filme) 
        REFERENCES FILME (id_filme) 
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_aval_usuario FOREIGN KEY (id_usuario) 
        REFERENCES USUARIO (id_usuario) 
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- Índices auxiliares exigidos e recomendados (prefixo idx_)
-- -----------------------------------------------------------------------------
CREATE INDEX idx_filme_titulo ON FILME (titulo);
CREATE INDEX idx_pessoa_nome ON PESSOA (nome);
CREATE INDEX idx_disp_periodo ON DISPONIBILIDADE (data_inicio, data_fim);