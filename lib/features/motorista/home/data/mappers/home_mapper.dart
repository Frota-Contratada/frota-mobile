import '../dtos/response/corrida_response_dto.dart';
import '../models/corrida_model.dart';

class HomeMapper {
  static CorridaModel toCorridaModel(CorridaResponseDto dto) {
    return CorridaModel(
      id: dto.id,
      dataHoraPartida: DateTime.parse(dto.dataHoraPartida),
      origem: dto.origem,
      destino: dto.destino,
      ehProxima: dto.ehProxima,
      minutosRestantes: dto.minutosRestantes,
    );
  }
}
