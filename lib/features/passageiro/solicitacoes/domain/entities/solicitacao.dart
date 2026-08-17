import 'package:equatable/equatable.dart';
import 'corrida_solicitacao.dart';
import 'endereco_solicitacao.dart';
import 'passageiro_solicitacao.dart';
import 'rateio_centro_custo.dart';
import 'status_solicitacao.dart';

class Solicitacao extends Equatable {
  final int id;
  final StatusSolicitacao status;
  final DateTime dataCriacao;
  final DateTime dataCorrida;
  final DateTime? dataChegadaEstimada;
  final int? duracaoEstimadaMinutos;
  final double distanciaEstimadaKm;
  final double valorEstimado;
  final String tipoCorrida;
  final String? tipoVeiculo;
  final String? fornecedorNome;
  final EnderecoSolicitacao origem;
  final EnderecoSolicitacao destino;
  final List<EnderecoSolicitacao> paradas;
  final String motivoSolicitacao;
  final String? motivoCancelamento;
  final String? motivoReprovacao;
  final List<RateioCentroCusto> centrosCusto;
  final List<PassageiroSolicitacao> passageiros;
  final CorridaSolicitacao? corrida;
  final bool emAndamento;
  final bool cancelavel;

  const Solicitacao({
    required this.id,
    required this.status,
    required this.dataCriacao,
    required this.dataCorrida,
    required this.distanciaEstimadaKm,
    required this.valorEstimado,
    required this.tipoCorrida,
    required this.origem,
    required this.destino,
    required this.motivoSolicitacao,
    required this.emAndamento,
    required this.cancelavel,
    this.dataChegadaEstimada,
    this.duracaoEstimadaMinutos,
    this.tipoVeiculo,
    this.fornecedorNome,
    this.paradas = const [],
    this.motivoCancelamento,
    this.motivoReprovacao,
    this.centrosCusto = const [],
    this.passageiros = const [],
    this.corrida,
  });

  List<EnderecoSolicitacao> get trajeto => [origem, ...paradas, destino];

  bool get compartilhada => passageiros.length > 1;

  @override
  List<Object?> get props => [
    id,
    status,
    dataCriacao,
    dataCorrida,
    dataChegadaEstimada,
    duracaoEstimadaMinutos,
    distanciaEstimadaKm,
    valorEstimado,
    tipoCorrida,
    tipoVeiculo,
    fornecedorNome,
    origem,
    destino,
    paradas,
    motivoSolicitacao,
    motivoCancelamento,
    motivoReprovacao,
    centrosCusto,
    passageiros,
    corrida,
    emAndamento,
    cancelavel,
  ];
}

class PaginaSolicitacoes extends Equatable {
  final List<Solicitacao> itens;
  final int totalCount;
  final bool hasNextPage;

  const PaginaSolicitacoes({
    required this.itens,
    required this.totalCount,
    required this.hasNextPage,
  });

  @override
  List<Object?> get props => [itens, totalCount, hasNextPage];
}
