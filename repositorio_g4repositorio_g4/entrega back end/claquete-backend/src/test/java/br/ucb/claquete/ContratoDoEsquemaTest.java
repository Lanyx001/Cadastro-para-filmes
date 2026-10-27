package br.ucb.claquete;

import static org.assertj.core.api.Assertions.assertThat;

import java.nio.file.Files;
import java.nio.file.Path;
import org.junit.jupiter.api.Test;

/** Verifica os contratos físicos que a API precisa respeitar, sem exigir um banco local. */
class ContratoDoEsquemaTest {
    private final String ddl = ler("../scripts sql/topicos 1.2 a 1.5/01_ddl.sql");

    @Test void filmeTemIdManualESemSinopse() {
        assertThat(ddl).contains("id_filme INT NOT NULL", "CONSTRAINT pk_filme PRIMARY KEY (id_filme)")
                .doesNotContain("sinopse");
    }

    @Test void chavesCompostasEstaoDefinidas() {
        assertThat(ddl).contains("PRIMARY KEY (id_filme, id_usuario)",
                "PRIMARY KEY (id_filme, id_plataforma, data_inicio)");
    }

    private static String ler(String arquivo) {
        try { return Files.readString(Path.of(arquivo)); }
        catch (Exception e) { throw new IllegalStateException("Não foi possível ler o DDL", e); }
    }
}
