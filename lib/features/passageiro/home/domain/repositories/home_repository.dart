import '../entities/viagem.dart';

abstract class PassageiroHomeRepository {
  Future<List<Viagem>> buscarViagensPorSemana({
    required DateTime inicioSemana,
    required DateTime fimSemana,
  });
}
