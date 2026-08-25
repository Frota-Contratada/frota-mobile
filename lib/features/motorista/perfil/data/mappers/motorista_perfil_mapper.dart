import '../../domain/entities/motorista_perfil.dart';
import '../dtos/response/motorista_perfil_response_dto.dart';

class MotoristaPerfilMapper {
  static MotoristaPerfil toEntity(MotoristaPerfilResponseDto dto) {
    return MotoristaPerfil(
      id: dto.id,
      nome: dto.nome,
      email: dto.email,
      cpf: dto.cpf,
      fornecedorNome: dto.fornecedorNome,
      fotoPerfil: dto.fotoPerfil,
      viagensFinalizadas: dto.viagensFinalizadas,
      transportesDeItens: dto.transportesDeItens,
      historico: dto.historico.map(_toHistorico).toList(),
    );
  }

  static MotoristaHistorico _toHistorico(MotoristaHistoricoResponseDto dto) {
    return MotoristaHistorico(
      id: dto.id,
      dataHoraPartida: DateTime.parse(dto.dataHoraPartida).toLocal(),
      origem: dto.origem,
      destino: dto.destino,
      tipoCorrida: dto.tipoCorrida,
    );
  }
}
