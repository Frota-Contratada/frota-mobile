import '../entities/corrida_detalhe.dart';

abstract class CorridaRepository {
  Future<CorridaDetalhe> buscarDetalhes(String corridaId);

  Future<CorridaDetalhe> iniciarCorrida(String corridaId);

  Future<CorridaDetalhe> recusarCorrida(String corridaId, String motivo);
}
