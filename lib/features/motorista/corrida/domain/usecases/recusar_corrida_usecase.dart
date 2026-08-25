import '../entities/corrida_detalhe.dart';
import '../repositories/corrida_repository.dart';

class RecusarCorridaUsecase {
  final CorridaRepository repository;

  RecusarCorridaUsecase(this.repository);

  Future<CorridaDetalhe> call(String corridaId, String motivo) {
    return repository.recusarCorrida(corridaId, motivo);
  }
}
