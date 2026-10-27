package br.ucb.claquete;

import static org.mockito.Mockito.verify;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.httpBasic;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.user;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import br.ucb.claquete.config.SegurancaConfig;
import br.ucb.claquete.controller.CredencialController;
import br.ucb.claquete.service.CredencialService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.WebMvcTest;
import org.springframework.context.annotation.Import;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.springframework.test.web.servlet.MockMvc;

@WebMvcTest(CredencialController.class)
@Import(SegurancaConfig.class)
class CredencialControllerSegurancaTest {
    private static final String SENHA_ADMINISTRATIVA_DE_TESTE = "senha-administrativa-de-teste";

    @DynamicPropertySource
    static void configurarAdministrador(DynamicPropertyRegistry propriedades) {
        propriedades.add("claquete.seguranca.administrador.usuario", () -> "administrador-teste");
        propriedades.add("claquete.seguranca.administrador.hash-senha",
                () -> new BCryptPasswordEncoder(12).encode(SENHA_ADMINISTRATIVA_DE_TESTE));
    }

    @Autowired
    private MockMvc mvc;

    @MockitoBean
    private CredencialService service;

    @Test
    void definirSenhaSemAutenticacaoERecusado() throws Exception {
        mvc.perform(post("/api/credenciais/1")
                        .contentType("application/json")
                        .content("{\"senha\":\"senha-de-teste-segura\"}"))
                .andExpect(status().isUnauthorized());
    }

    @Test
    void administradorPodeDefinirSenhaSemReceberHash() throws Exception {
        mvc.perform(post("/api/credenciais/1")
                        .with(user("administrador").roles("ADMIN_CREDENCIAIS"))
                        .contentType("application/json")
                        .content("{\"senha\":\"senha-de-teste-segura\"}"))
                .andExpect(status().isNoContent());

        verify(service).definirSenha(1, "senha-de-teste-segura");
    }

    @Test
    void credenciaisAdministrativasComHashBcryptPermitemAutenticacaoHttpBasic() throws Exception {
        mvc.perform(post("/api/credenciais/1")
                        .with(httpBasic("administrador-teste", SENHA_ADMINISTRATIVA_DE_TESTE))
                        .contentType("application/json")
                        .content("{\"senha\":\"senha-de-teste-segura\"}"))
                .andExpect(status().isNoContent());
    }

    @Test
    void usuarioSemRoleAdministrativaNaoPodeVerificarSenha() throws Exception {
        mvc.perform(post("/api/credenciais/1/verificar")
                        .with(user("leitor").roles("LEITOR"))
                        .contentType("application/json")
                        .content("{\"senha\":\"senha-de-teste-segura\"}"))
                .andExpect(status().isForbidden());
    }
}
