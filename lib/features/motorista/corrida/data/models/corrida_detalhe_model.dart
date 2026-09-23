import '../../domain/entities/corrida_detalhe.dart';
import '../dtos/response/corrida_detalhe_response_dto.dart';
import '../mappers/corrida_mapper.dart';

class CorridaDetalheModel extends CorridaDetalhe {
  const CorridaDetalheModel({
    required super.id,
    required super.dataHoraPartida,
    required super.origem,
    required super.destino,
    super.paradas,
    required super.nomePassageiro,
    required super.valorEstimado,
    super.ehProxima,
    super.minutosRestantes,
    super.motivoRecusa,
    super.trackingSnapshot,
  });

  factory CorridaDetalheModel.fromJson(Map<String, dynamic> json) {
    return CorridaMapper.toCorridaDetalheModel(
      CorridaDetalheResponseDto.fromJson(json),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dataHoraPartida': dataHoraPartida.toIso8601String(),
      'origem': origem,
      'destino': destino,
      'paradas': paradas
          .map(
            (parada) => {
              'ordem': parada.ordem,
              'endereco': parada.endereco,
              'latitude': parada.latitude,
              'longitude': parada.longitude,
            },
          )
          .toList(),
      'nomePassageiro': nomePassageiro,
      'valorEstimado': valorEstimado,
      'ehProxima': ehProxima,
      'minutosRestantes': minutosRestantes,
      'motivoRecusa': motivoRecusa,
      if (trackingSnapshot != null)
        'tracking': trackingSnapshot!.toBootstrapPayload(),
    };
  }
}
