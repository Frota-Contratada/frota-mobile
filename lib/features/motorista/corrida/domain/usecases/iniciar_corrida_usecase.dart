import '../entities/corrida_detalhe.dart';
import '../repositories/corrida_repository.dart';

class IniciarCorridaUsecase {
  final CorridaRepository repository;

  IniciarCorridaUsecase(this.repository);

  Future<CorridaDetalhe> call(String corridaId) {
    return repository.iniciarCorrida(corridaId);
  }
}
