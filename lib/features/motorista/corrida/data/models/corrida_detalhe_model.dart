import '../../domain/entities/corrida_detalhe.dart';
import '../dtos/response/corrida_detalhe_response_dto.dart';
import '../mappers/corrida_mapper.dart';

class CorridaDetalheModel extends CorridaDetalhe {
  const CorridaDetalheModel({
    required super.id,
    required super.dataHoraPartida,
    required super.origem,
    required super.destino,
    required super.nomePassageiro,
    required super.valorEstimado,
    super.ehProxima,
    super.minutosRestantes,
  });

  factory CorridaDetalheModel.fromJson(Map<String, dynamic> json) {
    return CorridaMapper.toCorridaDetalheModel(
      CorridaDetalheResponseDto.fromJson(json),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'data_hora_partida': dataHoraPartida.toIso8601String(),
      'origem': origem,
      'destino': destino,
      'nome_passageiro': nomePassageiro,
      'valor_estimado': valorEstimado,
      'eh_proxima': ehProxima,
      'minutos_restantes': minutosRestantes,
    };
  }
}
