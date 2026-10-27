package br.ucb.claquete.exception;

/** Vira HTTP 409 (ex.: excluir um filme que ainda tem avaliações). */
public class ConflitoException extends RuntimeException {
    public ConflitoException(String mensagem) {
        super(mensagem);
    }
}
