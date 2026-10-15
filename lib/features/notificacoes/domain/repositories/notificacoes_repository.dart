import '../entities/notificacao.dart';

abstract class NotificacoesRepository {
  Stream<Notificacao> get notificacoesCriadas;
  Stream<String> get notificacoesRemovidas;
  Future<List<Notificacao>> buscarTodas();
  Future<int> contarNaoLidas();
  Future<Notificacao> marcarComoLida(String id);
  Future<void> conectar();
  Future<void> desconectar();
}
