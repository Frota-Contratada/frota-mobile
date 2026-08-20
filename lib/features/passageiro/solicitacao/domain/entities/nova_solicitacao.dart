import '../../../../../core/maps/endereco_estruturado.dart';

class NovaSolicitacao {
  final DateTime dataCorrida;
  final int tipoCorridaId;
  final int? tipoVeiculoId;
  final int motivoSolicitacaoId;
  final EnderecoEstruturado origem;
  final EnderecoEstruturado destino;
  final List<EnderecoEstruturado> paradas;
  final List<int> centrosCustoIds;
  final List<String> cpfsAcompanhantes;

  const NovaSolicitacao({
    required this.dataCorrida,
    required this.tipoCorridaId,
    required this.motivoSolicitacaoId,
    required this.origem,
    required this.destino,
    required this.centrosCustoIds,
    this.tipoVeiculoId,
    this.paradas = const [],
    this.cpfsAcompanhantes = const [],
  });

  Map<String, dynamic> toJson() => {
    ...toSimulacaoJson(),
    'motivoSolicitacaoId': motivoSolicitacaoId,
    'centrosCustoIds': centrosCustoIds,
    'cpfsAcompanhantes': cpfsAcompanhantes,
  };

  Map<String, dynamic> toSimulacaoJson() => {
    'dataCorrida': dataCorrida.toUtc().toIso8601String(),
    'tipoCorridaId': tipoCorridaId,
    if (tipoVeiculoId != null) 'tipoVeiculoId': tipoVeiculoId,
    'origem': origem.toJson(),
    'destino': destino.toJson(),
    'paradas': paradas.map((parada) => parada.toJson()).toList(),
    'cpfsAcompanhantes': cpfsAcompanhantes,
  };
}
