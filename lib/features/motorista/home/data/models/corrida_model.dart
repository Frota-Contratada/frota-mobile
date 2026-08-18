import '../../domain/entities/corrida.dart';
import '../dtos/response/corrida_response_dto.dart';
import '../mappers/home_mapper.dart';

class CorridaModel extends Corrida {
  const CorridaModel({
    required super.id,
    required super.dataHoraPartida,
    required super.origem,
    required super.destino,
    super.ehProxima,
    super.minutosRestantes,
  });

  factory CorridaModel.fromJson(Map<String, dynamic> json) {
    return HomeMapper.toCorridaModel(CorridaResponseDto.fromJson(json));
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dataHoraPartida': dataHoraPartida.toIso8601String(),
      'origem': origem,
      'destino': destino,
      'ehProxima': ehProxima,
      'minutosRestantes': minutosRestantes,
    };
  }
}
