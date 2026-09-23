import '../entities/corrida_detalhe.dart';
import '../repositories/corrida_repository.dart';

class BuscarCorridaDetalheUsecase {
  final CorridaRepository repository;

  BuscarCorridaDetalheUsecase(this.repository);

  Future<CorridaDetalhe> call(String corridaId) {
    return repository.buscarDetalhes(corridaId);
  }
}
