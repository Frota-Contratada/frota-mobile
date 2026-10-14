import 'dart:async';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure_mapper.dart';
import '../../domain/entities/preferencias_notificacao.dart';
import '../../domain/repositories/preferencias_notificacao_repository.dart';
import '../datasources/preferencias_notificacao_remote_datasource.dart';

class PreferenciasNotificacaoRepositoryImpl
    implements PreferenciasNotificacaoRepository {
  final PreferenciasNotificacaoRemoteDatasource remoteDatasource;
  final _alteracoes = StreamController<PreferenciasNotificacao>.broadcast();

  PreferenciasNotificacaoRepositoryImpl({required this.remoteDatasource});

  @override
  Stream<PreferenciasNotificacao> get alteracoes => _alteracoes.stream;

  @override
  Future<PreferenciasNotificacao> buscar() =>
      _publicar(remoteDatasource.buscar);

  @override
  Future<PreferenciasNotificacao> atualizar({
    bool? pushAtivo,
    Map<CategoriaNotificacao, bool>? categorias,
  }) => _publicar(
    () => remoteDatasource.atualizar(
      pushAtivo: pushAtivo,
      categorias: categorias,
    ),
  );

  Future<PreferenciasNotificacao> _publicar(
    Future<PreferenciasNotificacao> Function() chamada,
  ) async {
    try {
      final preferencias = await chamada();
      _alteracoes.add(preferencias);
      return preferencias;
    } on ServerException catch (e) {
      throw mapServerException(e);
    }
  }
}
