package br.ucb.claquete.exception;

import java.time.Instant;
import java.util.List;

/** Formato único de erro devolvido pela API. */
public record ApiError(Instant timestamp, int status, String erro, String mensagem, String caminho, List<String> detalhes) {
}
