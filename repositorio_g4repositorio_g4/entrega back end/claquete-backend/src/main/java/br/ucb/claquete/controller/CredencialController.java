package br.ucb.claquete.controller;

import br.ucb.claquete.exception.RequisicaoInvalidaException;
import br.ucb.claquete.service.CredencialService;
import java.util.Map;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/** Endpoints administrativos protegidos por HTTP Basic e role ADMIN_CREDENCIAIS. */
@RestController
@RequestMapping("/api/credenciais")
public class CredencialController {
    private final CredencialService service;

    public CredencialController(CredencialService service) { this.service = service; }

    @PostMapping("/{usuarioId}")
    public ResponseEntity<Void> definir(@PathVariable int usuarioId, @RequestBody Map<String, Object> corpo) {
        service.definirSenha(usuarioId, senha(corpo));
        return ResponseEntity.status(HttpStatus.NO_CONTENT).build();
    }

    @PostMapping("/{usuarioId}/verificar")
    public Map<String, Boolean> verificar(@PathVariable int usuarioId, @RequestBody Map<String, Object> corpo) {
        return Map.of("valida", service.verificarSenha(usuarioId, senha(corpo)));
    }

    private static String senha(Map<String, Object> corpo) {
        Object senha = corpo.get("senha");
        if (senha == null) throw new RequisicaoInvalidaException("O campo 'senha' é obrigatório.");
        return senha.toString();
    }
}
