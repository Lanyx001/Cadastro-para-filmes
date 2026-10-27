package br.ucb.claquete;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

class SenhaSeguraTest {
    private final BCryptPasswordEncoder encoder = new BCryptPasswordEncoder(12);

    @Test void bcryptAceitaSenhaCorretaERejeitaOutra() {
        String senha = "senha-de-teste-segura";
        String hash = encoder.encode(senha);
        assertThat(hash).doesNotContain(senha).startsWith("$2");
        assertThat(encoder.matches(senha, hash)).isTrue();
        assertThat(encoder.matches("senha-incorreta", hash)).isFalse();
    }

    @Test void bcryptGeraHashesDiferentesComSaltIndividual() {
        String senha = "senha-de-teste-segura";
        assertThat(encoder.encode(senha)).isNotEqualTo(encoder.encode(senha));
    }
}
