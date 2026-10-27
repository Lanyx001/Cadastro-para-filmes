-- =============================================================================
-- DISCIPLINA: Laboratório de Banco de Dados (2026/2)
-- PROFESSOR: Samuel Novais Moura Júnior
-- ARTEFATO: A7 - Script de Carga DML (02_carga.sql) - REVISADO ETAPA 2
-- DOMÍNIO: Acervo Cinematográfico / Streaming
-- =============================================================================

USE db_acervo_filmes;

-- Desativar temporariamente verificações de chaves para limpeza e recarga ordenada
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE AVALIACAO;
TRUNCATE TABLE DISPONIBILIDADE;
TRUNCATE TABLE FILME_GENERO;
TRUNCATE TABLE DIRECAO;
TRUNCATE TABLE ELENCO;
TRUNCATE TABLE EPISODIO;
TRUNCATE TABLE FILME;
TRUNCATE TABLE DIRETOR;
TRUNCATE TABLE ATOR;
TRUNCATE TABLE PESSOA;
TRUNCATE TABLE PLATAFORMA;
TRUNCATE TABLE GENERO;
TRUNCATE TABLE USUARIO;
SET FOREIGN_KEY_CHECKS = 1;

-- -----------------------------------------------------------------------------
-- 1. CARGA: GENERO (10 registros)
-- Atende: RN05
-- -----------------------------------------------------------------------------
INSERT INTO GENERO (id_genero, nome) VALUES
(1, 'Ação'),
(2, 'Drama'),
(3, 'Comédia'),
(4, 'Ficção Científica'),
(5, 'Terror'),
(6, 'Romance'),
(7, 'Animação'),
(8, 'Aventura'),
(9, 'Suspense'),
(10, 'Documentário');

-- -----------------------------------------------------------------------------
-- 2. CARGA: PLATAFORMA (8 registros)
-- Atende: RN16 e ck_plataforma_tipo ('Streaming', 'Cinema', 'Canal TV', 'Mídia Física')
-- -----------------------------------------------------------------------------
INSERT INTO PLATAFORMA (id_plataforma, nome, tipo) VALUES
(1, 'CineMax Taguatinga', 'Cinema'),
(2, 'StreamFlix Brasil', 'Streaming'),
(3, 'PrimeVision', 'Streaming'),
(4, 'MaxPlay Vídeo', 'Streaming'),
(5, 'ToonPlus', 'Streaming'),
(6, 'CineHome Premium', 'Streaming'),
(7, 'Canal CineCult Brasil', 'Canal TV'),
(8, 'Cine Drive-in Taguatinga', 'Cinema');

-- -----------------------------------------------------------------------------
-- 3. CARGA: USUARIO (25 registros sintéticos)
-- Atende: RN18
-- -----------------------------------------------------------------------------
INSERT INTO USUARIO (id_usuario, nome, email) VALUES
(1, 'Lucas Silva Medeiros', 'lucas.medeiros@exemplo.com'),
(2, 'Mariana Costa Rios', 'mariana.rios@exemplo.com'),
(3, 'Pedro Henrique Bastos', 'pedro.bastos@exemplo.com'),
(4, 'Beatriz Souza Lemos', 'beatriz.lemos@exemplo.com'),
(5, 'Rafael Alencar Prado', 'rafael.prado@exemplo.com'),
(6, 'Camila Rocha Nogueira', 'camila.nogueira@exemplo.com'),
(7, 'Gustavo Borges Viana', 'gustavo.viana@exemplo.com'),
(8, 'Larissa Ramos Toledo', 'larissa.toledo@exemplo.com'),
(9, 'Thiago Mendes Queiroz', 'thiago.queiroz@exemplo.com'),
(10, 'Fernanda Lima Duarte', 'fernanda.duarte@exemplo.com'),
(11, 'Rodrigo Tavares Bueno', 'rodrigo.bueno@exemplo.com'),
(12, 'Juliana Nogueira Abreu', 'juliana.abreu@exemplo.com'),
(13, 'André Farias Neves', 'andre.neves@exemplo.com'),
(14, 'Patrícia Castro Pires', 'patricia.pires@exemplo.com'),
(15, 'Marcelo Antunes Fonseca', 'marcelo.fonseca@exemplo.com'),
(16, 'Aline Martins Peixoto', 'aline.peixoto@exemplo.com'),
(17, 'Felipe Duarte Sampaio', 'felipe.sampaio@exemplo.com'),
(18, 'Carla Prado Miranda', 'carla.miranda@exemplo.com'),
(19, 'Bruno Guimarães Macedo', 'bruno.macedo@exemplo.com'),
(20, 'Vanessa Dias Resende', 'vanessa.resende@exemplo.com'),
(21, 'Diego Silveira Barreto', 'diego.barreto@exemplo.com'),
(22, 'Sofia Camargo Antunes', 'sofia.antunes@exemplo.com'),
(23, 'Vinícius Meireles Cunha', 'vinicius.cunha@exemplo.com'),
(24, 'Isabela Freitas Gontijo', 'isabela.gontijo@exemplo.com'),
(25, 'Eduardo Paiva Teles', 'eduardo.teles@exemplo.com');

-- -----------------------------------------------------------------------------
-- 4. CARGA: PESSOA (45 registros totalmente fictícios - Mínimo >= 40)
-- Atende: RN07, RN10
-- -----------------------------------------------------------------------------
INSERT INTO PESSOA (id_pessoa, nome, data_nascimento) VALUES
(1, 'Carlos Eduardo Marcondes', '1971-04-12'),
(2, 'Leandro Drummond Ramos', '1975-09-23'),
(3, 'Renato Silveira Guimarães', '1964-11-05'),
(4, 'Breno Castelo Branco', '1966-02-18'),
(5, 'Helena Vargas Moretti', '1982-06-14'),
(6, 'Marina Vasconcelos Rios', '1989-10-30'),
(7, 'Danilo Albuquerque Prado', '1968-07-21'),
(8, 'Tiago Mendonça Frota', '1994-03-19'),
(9, 'Marcio Saldanha Bueno', '1952-12-08'),
(10, 'Roberto Junqueira Maia', '1955-08-11'),
(11, 'Silvio Barreto Fagundes', '1958-01-26'),
(12, 'Tomas Antunes Brandão', '1962-05-17'),
(13, 'Gustavo Beltrão Diniz', '1965-09-02'),
(14, 'Douglas Fontes Carvalhal', '1970-11-29'),
(15, 'Julio Cesar Peçanha', '1978-04-03'),
(16, 'Daniel Cordeiro Viana', '1987-08-14'),
(17, 'Bernardo Shinoda Luz', '1972-02-28'),
(18, 'Samuel Kanno Ferreira', '1969-12-16'),
(19, 'Alvaro Calderon Brito', '1963-07-09'),
(20, 'Yara Pimentel Duarte', '1992-05-24'),
(21, 'Jonas Valadares Campos', '1959-10-04'),
(22, 'Sergio Wanderley Lins', '1977-03-15'),
(23, 'Rodrigo Scalco Toledo', '1954-06-22'),
(24, 'Simone Veiga Matos', '1960-01-19'),
(25, 'Gilberto Nogueira Arantes', '1953-08-30'),
(26, 'Clarice Telles Fagundes', '1976-12-03'),
(27, 'Tarcisio Werneck Sales', '1974-04-27'),
(28, 'Rodrigo Becker Pires', '2005-09-12'),
(29, 'Dario Chaves Gusmão', '1984-07-18'),
(30, 'Raul Gouveia Meireles', '1981-11-07'),
(31, 'Wagner Siqueira Villela', '1970-08-25'),
(32, 'Ronaldo Faraco Medeiros', '1965-03-14'),
(33, 'David Fernandes Couto', '1967-10-10'),
(34, 'Jonas Esteves Morais', '1985-02-09'),
(35, 'Clemente Pacheco Maia', '1950-05-20'),
(36, 'Benjamin Avelar Rios', '1973-09-18'),
(37, 'Kleber Brandão Sanches', '1966-12-01'),
(38, 'Caio Munhoz Portela', '1979-06-13'),
(39, 'Elisa Santoro Paiva', '1987-04-29'),
(40, 'Fernanda Prestes Vilar', '1995-01-22'),
(41, 'Zelia Cavalcanti Moura', '1997-08-08'),
(42, 'Mateus Donato Ferraz', '1973-11-15'),
(43, 'Cristiano Bicalho Prado', '1976-02-27'),
(44, 'Almir Paschoalino Gomes', '1951-07-16'),
(45, 'Miriam Severo Coutinho', '1956-09-04');

-- -----------------------------------------------------------------------------
-- 5. CARGA: ATOR (Subclasse de PESSOA)
-- Atende: RN08, RN10
-- Casos de contorno: pessoas que também exercem direção (sobreposição)
-- -----------------------------------------------------------------------------
INSERT INTO ATOR (id_pessoa, registro_profissional) VALUES
(2, 'DRT-102030-DF'),
(4, 'DRT-102031-DF'),
(6, 'DRT-102032-DF'),
(8, 'DRT-102033-GO'),
(10, 'DRT-102034-SP'),
(12, 'DRT-102035-RJ'),
(14, 'DRT-102036-MG'),
(16, 'DRT-102037-RS'),
(18, 'DRT-102038-BA'),
(20, 'DRT-102039-PE'),
(22, 'DRT-102040-SC'),
(24, 'DRT-102041-GO'),
(26, 'DRT-102042-SP'),
(28, 'DRT-102043-RJ'),
(30, 'DRT-102044-DF'),
(32, 'DRT-102045-SP'),
(34, 'DRT-102046-MG'),
(35, 'DRT-102047-RS'), -- Atua e Dirige (Caso de contorno)
(36, 'DRT-102048-RJ'), -- Atua e Dirige (Caso de contorno)
(37, 'DRT-102049-SP'), -- Atua e Dirige (Caso de contorno)
(38, 'DRT-102050-DF'),
(39, 'DRT-102051-SP'),
(40, 'DRT-102052-RJ'),
(41, 'DRT-102053-MG'),
(42, 'DRT-102054-SP'),
(43, 'DRT-102055-RJ'),
(44, 'DRT-102056-SP'),
(45, 'DRT-102057-RJ'),
(3,  'DRT-102058-SP'), -- Atua e Dirige
(5,  'DRT-102059-RJ'), -- Atua e Dirige
(15, 'DRT-102060-DF'), -- Atua e Dirige
(27, 'DRT-102061-SP'); -- Atua e Dirige

-- -----------------------------------------------------------------------------
-- 6. CARGA: DIRETOR (Subclasse de PESSOA)
-- Atende: RN09, RN10
-- -----------------------------------------------------------------------------
INSERT INTO DIRETOR (id_pessoa, registro_diretor) VALUES
(1, 'DIR-7001-BR'),
(3, 'DIR-7002-BR'),
(5, 'DIR-7003-BR'),
(7, 'DIR-7004-BR'),
(9, 'DIR-7005-BR'),
(11, 'DIR-7006-BR'),
(13, 'DIR-7007-BR'),
(15, 'DIR-7008-BR'),
(17, 'DIR-7009-BR'),
(19, 'DIR-7010-BR'),
(21, 'DIR-7011-BR'),
(23, 'DIR-7012-BR'),
(25, 'DIR-7013-BR'),
(27, 'DIR-7014-BR'),
(29, 'DIR-7015-BR'),
(31, 'DIR-7016-BR'),
(33, 'DIR-7017-BR'),
(35, 'DIR-7018-BR'),
(36, 'DIR-7019-BR'),
(37, 'DIR-7020-BR');

-- -----------------------------------------------------------------------------
-- 7. CARGA: FILME (42 registros - Mínimo >= 40)
-- Atende: RN01, RN02, RN03, RN04, RN13, RN20, ck_filme_nao_auto_sequencia
-- -----------------------------------------------------------------------------
INSERT INTO FILME (id_filme, titulo, ano_lancamento, duracao, status, id_filme_sequencia) VALUES
(1, 'Origens do Guerreiro', 2005, 140, 'ativo', NULL),
(2, 'O Cavaleiro da Noite', 2008, 152, 'ativo', NULL),
(3, 'O Retorno Triunfal', 2012, 165, 'ativo', NULL),
(4, 'Duna de Areia: Parte I', 2021, 155, 'ativo', NULL),
(5, 'Duna de Areia: Parte II', 2024, 166, 'ativo', NULL),
(6, 'Visitante Sideral', 1979, 117, 'ativo', NULL),
(7, 'O Segundo Confronto', 1986, 137, 'ativo', NULL),
(8, 'Mundo Primordial', 2009, 162, 'ativo', NULL),
(9, 'Mundo Primordial: Mares Profundos', 2022, 192, 'ativo', NULL),
(10, 'Labirinto dos Sonhos', 2010, 148, 'ativo', NULL),
(11, 'Fronteiras do Infinito', 2014, 169, 'ativo', NULL),
(12, 'O Projeto do Século', 2023, 180, 'ativo', NULL),
(13, 'Histórias Urbanas', 1994, 154, 'ativo', NULL),
(14, 'Bastardos da Vingança', 2009, 153, 'ativo', NULL),
(15, 'Era Uma Vez no Planalto', 2019, 161, 'ativo', NULL),
(16, 'Passos da Juventude', 2017, 94, 'ativo', NULL),
(17, 'Quatro Destinos', 2019, 135, 'ativo', NULL),
(18, 'Mundo de Plástico', 2023, 114, 'ativo', NULL),
(19, 'Primeiro Contato', 2016, 116, 'ativo', NULL),
(20, 'Androides do Futuro', 2017, 164, 'ativo', NULL),
(21, 'Motorista da Madrugada', 1976, 114, 'ativo', NULL),
(22, 'Irmãos da Lei Paralela', 1990, 145, 'ativo', NULL),
(23, 'O Veterano Solitário', 2019, 209, 'ativo', NULL),
(24, 'Ilha dos Gigantes', 1993, 127, 'ativo', NULL),
(25, 'Lista de Esperança', 1993, 195, 'ativo', NULL),
(26, 'Resgate na Linha de Frente', 1998, 169, 'ativo', NULL),
(27, 'O Reino das Sombras', 2006, 118, 'ativo', NULL),
(28, 'Forma da Água Viva', 2017, 123, 'ativo', NULL),
(29, 'Fuja da Casa Grande', 2017, 104, 'ativo', NULL),
(30, 'Nós no Espelho', 2019, 116, 'ativo', NULL),
(31, 'Não Olhe Para Cima', 2022, 130, 'ativo', NULL),
(32, 'Intrusos na Mansão', 2019, 132, 'ativo', NULL),
(33, 'Memórias da Capital', 2018, 135, 'ativo', NULL),
(34, 'Velocidade e Deserto', 2015, 120, 'ativo', NULL),
(35, 'Amigo Imaginário', 2019, 108, 'ativo', NULL),
(36, 'Cidade das Estrelas', 2016, 128, 'ativo', NULL),
(37, 'Ritmo Obsessivo', 2014, 106, 'ativo', NULL),
(38, 'Hotel das Cordilheiras', 2014, 99, 'ativo', NULL),
(39, 'Rede de Conexões', 2010, 120, 'ativo', NULL),
(40, 'Os Imperdoáveis do Sertão', 1992, 130, 'ativo', NULL),
(41, 'Cidade Blindada', 2010, 125, 'ativo', NULL),
(42, 'Piloto Cancelado dos Arquivos', 2020, 90, 'desativado', NULL); -- Caso de contorno: exclusão lógica (RN20)

-- Estabelecendo autorrelacionamento válido (RN13 e ck_filme_nao_auto_sequencia)
UPDATE FILME SET id_filme_sequencia = 2 WHERE id_filme = 1;
UPDATE FILME SET id_filme_sequencia = 3 WHERE id_filme = 2;
UPDATE FILME SET id_filme_sequencia = 5 WHERE id_filme = 4;
UPDATE FILME SET id_filme_sequencia = 7 WHERE id_filme = 6;
UPDATE FILME SET id_filme_sequencia = 9 WHERE id_filme = 8;

-- -----------------------------------------------------------------------------
-- 8. CARGA: EPISODIO (15 registros de entidade fraca vinculada a FILME)
-- Atende: RN14, RN15
-- -----------------------------------------------------------------------------
INSERT INTO EPISODIO (id_filme, numero_episodio, titulo, duracao) VALUES
(1, 1, 'Bastidores: A Criação do Mito', 45),
(1, 2, 'Engenharia dos Veículos Táticos', 25),
(2, 1, 'Construindo o Caos no Roteiro', 50),
(4, 1, 'Concepção do Planeta Desértico', 60),
(5, 1, 'Dialetos e Costumes Nativos', 30),
(10, 1, 'Arquitetura e Dimensão dos Sonhos', 35),
(11, 1, 'Fundamentos de Astrofísica Aplicada', 55),
(12, 1, 'A Simulação Científica em Foco', 40),
(18, 1, 'Direção de Arte e Cenografia Rosa', 28),
(27, 1, 'Maquiagem e Caracterização Prática', 32),
(32, 1, 'A Arquitetura dos Ambientes Opostos', 42),
(34, 1, 'Oficina e Blindagem das Máquinas', 52),
(36, 1, 'Ensaios e Arranjos no Asfalto', 26),
(38, 1, 'Paleta Simétrica e Miniaturas', 20),
(42, 1, 'Episódio Experimental Arquivado', 45);

-- -----------------------------------------------------------------------------
-- 9. CARGA: FILME_GENERO (Associação N:N)
-- Atende: RN06
-- -----------------------------------------------------------------------------
INSERT INTO FILME_GENERO (id_filme, id_genero) VALUES
(1, 1), (1, 9),
(2, 1), (2, 2), (2, 9),
(3, 1), (3, 9),
(4, 4), (4, 8),
(5, 4), (5, 8),
(6, 4), (6, 5),
(7, 1), (7, 4), (7, 5),
(8, 4), (8, 8),
(9, 4), (9, 8),
(10, 4), (10, 9),
(11, 4), (11, 2),
(12, 2), (12, 10),
(13, 2), (13, 9),
(14, 1), (14, 2),
(15, 2), (15, 3),
(16, 2), (16, 3),
(17, 2), (17, 6),
(18, 3), (18, 8),
(19, 4), (19, 2),
(20, 4), (20, 9),
(21, 2),
(22, 2),
(23, 2),
(24, 4), (24, 8),
(25, 2),
(26, 1), (26, 2),
(27, 2), (27, 5),
(28, 2), (28, 6),
(29, 5), (29, 9),
(30, 5), (30, 9),
(31, 4), (31, 5),
(32, 2), (32, 9),
(33, 2),
(34, 1), (34, 4),
(35, 2), (35, 3),
(36, 2), (36, 6),
(37, 2),
(38, 3), (38, 8),
(39, 2),
(40, 2),
(41, 1), (41, 2),
(42, 3);

-- -----------------------------------------------------------------------------
-- 10. CARGA: DIRECAO (Associação N:N com DIRETOR)
-- Atende: RN12
-- -----------------------------------------------------------------------------
INSERT INTO DIRECAO (id_filme, id_pessoa_diretor) VALUES
(1, 1),
(2, 1),
(3, 1),
(4, 7),
(5, 7),
(6, 23),
(7, 21),
(8, 21),
(9, 21),
(10, 1),
(11, 1),
(12, 1),
(13, 3),
(14, 3),
(15, 3),
(16, 5),
(17, 5),
(18, 5),
(19, 7),
(20, 7),
(21, 9),
(22, 9),
(23, 9),
(24, 11),
(25, 11),
(26, 11),
(27, 13),
(28, 13),
(29, 15),
(30, 15),
(31, 15),
(32, 17),
(33, 19),
(34, 25),
(35, 27),
(36, 29),
(37, 29),
(38, 31),
(39, 33),
(40, 35),
(41, 36),
(42, 27);

-- -----------------------------------------------------------------------------
-- 11. CARGA: ELENCO (Associação N:N com ATOR e atributo obrigatório)
-- Atende: RN11
-- -----------------------------------------------------------------------------
INSERT INTO ELENCO (id_filme, id_pessoa_ator, personagem) VALUES
(1, 43, 'Bruno Martins / Vigilante'),
(2, 43, 'Bruno Martins / Vigilante'),
(2, 38, 'Dr. Arnaldo Crane'),
(3, 43, 'Bruno Martins / Vigilante'),
(4, 8, 'Paulo Albuquerque'),
(4, 41, 'Shani das Areias'),
(5, 8, 'Paulo Albuquerque'),
(5, 41, 'Shani das Areias'),
(5, 40, 'Princesa Sofia'),
(6, 24, 'Tenente Raquel'),
(7, 24, 'Tenente Raquel'),
(8, 22, 'Jaime Silva'),
(8, 24, 'Dra. Gabriela Veiga'),
(9, 22, 'Jaime Silva'),
(9, 24, 'Kira das Marés'),
(10, 2, 'Dominic Rios'),
(10, 38, 'Roberto Fagundes'),
(11, 42, 'Dr. Manfredo'),
(12, 38, 'Dr. Julio Portela'),
(12, 40, 'Joana Santos'),
(12, 42, 'General Ferraz'),
(13, 4, 'Vicente Gomes'),
(14, 4, 'Tenente Renato'),
(15, 2, 'Ricardo Dalton'),
(15, 4, 'Claudio Boaventura'),
(15, 6, 'Sara Lins'),
(16, 5, 'Professora Marta'),
(17, 8, 'Lorenzo Fontes'),
(17, 40, 'Amelia Matos'),
(17, 45, 'Tia Cecília'),
(18, 6, 'Boneca Bela'),
(18, 30, 'Kenzo Modelo'),
(19, 34, 'Dr. Ian Nogueira'),
(20, 30, 'Agente Especial 40'),
(21, 10, 'Travis Condutor'),
(22, 10, 'Jaime Paranhos'),
(23, 10, 'Francisco Saldanha'),
(23, 44, 'Almir Barroso'),
(24, 14, 'Dr. Henrique Biólogo'),
(25, 32, 'Comandante Otto'),
(26, 12, 'Capitão Antunes'),
(26, 42, 'Soldado Cristiano'),
(27, 14, 'Criatura Mística'),
(28, 14, 'Ser Subaquático'),
(29, 16, 'Cristiano Ferreira'),
(30, 16, 'Gabriel Viana'),
(31, 16, 'Otavio Silva'),
(32, 18, 'Carlos Kim'),
(33, 20, 'Clara Faxineira'),
(34, 26, 'Comandante Fúria'),
(35, 27, 'Mentor Sátira'),
(35, 28, 'Menino Jonas'),
(36, 30, 'Sebastião Pianista'),
(36, 39, 'Mariana Atriz'),
(37, 34, 'Baterista Rival'),
(38, 32, 'Gustavo Camareiro'),
(39, 34, 'Marcos Programador'),
(40, 35, 'Guilherme Muniz'),
(41, 36, 'Douglas Maciel'),
(42, 28, 'Protagonista de Teste');

-- -----------------------------------------------------------------------------
-- 12. CARGA: DISPONIBILIDADE (Associação Temporal FILME <-> PLATAFORMA)
-- Atende: RN17, RN20 e ck_disp_datas
-- Casos de contorno: contratos em aberto (data_fim NULL) e reentradas
-- -----------------------------------------------------------------------------
INSERT INTO DISPONIBILIDADE (id_filme, id_plataforma, data_inicio, data_fim) VALUES
(1, 4, '2021-01-01', '2021-12-31'),
(1, 4, '2023-01-01', NULL), -- Contrato vigente em aberto
(2, 4, '2021-01-01', '2021-12-31'),
(2, 4, '2023-01-01', NULL),
(3, 4, '2023-01-01', NULL),
(4, 4, '2022-03-01', '2023-06-30'),
(4, 2, '2023-10-01', NULL),
(5, 1, '2024-03-01', '2024-05-30'), -- Exibição em cinema
(5, 4, '2024-06-01', NULL),
(6, 5, '2021-05-01', NULL),
(7, 5, '2021-05-01', NULL),
(8, 1, '2009-12-18', '2010-04-30'),
(8, 5, '2020-11-17', NULL),
(9, 1, '2022-12-15', '2023-04-15'),
(9, 5, '2023-06-07', NULL),
(10, 2, '2020-01-01', '2022-12-31'),
(10, 3, '2023-01-01', NULL),
(11, 3, '2021-08-01', NULL),
(12, 1, '2023-07-20', '2023-11-30'),
(12, 3, '2024-04-01', NULL),
(13, 2, '2019-01-01', NULL),
(14, 2, '2020-05-01', NULL),
(15, 2, '2021-03-01', '2022-03-01'),
(16, 2, '2022-07-01', NULL),
(17, 3, '2021-02-01', NULL),
(18, 1, '2023-07-20', '2023-10-31'),
(18, 4, '2023-12-15', NULL),
(19, 2, '2021-09-01', NULL),
(20, 2, '2020-01-01', '2021-12-31'),
(21, 7, '2023-01-01', NULL),
(22, 4, '2022-01-01', NULL),
(23, 2, '2019-11-27', NULL),
(24, 3, '2020-01-01', NULL),
(25, 2, '2021-06-01', NULL),
(26, 3, '2022-04-01', NULL),
(27, 2, '2020-10-01', NULL),
(28, 5, '2021-01-01', NULL),
(29, 2, '2019-08-01', '2021-08-01'),
(30, 3, '2021-05-01', NULL),
(31, 3, '2023-03-01', NULL),
(32, 4, '2021-02-01', NULL),
(33, 2, '2018-12-14', NULL),
(34, 4, '2020-05-01', NULL),
(35, 5, '2021-07-01', NULL),
(36, 2, '2019-03-01', NULL),
(37, 4, '2021-11-01', NULL),
(38, 5, '2021-08-01', NULL),
(39, 4, '2022-09-01', NULL),
(40, 7, '2022-01-01', NULL),
(41, 4, '2021-04-01', NULL);

-- -----------------------------------------------------------------------------
-- 13. CARGA: AVALIACAO (Tabela de Maior Movimento - 105 Registros)
-- Atende: RN19, RN20 e ck_avaliacao_nota
-- Mínimo de 100 registros atendido. Casos de contorno: comentários nulos, notas 0.0 e 10.0
-- -----------------------------------------------------------------------------
INSERT INTO AVALIACAO (id_filme, id_usuario, nota, comentario, data_avaliacao) VALUES
(1, 1, 9.0, 'Excelente reinício de narrativa, tom realista bem conduzido.', '2024-01-10 14:20:00'),
(1, 2, 8.5, 'Atuação do protagonista é muito sólida e consistente.', '2024-01-12 19:30:00'),
(1, 3, 7.5, NULL, '2024-01-15 08:45:00'), -- Comentário opcional nulo
(2, 1, 10.0, 'Obra irretocável em tensão, ritmo e fotografia.', '2024-01-10 17:00:00'), -- Nota máxima
(2, 2, 10.0, 'O antagonista principal entrega uma interpretação impecável.', '2024-01-11 21:15:00'),
(2, 3, 9.5, 'Roteiro muito bem amarrado do início ao fim.', '2024-01-13 11:10:00'),
(2, 4, 10.0, NULL, '2024-01-14 22:05:00'),
(2, 5, 9.0, 'Sequências de ação primorosas.', '2024-01-16 18:40:00'),
(3, 1, 8.0, 'Fechamento digno para o arco do herói.', '2024-01-20 20:00:00'),
(3, 2, 7.5, 'Vilão intimidador, mas o terceiro ato correu demais.', '2024-01-22 15:30:00'),
(3, 6, 8.5, NULL, '2024-01-23 09:10:00'),
(4, 4, 9.0, 'Identidade visual e trilha sonora impressionantes.', '2024-02-01 19:25:00'),
(4, 5, 8.5, 'Construção contemplativa e fiel ao romance.', '2024-02-02 21:00:00'),
(4, 6, 9.0, 'Imersão nos cenários do deserto é espetacular.', '2024-02-03 16:45:00'),
(4, 7, 7.0, 'Extenso demais em alguns trechos expositivos.', '2024-02-05 14:15:00'),
(5, 4, 9.5, 'Superou com folga o primeiro capítulo da saga!', '2024-03-10 22:30:00'),
(5, 5, 10.0, 'Cenas de combate épicas e fotografia brilhante.', '2024-03-11 18:20:00'),
(5, 6, 9.0, NULL, '2024-03-12 12:00:00'),
(5, 7, 8.5, 'Composição sonora de alto nível técnico.', '2024-03-14 20:10:00'),
(5, 8, 9.5, 'Novo marco de ficção científica do acervo.', '2024-03-15 17:50:00'),
(6, 8, 9.0, 'Clássico espacial de isolamento e suspense.', '2024-02-10 21:00:00'),
(6, 9, 8.5, 'Efeitos físicos e práticos primorosos para a época.', '2024-02-12 18:30:00'),
(6, 10, 9.0, NULL, '2024-02-15 11:20:00'),
(7, 8, 9.0, 'Ação ininterrupta e ritmo excelente.', '2024-02-18 20:40:00'),
(7, 9, 8.5, 'Abordagem diferente do antecessor, mas marcante.', '2024-02-20 14:10:00'),
(8, 10, 7.5, 'Marco técnico na computação gráfica.', '2024-02-22 16:00:00'),
(8, 11, 8.0, NULL, '2024-02-25 19:15:00'),
(9, 10, 7.0, 'Visual oceânico deslumbrante, porém longo.', '2024-03-01 22:10:00'),
(9, 11, 7.5, 'Biologia alienígena apresentada com perfeição.', '2024-03-03 15:40:00'),
(10, 1, 9.5, 'Premissa inteligente com execução criativa.', '2024-01-25 13:00:00'),
(10, 3, 9.0, 'Edição e montagem paralelas impressionantes.', '2024-01-28 17:50:00'),
(10, 12, 8.5, NULL, '2024-02-02 20:30:00'),
(10, 13, 10.0, 'Um dos melhores roteiros originais do catálogo.', '2024-02-04 22:45:00'),
(11, 1, 10.0, 'Emocionante e ambicioso cientificamente.', '2024-02-06 21:10:00'),
(11, 12, 9.5, 'Final tocante com mensagem profunda.', '2024-02-08 19:00:00'),
(11, 13, 9.0, NULL, '2024-02-10 14:35:00'),
(11, 14, 8.0, 'Conceitos temporais envolventes.', '2024-02-11 11:00:00'),
(12, 1, 9.5, 'Biografia histórica densa com edição precisa.', '2024-02-15 16:20:00'),
(12, 14, 9.0, 'Atuação central visceral e contida.', '2024-02-17 18:40:00'),
(12, 15, 8.5, NULL, '2024-02-19 21:50:00'),
(12, 16, 9.0, 'Sequência do teste prático é de tirar o fôlego.', '2024-02-21 23:10:00'),
(13, 15, 9.5, 'Diálogos memoráveis e trilha marcante.', '2024-02-23 15:00:00'),
(13, 16, 9.0, 'Narrativa não linear montada com maestria.', '2024-02-24 19:30:00'),
(13, 17, 8.5, NULL, '2024-02-26 12:45:00'),
(14, 15, 9.0, 'Tensão máxima na cena da taverna.', '2024-02-28 20:15:00'),
(14, 17, 9.0, 'Antagonista carismático e aterrorizante.', '2024-03-01 17:00:00'),
(15, 16, 8.0, 'Homenagem afetuosa ao cinema clássico.', '2024-03-02 21:40:00'),
(15, 18, 7.5, NULL, '2024-03-04 14:20:00'),
(16, 18, 8.5, 'Sensível, cômico e muito autêntico.', '2024-03-05 18:10:00'),
(16, 19, 9.0, 'Direção impecável sobre relações familiares.', '2024-03-06 20:30:00'),
(17, 18, 8.5, 'Adaptação contemporânea muito elegante.', '2024-03-08 16:00:00'),
(17, 19, 8.0, NULL, '2024-03-09 11:30:00'),
(18, 2, 8.5, 'Divertido, satírico e esteticamente rico.', '2024-03-11 19:50:00'),
(18, 6, 8.0, 'Figurinos e direção de arte impecáveis.', '2024-03-12 21:00:00'),
(18, 20, 7.5, NULL, '2024-03-13 14:15:00'),
(18, 21, 6.5, 'Bom entretenimento, embora com ritmo irregular.', '2024-03-15 17:35:00'),
(19, 7, 9.5, 'Reflexão profunda sobre linguagem e tempo.', '2024-03-16 20:00:00'),
(19, 21, 9.0, NULL, '2024-03-18 10:40:00'),
(20, 7, 9.0, 'Fotografia que beira a pintura em cada plano.', '2024-03-20 22:15:00'),
(20, 22, 8.5, 'Identidade visual forte e atmosfera densa.', '2024-03-22 16:30:00'),
(21, 9, 9.5, 'Estudo sombrio sobre solidão nas grandes cidades.', '2024-03-23 18:45:00'),
(21, 22, 9.0, NULL, '2024-03-24 14:00:00'),
(22, 9, 9.5, 'Referência absoluta no cinema sobre crime organizado.', '2024-03-25 21:10:00'),
(22, 23, 9.0, 'Ritmo frenético e atuações inspiradas.', '2024-03-26 19:20:00'),
(23, 23, 8.0, 'Melancólico e reflexivo sobre o envelhecimento.', '2024-03-27 22:00:00'),
(23, 24, 8.5, NULL, '2024-03-28 15:30:00'),
(24, 11, 9.5, 'Divisor de águas no uso de efeitos computadorizados.', '2024-03-29 17:40:00'),
(24, 24, 9.0, 'Sensação de deslumbramento genuína.', '2024-03-30 20:10:00'),
(25, 11, 10.0, 'Retrato histórico doloroso contado com sensibilidade.', '2024-04-01 19:00:00'),
(25, 25, 9.5, NULL, '2024-04-02 21:30:00'),
(26, 11, 9.5, 'Sequência de abertura do desembarque é inigualável.', '2024-04-03 16:15:00'),
(26, 25, 9.0, 'Impactante do ponto de vista técnico e humano.', '2024-04-04 18:50:00'),
(27, 13, 9.0, 'Fábula sombria com excelente concepção visual.', '2024-04-05 20:30:00'),
(27, 25, 8.5, NULL, '2024-04-06 13:20:00'),
(28, 13, 8.0, 'Romance poético e criativo.', '2024-04-07 15:45:00'),
(29, 15, 9.5, 'Crítica afiada costurada com suspense impecável.', '2024-04-08 21:00:00'),
(29, 16, 9.0, 'Atmosfera desconfortável que prende o espectador.', '2024-04-09 19:10:00'),
(30, 16, 7.5, 'Bons momentos de mistério, clímax acelerado.', '2024-04-10 22:15:00'),
(31, 16, 8.0, NULL, '2024-04-11 14:00:00'),
(32, 17, 10.0, 'Construção de tensão social milimetricamente pensada.', '2024-04-12 20:45:00'),
(32, 18, 9.5, 'Reviravoltas orgânicas e direção precisa.', '2024-04-13 18:30:00'),
(33, 19, 8.5, 'Fotografia em preto e branco magistral.', '2024-04-14 16:00:00'),
(34, 20, 9.5, 'Cenas de perseguição no ápice dos efeitos práticos.', '2024-04-15 21:40:00'),
(34, 21, 9.0, NULL, '2024-04-16 11:20:00'),
(35, 22, 8.5, 'Equilíbrio sutil entre comédia e drama humano.', '2024-04-17 19:30:00'),
(36, 2, 9.0, 'Química fantástica dos protagonistas em tela.', '2024-04-18 20:50:00'),
(36, 23, 8.5, NULL, '2024-04-19 14:10:00'),
(37, 24, 9.5, 'Intensidade dramática do confronto é eletrizante.', '2024-04-20 17:00:00'),
(38, 25, 8.5, 'Estética simétrica e humor sofisticado impecáveis.', '2024-04-21 21:15:00'),
(39, 1, 9.0, 'Roteiro dinâmico, diálogos rápidos e precisos.', '2024-04-22 18:00:00'),
(40, 3, 9.0, 'Desconstrução reflexiva dos mitos do faroeste.', '2024-04-23 20:20:00'),
(41, 5, 8.0, 'Ação urbana policial bem executada.', '2024-04-24 22:00:00'),
(42, 1, 0.0, 'Projeto descontinuado e sem coerência temática.', '2024-04-25 10:00:00'), -- Nota mínima (0.0) em obra desativada
(42, 2, 0.5, 'Produção falha, mantido apenas para arquivo histórico.', '2024-04-25 11:15:00'),
(1, 4, 8.0, 'Revendo anos após o lançamento, envelheceu muito bem.', '2024-05-01 19:00:00'),
(2, 6, 9.5, 'Sequência da perseguição continua sendo referência.', '2024-05-02 21:30:00'),
(3, 7, 7.0, NULL, '2024-05-03 14:40:00'),
(4, 8, 8.5, 'Figurinos e caracterização de alto nível.', '2024-05-04 18:20:00'),
(5, 9, 9.0, 'Conclusão épica para o conflito nos desertos.', '2024-05-05 20:00:00'),
(10, 10, 9.0, 'Cada revisão revela detalhes novos na trama.', '2024-05-06 22:10:00'),
(11, 11, 10.0, 'Impacto emocional e grandiosidade cinematográfica.', '2024-05-07 16:50:00'),
(12, 12, 9.0, 'Construção sonora da contagem regressiva é impecável.', '2024-05-08 19:40:00'),
(13, 13, 9.5, NULL, '2024-05-09 23:00:00'),
(14, 14, 9.0, 'Excelente tensão e ritmo narrativo afiado.', '2024-05-10 17:30:00'),
(32, 15, 10.0, 'Roteiro brilhante, merecedor de todo o reconhecimento.', '2024-05-11 21:00:00');