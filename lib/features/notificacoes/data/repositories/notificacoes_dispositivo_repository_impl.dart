import '../../domain/entities/notificacao.dart';
import '../../domain/entities/toque_notificacao.dart';
import '../../domain/repositories/notificacoes_dispositivo_repository.dart';
import '../datasources/notificacoes_locais_datasource.dart';

class NotificacoesDispositivoRepositoryImpl
    implements NotificacoesDispositivoRepository {
  final NotificacoesLocaisDatasource datasource;

  NotificacoesDispositivoRepositoryImpl({required this.datasource});

  @override
  Stream<ToqueNotificacao> get toques => datasource.toques;

  @override
  Future<bool> inicializar() => datasource.inicializar();

  @override
  Future<bool> solicitarPermissao() => datasource.solicitarPermissao();

  @override
  Future<void> exibir(Notificacao notificacao) =>
      datasource.exibir(notificacao);

  @override
  Future<ToqueNotificacao?> toqueInicial() => datasource.toqueInicial();
}
