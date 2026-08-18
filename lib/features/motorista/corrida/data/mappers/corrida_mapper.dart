import '../dtos/response/corrida_detalhe_response_dto.dart';
import '../models/corrida_detalhe_model.dart';

class CorridaMapper {
  static CorridaDetalheModel toCorridaDetalheModel(
    CorridaDetalheResponseDto dto,
  ) {
    return CorridaDetalheModel(
      id: dto.id,
      dataHoraPartida: DateTime.parse(dto.dataHoraPartida).toLocal(),
      origem: dto.origem,
      destino: dto.destino,
      nomePassageiro: dto.nomePassageiro,
      valorEstimado: dto.valorEstimado,
      ehProxima: dto.ehProxima,
      minutosRestantes: dto.minutosRestantes,
    );
  }
}
