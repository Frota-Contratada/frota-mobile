import '../entities/corrida.dart';

abstract class ViagensRepository {
  Future<List<Corrida>> buscarViagensPorSemana({
    required DateTime inicioSemana,
    required DateTime fimSemana,
  });
}
