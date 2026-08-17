import 'package:equatable/equatable.dart';

class CorridaSolicitacao extends Equatable {
  final int id;
  final DateTime dataInicio;
  final DateTime? dataFim;
  final String? motoristaNome;
  final String placaVeiculo;
  final double kmPercorrido;
  final double valorFinal;
  final bool emAndamento;

  const CorridaSolicitacao({
    required this.id,
    required this.dataInicio,
    required this.placaVeiculo,
    required this.kmPercorrido,
    required this.valorFinal,
    required this.emAndamento,
    this.dataFim,
    this.motoristaNome,
  });

  @override
  List<Object?> get props => [
    id,
    dataInicio,
    dataFim,
    motoristaNome,
    placaVeiculo,
    kmPercorrido,
    valorFinal,
    emAndamento,
  ];
}
