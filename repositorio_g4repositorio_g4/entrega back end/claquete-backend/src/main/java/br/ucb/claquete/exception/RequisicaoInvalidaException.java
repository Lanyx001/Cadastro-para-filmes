package br.ucb.claquete.exception;

/** Vira HTTP 400 (ex.: referência a um filme que não existe). */
public class RequisicaoInvalidaException extends RuntimeException {
    public RequisicaoInvalidaException(String mensagem) {
        super(mensagem);
    }
}
