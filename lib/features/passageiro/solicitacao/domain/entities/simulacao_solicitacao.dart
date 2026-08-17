import 'package:equatable/equatable.dart';

class SimulacaoSolicitacao extends Equatable {
  final double distanciaEstimadaKm;
  final int duracaoEstimadaMinutos;
  final DateTime dataChegadaEstimada;
  final double valorEstimado;
  final int fornecedorId;
  final String fornecedorNome;

  const SimulacaoSolicitacao({
    required this.distanciaEstimadaKm,
    required this.duracaoEstimadaMinutos,
    required this.dataChegadaEstimada,
    required this.valorEstimado,
    required this.fornecedorId,
    required this.fornecedorNome,
  });

  @override
  List<Object?> get props => [
    distanciaEstimadaKm,
    duracaoEstimadaMinutos,
    dataChegadaEstimada,
    valorEstimado,
    fornecedorId,
    fornecedorNome,
  ];
}
