import '../entities/corrida.dart';
import '../repositories/viagens_repository.dart';

class BuscarViagensPorSemanaUsecase {
  final ViagensRepository repository;

  BuscarViagensPorSemanaUsecase(this.repository);

  Future<List<Corrida>> call({
    required DateTime inicioSemana,
    required DateTime fimSemana,
  }) {
    return repository.buscarViagensPorSemana(
      inicioSemana: inicioSemana,
      fimSemana: fimSemana,
    );
  }
}
