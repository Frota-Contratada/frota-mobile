import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure_mapper.dart';
import '../../domain/entities/notificacao.dart';
import '../../domain/repositories/notificacoes_repository.dart';
import '../datasources/notificacoes_remote_datasource.dart';
import '../datasources/notificacoes_socket_datasource.dart';

class NotificacoesRepositoryImpl implements NotificacoesRepository {
  final NotificacoesRemoteDatasource remoteDatasource;
  final NotificacoesSocketDatasource socketDatasource;

  NotificacoesRepositoryImpl({
    required this.remoteDatasource,
    required this.socketDatasource,
  });

  @override
  Stream<Notificacao> get notificacoesCriadas =>
      socketDatasource.notificacoesCriadas;

  @override
  Stream<String> get notificacoesRemovidas =>
      socketDatasource.notificacoesRemovidas;

  @override
  Future<List<Notificacao>> buscarTodas() =>
      _handleRemoteCall(remoteDatasource.buscarTodas);

  @override
  Future<int> contarNaoLidas() =>
      _handleRemoteCall(remoteDatasource.contarNaoLidas);

  @override
  Future<Notificacao> marcarComoLida(String id) =>
      _handleRemoteCall(() => remoteDatasource.marcarComoLida(id));

  @override
  Future<void> conectar() => socketDatasource.conectar();

  @override
  Future<void> desconectar() => socketDatasource.desconectar();

  Future<T> _handleRemoteCall<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on ServerException catch (e) {
      throw mapServerException(e);
    }
  }
}
