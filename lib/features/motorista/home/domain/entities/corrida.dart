import 'package:equatable/equatable.dart';

class Corrida extends Equatable {
  final String id;
  final DateTime dataHoraPartida;
  final String origem;
  final String destino;
  final bool ehProxima;
  final int? minutosRestantes;

  const Corrida({
    required this.id,
    required this.dataHoraPartida,
    required this.origem,
    required this.destino,
    this.ehProxima = false,
    this.minutosRestantes,
  });

  @override
  List<Object?> get props => [
    id,
    dataHoraPartida,
    origem,
    destino,
    ehProxima,
    minutosRestantes,
  ];
}
