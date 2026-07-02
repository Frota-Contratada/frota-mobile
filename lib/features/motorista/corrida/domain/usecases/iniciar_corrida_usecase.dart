import '../repositories/corrida_repository.dart';

class IniciarCorridaUsecase {
  final CorridaRepository repository;

  IniciarCorridaUsecase(this.repository);

  Future<void> call(String corridaId) {
    return repository.iniciarCorrida(corridaId);
  }
}
