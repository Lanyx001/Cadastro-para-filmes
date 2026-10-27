package br.ucb.claquete.service;

import br.ucb.claquete.exception.RecursoNaoEncontradoException;
import br.ucb.claquete.exception.RequisicaoInvalidaException;
import java.math.BigDecimal;
import java.sql.Date;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/** Consultas explícitas e parametrizadas para o esquema definido em sql/01_ddl.sql. */
@Service
public class AcervoJdbcService {
    private final JdbcTemplate jdbc;
    public AcervoJdbcService(JdbcTemplate jdbc) { this.jdbc = jdbc; }

    private List<Map<String,Object>> q(String sql, Object... args) { return jdbc.queryForList(sql, args); }
    private Map<String,Object> one(String recurso, int id, String sql, Object... args) {
        List<Map<String,Object>> r = q(sql, args);
        if (r.isEmpty()) throw new RecursoNaoEncontradoException(recurso, (long) id);
        return r.getFirst();
    }
    public long count(String tabela) {
        if (!List.of("FILME", "AVALIACAO", "PLATAFORMA", "DISPONIBILIDADE").contains(tabela)) {
            throw new IllegalArgumentException("Tabela de indicador inválida.");
        }
        return jdbc.queryForObject("SELECT COUNT(*) FROM " + tabela, Long.class);
    }

    public List<Map<String,Object>> filmes(String titulo, Integer anoMin, Integer anoMax, String genero) {
        StringBuilder s = new StringBuilder("SELECT DISTINCT f.id_filme AS id, f.titulo, f.ano_lancamento AS ano, f.duracao, f.status, f.id_filme_sequencia AS filmeSequencia FROM FILME f LEFT JOIN FILME_GENERO fg ON fg.id_filme=f.id_filme LEFT JOIN GENERO g ON g.id_genero=fg.id_genero WHERE 1=1");
        java.util.ArrayList<Object> a = new java.util.ArrayList<>();
        if (titulo != null && !titulo.isBlank()) { s.append(" AND f.titulo LIKE ?"); a.add("%" + titulo.trim() + "%"); }
        if (anoMin != null) { s.append(" AND f.ano_lancamento >= ?"); a.add(anoMin); }
        if (anoMax != null) { s.append(" AND f.ano_lancamento <= ?"); a.add(anoMax); }
        if (genero != null && !genero.isBlank()) { s.append(" AND g.nome = ?"); a.add(genero.trim()); }
        s.append(" ORDER BY f.titulo"); return q(s.toString(), a.toArray());
    }
    public Map<String,Object> filme(int id) { return one("Filme", id, "SELECT id_filme AS id,titulo,ano_lancamento AS ano,duracao,status,id_filme_sequencia AS filmeSequencia FROM FILME WHERE id_filme=?", id); }
    @Transactional public Map<String,Object> criarFilme(Map<String,Object> r) {
        int id = inteiro(r, "id"); validarFilme(r);
        jdbc.update("INSERT INTO FILME (id_filme,titulo,ano_lancamento,duracao,status,id_filme_sequencia) VALUES (?,?,?,?,?,?)", id, texto(r,"titulo"), inteiro(r,"ano"), inteiro(r,"duracao"), textoOu(r,"status","ativo"), inteiroOuNulo(r,"filmeSequencia"));
        return filme(id);
    }
    /** Cadastra uma ficha técnica mínima como uma única unidade atômica. */
    @Transactional public Map<String,Object> criarFichaTecnica(Map<String,Object> r) {
        int id = inteiro(r, "id"), generoId = inteiro(r, "generoId"), atorId = inteiro(r, "atorId");
        validarFilme(r);
        jdbc.update("INSERT INTO FILME (id_filme,titulo,ano_lancamento,duracao,status,id_filme_sequencia) VALUES (?,?,?,?,?,?)", id, texto(r,"titulo"), inteiro(r,"ano"), inteiro(r,"duracao"), textoOu(r,"status","ativo"), inteiroOuNulo(r,"filmeSequencia"));
        jdbc.update("INSERT INTO FILME_GENERO (id_filme,id_genero) VALUES (?,?)", id, generoId);
        jdbc.update("INSERT INTO ELENCO (id_filme,id_pessoa_ator,personagem) VALUES (?,?,?)", id, atorId, texto(r,"personagem"));
        return q("SELECT f.id_filme AS id,f.titulo,f.ano_lancamento AS ano,f.duracao,f.status,fg.id_genero AS generoId,e.id_pessoa_ator AS atorId,e.personagem FROM FILME f JOIN FILME_GENERO fg ON fg.id_filme=f.id_filme JOIN ELENCO e ON e.id_filme=f.id_filme WHERE f.id_filme=?", id).getFirst();
    }
    @Transactional public Map<String,Object> atualizarFilme(int id, Map<String,Object> r) {
        filme(id); validarFilme(r);
        jdbc.update("UPDATE FILME SET titulo=?,ano_lancamento=?,duracao=?,status=?,id_filme_sequencia=? WHERE id_filme=?", texto(r,"titulo"), inteiro(r,"ano"), inteiro(r,"duracao"), textoOu(r,"status","ativo"), inteiroOuNulo(r,"filmeSequencia"), id); return filme(id);
    }
    public void excluirFilme(int id) { if (jdbc.update("DELETE FROM FILME WHERE id_filme=?", id) == 0) throw new RecursoNaoEncontradoException("Filme", (long) id); }

    public List<Map<String,Object>> plataformas() { return q("SELECT id_plataforma AS id,nome,tipo FROM PLATAFORMA ORDER BY nome"); }
    public Map<String,Object> plataforma(int id) { return one("Plataforma",id,"SELECT id_plataforma AS id,nome,tipo FROM PLATAFORMA WHERE id_plataforma=?",id); }
    @Transactional public Map<String,Object> criarPlataforma(Map<String,Object> r) { validarPlataforma(r); jdbc.update("INSERT INTO PLATAFORMA(nome,tipo) VALUES (?,?)",texto(r,"nome"),texto(r,"tipo")); return q("SELECT id_plataforma AS id,nome,tipo FROM PLATAFORMA WHERE id_plataforma=LAST_INSERT_ID()").getFirst(); }
    public Map<String,Object> atualizarPlataforma(int id, Map<String,Object> r) { plataforma(id); validarPlataforma(r); jdbc.update("UPDATE PLATAFORMA SET nome=?,tipo=? WHERE id_plataforma=?",texto(r,"nome"),texto(r,"tipo"),id); return plataforma(id); }
    public void excluirPlataforma(int id) { if(jdbc.update("DELETE FROM PLATAFORMA WHERE id_plataforma=?",id)==0) throw new RecursoNaoEncontradoException("Plataforma",(long)id); }

    public List<Map<String,Object>> avaliacoes() { return q("SELECT id_filme AS filmeId,id_usuario AS usuarioId,nota,comentario,data_avaliacao AS dataAvaliacao FROM AVALIACAO ORDER BY data_avaliacao DESC"); }
    public Map<String,Object> avaliacao(int f,int u) { List<Map<String,Object>> x=q("SELECT id_filme AS filmeId,id_usuario AS usuarioId,nota,comentario,data_avaliacao AS dataAvaliacao FROM AVALIACAO WHERE id_filme=? AND id_usuario=?",f,u); if(x.isEmpty()) throw new RequisicaoInvalidaException("Avaliação não encontrada."); return x.getFirst(); }
    public Map<String,Object> criarAvaliacao(Map<String,Object> r) { int f=inteiro(r,"filmeId"),u=inteiro(r,"usuarioId"); validarNota(r); jdbc.update("INSERT INTO AVALIACAO(id_filme,id_usuario,nota,comentario) VALUES (?,?,?,?)",f,u,decimal(r,"nota"),textoNulo(r,"comentario")); return avaliacao(f,u); }
    public Map<String,Object> atualizarAvaliacao(int f,int u,Map<String,Object> r) { avaliacao(f,u); validarNota(r); jdbc.update("UPDATE AVALIACAO SET nota=?,comentario=?,data_avaliacao=CURRENT_TIMESTAMP WHERE id_filme=? AND id_usuario=?",decimal(r,"nota"),textoNulo(r,"comentario"),f,u); return avaliacao(f,u); }
    public void excluirAvaliacao(int f,int u) { if(jdbc.update("DELETE FROM AVALIACAO WHERE id_filme=? AND id_usuario=?",f,u)==0) throw new RequisicaoInvalidaException("Avaliação não encontrada."); }

    public List<Map<String,Object>> disponibilidades(String plataforma,String genero,LocalDate vigenteEm) { String d=vigenteEm==null?"CURRENT_DATE": "?"; java.util.ArrayList<Object>a=new java.util.ArrayList<>(); StringBuilder s=new StringBuilder("SELECT d.id_filme AS filmeId,f.titulo,d.id_plataforma AS plataformaId,p.nome AS plataforma,d.data_inicio AS dataInicio,d.data_fim AS dataFim FROM DISPONIBILIDADE d JOIN FILME f ON f.id_filme=d.id_filme JOIN PLATAFORMA p ON p.id_plataforma=d.id_plataforma WHERE 1=1"); if(vigenteEm!=null){s.append(" AND d.data_inicio <= ? AND (d.data_fim IS NULL OR d.data_fim >= ?)");a.add(Date.valueOf(vigenteEm));a.add(Date.valueOf(vigenteEm));} if(plataforma!=null&&!plataforma.isBlank()){s.append(" AND p.nome LIKE ?");a.add("%"+plataforma.trim()+"%");} if(genero!=null&&!genero.isBlank()){s.append(" AND EXISTS (SELECT 1 FROM FILME_GENERO fg JOIN GENERO g ON g.id_genero=fg.id_genero WHERE fg.id_filme=f.id_filme AND g.nome=?)");a.add(genero.trim());} s.append(" ORDER BY d.data_inicio DESC");return q(s.toString(),a.toArray()); }
    public Map<String,Object> disponibilidade(int f,int p,LocalDate i) { List<Map<String,Object>> x=q("SELECT id_filme AS filmeId,id_plataforma AS plataformaId,data_inicio AS dataInicio,data_fim AS dataFim FROM DISPONIBILIDADE WHERE id_filme=? AND id_plataforma=? AND data_inicio=?",f,p,Date.valueOf(i));if(x.isEmpty())throw new RequisicaoInvalidaException("Disponibilidade não encontrada.");return x.getFirst(); }
    public Map<String,Object> criarDisponibilidade(Map<String,Object> r) { int f=inteiro(r,"filmeId"),p=inteiro(r,"plataformaId");LocalDate i=data(r,"dataInicio"); validarPeriodo(i,dataNula(r,"dataFim"));jdbc.update("INSERT INTO DISPONIBILIDADE(id_filme,id_plataforma,data_inicio,data_fim) VALUES (?,?,?,?)",f,p,Date.valueOf(i),dataNula(r,"dataFim"));return disponibilidade(f,p,i); }
    public Map<String,Object> atualizarDisponibilidade(int f,int p,LocalDate i,Map<String,Object> r) { disponibilidade(f,p,i); Date fim=dataNula(r,"dataFim"); validarPeriodo(i,fim);jdbc.update("UPDATE DISPONIBILIDADE SET data_fim=? WHERE id_filme=? AND id_plataforma=? AND data_inicio=?",fim,f,p,Date.valueOf(i));return disponibilidade(f,p,i); }
    public void excluirDisponibilidade(int f,int p,LocalDate i) {if(jdbc.update("DELETE FROM DISPONIBILIDADE WHERE id_filme=? AND id_plataforma=? AND data_inicio=?",f,p,Date.valueOf(i))==0)throw new RequisicaoInvalidaException("Disponibilidade não encontrada.");}

    public List<Map<String,Object>> consulta(int n) { String[] sql={"SELECT COUNT(*) AS total FROM FILME WHERE titulo LIKE 'A%' OR titulo LIKE 'O%'","SELECT id_filme AS id,titulo,ano_lancamento AS ano,id_filme_sequencia AS sequencia FROM FILME WHERE id_filme_sequencia IS NOT NULL ORDER BY ano","SELECT titulo,duracao FROM FILME WHERE duracao BETWEEN 60 AND 120 ORDER BY duracao DESC","SELECT id_filme AS id,titulo,ano_lancamento AS ano,status FROM FILME WHERE status='ativo' AND ano_lancamento BETWEEN 2000 AND 2020 ORDER BY ano","SELECT id_plataforma AS id,nome,tipo FROM PLATAFORMA WHERE tipo IN ('Streaming','Cinema') ORDER BY tipo,nome","SELECT p.nome AS plataforma,p.tipo,COUNT(d.id_filme) AS total FROM PLATAFORMA p JOIN DISPONIBILIDADE d ON d.id_plataforma=p.id_plataforma GROUP BY p.id_plataforma,p.nome,p.tipo","SELECT p.nome AS plataforma,ROUND(AVG(f.duracao),2) AS mediaDuracao,COUNT(f.id_filme) AS quantidade FROM PLATAFORMA p JOIN DISPONIBILIDADE d ON d.id_plataforma=p.id_plataforma JOIN FILME f ON f.id_filme=d.id_filme GROUP BY p.id_plataforma,p.nome HAVING AVG(f.duracao)>130","SELECT f.id_filme AS filmeId,f.titulo,a.id_usuario AS usuarioId,a.nota,a.comentario FROM FILME f LEFT JOIN AVALIACAO a ON a.id_filme=f.id_filme ORDER BY f.titulo,a.nota DESC","SELECT f.titulo,f.ano_lancamento AS ano,GROUP_CONCAT(g.nome ORDER BY g.nome SEPARATOR ', ') AS generos FROM FILME f JOIN FILME_GENERO fg ON fg.id_filme=f.id_filme JOIN GENERO g ON g.id_genero=fg.id_genero WHERE f.status='ativo' GROUP BY f.id_filme,f.titulo,f.ano_lancamento","SELECT DISTINCT p.nome AS plataforma,p.tipo AS tipoPlataforma,f.titulo AS filme FROM PLATAFORMA p JOIN DISPONIBILIDADE d ON d.id_plataforma=p.id_plataforma JOIN FILME_GENERO fg ON fg.id_filme=d.id_filme JOIN GENERO g ON g.id_genero=fg.id_genero JOIN FILME f ON f.id_filme=d.id_filme WHERE g.nome='Ficção Científica'","SELECT COUNT(*) AS total FROM FILME f WHERE EXISTS(SELECT 1 FROM DISPONIBILIDADE d WHERE d.id_filme=f.id_filme AND d.data_inicio<='2021-12-31' AND(d.data_fim IS NULL OR d.data_fim>='2020-01-01'))","SELECT u.id_usuario AS id,u.nome,u.email FROM USUARIO u WHERE EXISTS(SELECT 1 FROM AVALIACAO a JOIN FILME f ON f.id_filme=a.id_filme WHERE a.id_usuario=u.id_usuario AND a.comentario IS NOT NULL AND f.duracao>150)","SELECT f.id_filme AS id,f.titulo,ROUND(AVG(a.nota),2) AS media FROM FILME f JOIN AVALIACAO a ON a.id_filme=f.id_filme GROUP BY f.id_filme,f.titulo HAVING AVG(a.nota)>(SELECT AVG(nota) FROM AVALIACAO)","SELECT p.id_pessoa AS id,p.nome,a.registro_profissional AS registro FROM PESSOA p JOIN ATOR a ON a.id_pessoa=p.id_pessoa WHERE NOT EXISTS(SELECT 1 FROM ELENCO e JOIN FILME_GENERO fg ON fg.id_filme=e.id_filme JOIN GENERO g ON g.id_genero=fg.id_genero WHERE e.id_pessoa_ator=a.id_pessoa AND g.nome='Terror')","SELECT p.nome AS plataforma,p.tipo,COUNT(DISTINCT f.id_filme) AS titulos,ROUND(SUM(f.duracao)/60.0,1) AS totalHoras FROM PLATAFORMA p JOIN DISPONIBILIDADE d ON d.id_plataforma=p.id_plataforma JOIN FILME f ON f.id_filme=d.id_filme WHERE f.id_filme IN(SELECT id_filme FROM AVALIACAO GROUP BY id_filme HAVING AVG(nota)>=8) GROUP BY p.id_plataforma,p.nome,p.tipo ORDER BY totalHoras DESC"}; if(n<1||n>15)throw new RequisicaoInvalidaException("Informe um número de consulta entre 1 e 15.");return q(sql[n-1]); }
    public List<Map<String,Object>> relatorio() { return q("SELECT id_filme AS filmeId,titulo,ano_lancamento AS ano,duracao,total_avaliacoes AS totalAvaliacoes,media_notas AS notaMedia,generos,plataformas FROM vw_relatorio_consolidado ORDER BY titulo"); }
    private static String texto(Map<String,Object> r,String k){Object v=r.get(k);if(v==null||v.toString().isBlank())throw new RequisicaoInvalidaException("O campo '"+k+"' é obrigatório.");return v.toString().trim();} private static String textoOu(Map<String,Object>r,String k,String d){Object v=r.get(k);return v==null||v.toString().isBlank()?d:v.toString().trim();} private static String textoNulo(Map<String,Object>r,String k){Object v=r.get(k);return v==null||v.toString().isBlank()?null:v.toString().trim();} private static int inteiro(Map<String,Object>r,String k){try{return Integer.parseInt(texto(r,k));}catch(NumberFormatException e){throw new RequisicaoInvalidaException("O campo '"+k+"' deve ser numérico.");}} private static Integer inteiroOuNulo(Map<String,Object>r,String k){Object v=r.get(k);return v==null||v.toString().isBlank()?null:inteiro(r,k);} private static BigDecimal decimal(Map<String,Object>r,String k){try{return new BigDecimal(texto(r,k));}catch(NumberFormatException e){throw new RequisicaoInvalidaException("O campo '"+k+"' deve ser numérico.");}} private static LocalDate data(Map<String,Object>r,String k){try{return LocalDate.parse(texto(r,k));}catch(Exception e){throw new RequisicaoInvalidaException("O campo '"+k+"' deve estar no formato AAAA-MM-DD.");}} private static Date dataNula(Map<String,Object>r,String k){Object v=r.get(k);return v==null||v.toString().isBlank()?null:Date.valueOf(data(r,k));} private static void validarFilme(Map<String,Object>r){int ano=inteiro(r,"ano"),dur=inteiro(r,"duracao");if(ano<1888||dur<1)throw new RequisicaoInvalidaException("Ano ou duração inválidos.");String st=textoOu(r,"status","ativo");if(!st.equals("ativo")&&!st.equals("desativado"))throw new RequisicaoInvalidaException("Status deve ser ativo ou desativado.");} private static void validarPlataforma(Map<String,Object>r){texto(r,"nome");String t=texto(r,"tipo");if(!List.of("Streaming","Cinema","Canal TV","Mídia Física").contains(t))throw new RequisicaoInvalidaException("Tipo de plataforma inválido.");} private static void validarNota(Map<String,Object>r){BigDecimal n=decimal(r,"nota");if(n.compareTo(BigDecimal.ZERO)<0||n.compareTo(BigDecimal.TEN)>0)throw new RequisicaoInvalidaException("A nota deve estar entre 0 e 10.");} private static void validarPeriodo(LocalDate inicio,Date fim){if(fim!=null&&fim.toLocalDate().isBefore(inicio))throw new RequisicaoInvalidaException("A data final não pode ser anterior à data de início.");}
}
