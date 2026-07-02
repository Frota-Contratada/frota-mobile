import '../../../../../core/error/exceptions.dart';
import '../../../../../core/error/failures.dart';
import '../../domain/entities/corrida.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_datasource.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDatasource remoteDatasource;

  HomeRepositoryImpl({required this.remoteDatasource});

  @override
  Future<List<Corrida>> buscarViagensPorSemana({
    required DateTime inicioSemana,
    required DateTime fimSemana,
  }) {
    return _handleRemoteCall(
      () => remoteDatasource.buscarViagensPorSemana(
        inicioSemana: inicioSemana,
        fimSemana: fimSemana,
      ),
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
