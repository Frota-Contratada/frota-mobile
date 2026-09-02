import '../dtos/response/corrida_detalhe_response_dto.dart';
import '../models/corrida_detalhe_model.dart';
import '../../domain/entities/corrida_detalhe.dart';
import '../../../../shared/trip_tracking/domain/entities/trip_tracking_snapshot.dart';

class CorridaMapper {
  static CorridaDetalheModel toCorridaDetalheModel(
    CorridaDetalheResponseDto dto,
  ) {
    return CorridaDetalheModel(
      id: dto.id,
      dataHoraPartida: DateTime.parse(dto.dataHoraPartida).toLocal(),
      origem: dto.origem,
      destino: dto.destino,
      paradas: dto.paradas
          .map(
            (parada) => CorridaParada(
              ordem: parada.ordem,
              endereco: parada.endereco,
              latitude: parada.latitude,
              longitude: parada.longitude,
            ),
          )
          .toList(),
      nomePassageiro: dto.nomePassageiro,
      valorEstimado: dto.valorEstimado,
      ehProxima: dto.ehProxima,
      minutosRestantes: dto.minutosRestantes,
      motivoRecusa: dto.motivoRecusa,
      trackingSnapshot: dto.tracking == null
          ? null
          : TripTrackingSnapshot.fromJson(
              dto.tracking!,
              tripId: dto.id,
              role: TripRole.driver,
            ),
    );
  }
}
