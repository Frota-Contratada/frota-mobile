import '../../domain/entities/viagem.dart';
import '../dtos/response/viagem_response_dto.dart';
import '../mappers/home_mapper.dart';

class ViagemModel extends Viagem {
  const ViagemModel({
    required super.id,
    required super.dataHoraPartida,
    required super.origem,
    required super.destino,
    super.status,
  });

  factory ViagemModel.fromJson(Map<String, dynamic> json) {
    return HomeMapper.toViagemModel(ViagemResponseDto.fromJson(json));
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'data_hora_partida': dataHoraPartida.toIso8601String(),
      'origem': origem,
      'destino': destino,
      'status': status.name,
    };
  }
}
