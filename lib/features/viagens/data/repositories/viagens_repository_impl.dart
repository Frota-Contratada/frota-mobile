import '../../domain/entities/corrida.dart';
import '../../domain/repositories/viagens_repository.dart';
import '../datasources/viagens_remote_datasource.dart';

class ViagensRepositoryImpl implements ViagensRepository {
  final ViagensRemoteDatasource remoteDatasource;

  ViagensRepositoryImpl({required this.remoteDatasource});

  @override
  Future<List<Corrida>> buscarViagensPorSemana({
    required DateTime inicioSemana,
    required DateTime fimSemana,
  }) {
    return remoteDatasource.buscarViagensPorSemana(
      inicioSemana: inicioSemana,
      fimSemana: fimSemana,
    );
  }
}
