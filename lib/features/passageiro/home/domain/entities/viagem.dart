import 'package:equatable/equatable.dart';
import 'status_viagem.dart';

class Viagem extends Equatable {
  final String id;
  final DateTime dataHoraPartida;
  final String origem;
  final String destino;
  final StatusViagem status;
  final DateTime? dataChegadaEstimada;
  final String tipoCorrida;
  final double valorEstimado;
  final String? motoristaNome;
  final String? placaVeiculo;

  const Viagem({
    required this.id,
    required this.dataHoraPartida,
    required this.origem,
    required this.destino,
    this.status = StatusViagem.agendada,
    this.dataChegadaEstimada,
    this.tipoCorrida = '',
    this.valorEstimado = 0,
    this.motoristaNome,
    this.placaVeiculo,
  });

  bool get emAndamento => status == StatusViagem.emAndamento;

  @override
  List<Object?> get props => [
    id,
    dataHoraPartida,
    origem,
    destino,
    status,
    dataChegadaEstimada,
    tipoCorrida,
    valorEstimado,
    motoristaNome,
    placaVeiculo,
  ];
}
