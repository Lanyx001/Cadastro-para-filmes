package br.ucb.claquete.service;

import br.ucb.claquete.exception.RecursoNaoEncontradoException;
import br.ucb.claquete.exception.RequisicaoInvalidaException;
import java.util.List;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/** Armazena somente hashes BCrypt; a senha original nunca e persistida ou devolvida. */
@Service
public class CredencialService {
    private final JdbcTemplate jdbc;
    private final PasswordEncoder encoder;

    public CredencialService(JdbcTemplate jdbc, PasswordEncoder encoder) {
        this.jdbc = jdbc;
        this.encoder = encoder;
    }

    @Transactional
    public void definirSenha(int usuarioId, String senha) {
        validarSenha(senha);
        if (jdbc.queryForObject("SELECT COUNT(*) FROM USUARIO WHERE id_usuario=?", Long.class, usuarioId) == 0) {
            throw new RecursoNaoEncontradoException("Usuário", (long) usuarioId);
        }
        String hash = encoder.encode(senha);
        int atualizadas = jdbc.update("UPDATE USUARIO_CREDENCIAL SET hash_senha=? WHERE id_usuario=?", hash, usuarioId);
        if (atualizadas == 0) {
            jdbc.update("INSERT INTO USUARIO_CREDENCIAL (id_usuario, hash_senha) VALUES (?,?)", usuarioId, hash);
        }
    }

    public boolean verificarSenha(int usuarioId, String senha) {
        if (senha == null || senha.isBlank()) return false;
        List<String> hashes = jdbc.queryForList(
                "SELECT hash_senha FROM USUARIO_CREDENCIAL WHERE id_usuario=?", String.class, usuarioId);
        return !hashes.isEmpty() && encoder.matches(senha, hashes.getFirst());
    }

    private static void validarSenha(String senha) {
        if (senha == null || senha.length() < 12) {
            throw new RequisicaoInvalidaException("A senha deve ter ao menos 12 caracteres.");
        }
    }
}
