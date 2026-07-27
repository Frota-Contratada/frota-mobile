import 'package:equatable/equatable.dart';
import 'status_viagem.dart';

class Viagem extends Equatable {
  final String id;
  final DateTime dataHoraPartida;
  final String origem;
  final String destino;
  final StatusViagem status;

  const Viagem({
    required this.id,
    required this.dataHoraPartida,
    required this.origem,
    required this.destino,
    this.status = StatusViagem.agendada,
  });

  bool get emAndamento => status == StatusViagem.emAndamento;

  @override
  List<Object?> get props => [
        id,
        dataHoraPartida,
        origem,
        destino,
        status,
      ];
}
