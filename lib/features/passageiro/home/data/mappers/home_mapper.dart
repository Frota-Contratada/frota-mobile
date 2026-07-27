import '../../domain/entities/status_viagem.dart';
import '../dtos/response/viagem_response_dto.dart';
import '../models/viagem_model.dart';

class HomeMapper {
  static ViagemModel toViagemModel(ViagemResponseDto dto) {
    return ViagemModel(
      id: dto.id,
      dataHoraPartida: DateTime.parse(dto.dataHoraPartida),
      origem: dto.origem,
      destino: dto.destino,
      status: _mapStatus(dto.status),
    );
  }

  static StatusViagem _mapStatus(String status) {
    return switch (status) {
      'em_andamento' || 'emAndamento' => StatusViagem.emAndamento,
      _ => StatusViagem.agendada,
    };
  }
}
