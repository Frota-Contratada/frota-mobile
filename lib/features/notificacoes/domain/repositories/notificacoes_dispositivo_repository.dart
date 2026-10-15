import '../entities/notificacao.dart';
import '../entities/toque_notificacao.dart';

abstract class NotificacoesDispositivoRepository {
  Stream<ToqueNotificacao> get toques;
  Future<bool> inicializar();
  Future<bool> solicitarPermissao();
  Future<void> exibir(Notificacao notificacao);
  Future<ToqueNotificacao?> toqueInicial();
}
