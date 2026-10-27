package br.ucb.claquete.exception;

import jakarta.servlet.http.HttpServletRequest;
import java.time.Instant;
import java.util.List;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.web.HttpRequestMethodNotSupportedException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.method.annotation.MethodArgumentTypeMismatchException;
import org.springframework.web.servlet.resource.NoResourceFoundException;
import org.springframework.dao.DataIntegrityViolationException;

/** Tratamento centralizado: toda exceção vira JSON no formato ApiError, sem stack trace. */
@RestControllerAdvice
public class TratadorDeErros {

    private static final Logger log = LoggerFactory.getLogger(TratadorDeErros.class);

    @ExceptionHandler(RecursoNaoEncontradoException.class)
    public ResponseEntity<ApiError> naoEncontrado(RecursoNaoEncontradoException e, HttpServletRequest req) {
        return erro(HttpStatus.NOT_FOUND, e.getMessage(), req, List.of());
    }

    @ExceptionHandler(NoResourceFoundException.class)
    public ResponseEntity<ApiError> rotaInexistente(NoResourceFoundException e, HttpServletRequest req) {
        return erro(HttpStatus.NOT_FOUND, "Recurso não encontrado.", req, List.of());
    }

    @ExceptionHandler(RequisicaoInvalidaException.class)
    public ResponseEntity<ApiError> invalida(RequisicaoInvalidaException e, HttpServletRequest req) {
        return erro(HttpStatus.BAD_REQUEST, e.getMessage(), req, List.of());
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ApiError> validacao(MethodArgumentNotValidException e, HttpServletRequest req) {
        List<String> detalhes = e.getBindingResult().getFieldErrors().stream()
                .map(f -> f.getField() + ": " + f.getDefaultMessage())
                .sorted()
                .toList();
        return erro(HttpStatus.BAD_REQUEST, "Dados inválidos.", req, detalhes);
    }

    @ExceptionHandler(HttpMessageNotReadableException.class)
    public ResponseEntity<ApiError> jsonInvalido(HttpMessageNotReadableException e, HttpServletRequest req) {
        return erro(HttpStatus.BAD_REQUEST, "Corpo da requisição ausente ou com JSON inválido.", req, List.of());
    }

    @ExceptionHandler(MethodArgumentTypeMismatchException.class)
    public ResponseEntity<ApiError> tipoInvalido(MethodArgumentTypeMismatchException e, HttpServletRequest req) {
        return erro(HttpStatus.BAD_REQUEST, "Valor inválido para o parâmetro '" + e.getName() + "'.", req, List.of());
    }

    @ExceptionHandler(HttpRequestMethodNotSupportedException.class)
    public ResponseEntity<ApiError> metodoNaoSuportado(HttpRequestMethodNotSupportedException e, HttpServletRequest req) {
        return erro(HttpStatus.METHOD_NOT_ALLOWED, "Método HTTP não suportado para este endereço.", req, List.of());
    }

    @ExceptionHandler(ConflitoException.class)
    public ResponseEntity<ApiError> conflito(ConflitoException e, HttpServletRequest req) {
        return erro(HttpStatus.CONFLICT, e.getMessage(), req, List.of());
    }

    @ExceptionHandler(DataIntegrityViolationException.class)
    public ResponseEntity<ApiError> integridade(DataIntegrityViolationException e, HttpServletRequest req) {
        return erro(HttpStatus.CONFLICT, "A operação viola uma regra de integridade do banco de dados.", req, List.of());
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ApiError> inesperado(Exception e, HttpServletRequest req) {
        log.error("Erro inesperado em {}", req.getRequestURI(), e); // detalhes só no log do servidor
        return erro(HttpStatus.INTERNAL_SERVER_ERROR, "Erro interno do servidor.", req, List.of());
    }

    private ResponseEntity<ApiError> erro(HttpStatus status, String mensagem, HttpServletRequest req, List<String> detalhes) {
        ApiError corpo = new ApiError(Instant.now(), status.value(), status.getReasonPhrase(), mensagem,
                req.getRequestURI(), detalhes);
        return ResponseEntity.status(status).body(corpo);
    }
}
