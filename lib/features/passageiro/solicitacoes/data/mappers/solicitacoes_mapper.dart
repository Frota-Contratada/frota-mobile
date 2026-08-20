import '../../domain/entities/corrida_solicitacao.dart';
import '../../domain/entities/endereco_solicitacao.dart';
import '../../domain/entities/motivo.dart';
import '../../domain/entities/passageiro_solicitacao.dart';
import '../../domain/entities/rateio_centro_custo.dart';
import '../../domain/entities/solicitacao.dart';
import '../../domain/entities/status_solicitacao.dart';
import '../dtos/response/solicitacao_response_dto.dart';

class SolicitacoesMapper {
  static Solicitacao toEntity(SolicitacaoResponseDto dto) {
    final paradasOrdenadas = [...dto.paradas]
      ..sort((uma, outra) => uma.ordem.compareTo(outra.ordem));

    return Solicitacao(
      id: dto.id,
      status: StatusSolicitacao.aPartirDoCodigo(dto.status),
      dataCriacao: _paraLocal(dto.dataCriacao),
      dataCorrida: _paraLocal(dto.dataCorrida),
      dataChegadaEstimada: dto.dataChegadaEstimada == null
          ? null
          : _paraLocal(dto.dataChegadaEstimada!),
      duracaoEstimadaMinutos: dto.duracaoEstimadaMinutos,
      distanciaEstimadaKm: dto.distanciaEstimadaKm,
      valorEstimado: dto.valorEstimado,
      tipoCorrida: dto.tipoCorrida.nome,
      tipoVeiculo: dto.tipoVeiculo?.nome,
      fornecedorNome: dto.fornecedorNome,
      origem: _toEndereco(dto.origem),
      destino: _toEndereco(dto.destino),
      paradas: paradasOrdenadas
          .map((parada) => _toEndereco(parada.endereco))
          .toList(),
      motivoSolicitacao: dto.motivoSolicitacao.nome,
      motivoCancelamento: dto.motivoCancelamento?.nome,
      motivoReprovacao: dto.motivoReprovacao?.nome,
      centrosCusto: dto.centrosCusto
          .map(
            (rateio) => RateioCentroCusto(
              centroCustoId: rateio.centroCustoId,
              statusAprovacao: rateio.statusAprovacao,
              centroCustoNome: rateio.centroCustoNome,
              aprovadorNome: rateio.aprovadorNome,
              motivoRecusa: rateio.motivoRecusa?.nome,
            ),
          )
          .toList(),
      passageiros: dto.passageiros
          .map(
            (passageiro) => PassageiroSolicitacao(
              cpf: passageiro.cpf,
              nome: passageiro.nome,
              solicitante: passageiro.solicitante,
            ),
          )
          .toList(),
      corrida: dto.corrida == null ? null : _toCorrida(dto.corrida!),
      emAndamento: dto.emAndamento,
      cancelavel: dto.cancelavel,
    );
  }

  static Motivo toMotivo(CatalogoItemResponseDto dto) {
    return Motivo(
      id: dto.id,
      nome: dto.nome,
      tipo: dto.tipo,
      capacidadePassageiros: dto.capacidadePassageiros,
    );
  }

  static EnderecoSolicitacao _toEndereco(EnderecoResponseDto dto) {
    return EnderecoSolicitacao(
      id: dto.id,
      descricao: dto.descricao,
      logradouro: dto.logradouro,
      cidade: dto.cidade,
      uf: dto.uf,
      latitude: dto.latitude,
      longitude: dto.longitude,
      numero: dto.numero,
      bairro: dto.bairro,
    );
  }

  static CorridaSolicitacao _toCorrida(CorridaResponseDto dto) {
    return CorridaSolicitacao(
      id: dto.id,
      dataInicio: _paraLocal(dto.dataInicio),
      dataFim: dto.dataFim == null ? null : _paraLocal(dto.dataFim!),
      motoristaNome: dto.motoristaNome,
      placaVeiculo: dto.placaVeiculo,
      kmPercorrido: dto.kmPercorrido,
      valorFinal: dto.valorFinal,
      emAndamento: dto.emAndamento,
      status: dto.status,
    );
  }

  static DateTime _paraLocal(String iso) => DateTime.parse(iso).toLocal();
}
