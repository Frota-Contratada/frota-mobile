import '../entities/corrida_detalhe.dart';

abstract class CorridaRepository {
  Future<CorridaDetalhe> buscarDetalhes(String corridaId);

  Future<void> iniciarCorrida(String corridaId);
}
