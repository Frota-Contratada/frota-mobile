import '../../domain/entities/status_viagem.dart';
import '../dtos/response/viagem_response_dto.dart';
import '../models/viagem_model.dart';
import '../../../../shared/trip_tracking/domain/entities/trip_tracking_snapshot.dart';

class HomeMapper {
  static ViagemModel toViagemModel(ViagemResponseDto dto) {
    return ViagemModel(
      id: dto.corridaId ?? dto.solicitacaoId.toString(),
      dataHoraPartida: DateTime.parse(dto.dataHoraPartida).toLocal(),
      origem: dto.origem,
      destino: dto.destino,
      status: _mapStatus(dto.status),
      dataChegadaEstimada: dto.dataChegadaEstimada == null
          ? null
          : DateTime.parse(dto.dataChegadaEstimada!).toLocal(),
      tipoCorrida: dto.tipoCorrida,
      valorEstimado: dto.valorEstimado,
      motoristaNome: dto.motoristaNome,
      placaVeiculo: dto.placaVeiculo,
      trackingSnapshot: dto.tracking == null
          ? null
          : TripTrackingSnapshot.fromJson(
              dto.tracking!,
              tripId: dto.corridaId ?? dto.solicitacaoId.toString(),
              role: TripRole.passenger,
            ),
    );
  }

  static StatusViagem _mapStatus(String status) {
    return switch (status) {
      'em-andamento' ||
      'em_andamento' ||
      'emAndamento' => StatusViagem.emAndamento,
      _ => StatusViagem.agendada,
    };
  }
}
