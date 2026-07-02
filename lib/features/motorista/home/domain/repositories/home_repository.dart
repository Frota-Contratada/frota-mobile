import '../entities/corrida.dart';

abstract class HomeRepository {
  Future<List<Corrida>> buscarViagensPorSemana({
    required DateTime inicioSemana,
    required DateTime fimSemana,
  });
}
