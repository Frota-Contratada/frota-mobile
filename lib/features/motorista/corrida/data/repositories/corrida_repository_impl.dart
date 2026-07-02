import '../../../../../core/error/exceptions.dart';
import '../../../../../core/error/failures.dart';
import '../../domain/entities/corrida_detalhe.dart';
import '../../domain/repositories/corrida_repository.dart';
import '../datasources/corrida_remote_datasource.dart';

class CorridaRepositoryImpl implements CorridaRepository {
  final CorridaRemoteDatasource remoteDatasource;

  CorridaRepositoryImpl({required this.remoteDatasource});

  @override
  Future<CorridaDetalhe> buscarDetalhes(String corridaId) {
    return _handleRemoteCall(
      () => remoteDatasource.buscarDetalhes(corridaId),
    );
  }

  @override
  Future<void> iniciarCorrida(String corridaId) {
    return _handleRemoteCall(
      () => remoteDatasource.iniciarCorrida(corridaId),
    );
  }

  Future<T> _handleRemoteCall<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }
}
