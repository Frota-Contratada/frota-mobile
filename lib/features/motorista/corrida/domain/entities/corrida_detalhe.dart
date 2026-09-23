import 'package:equatable/equatable.dart';
import '../../../../shared/trip_tracking/domain/entities/trip_tracking_snapshot.dart';

class CorridaDetalhe extends Equatable {
  final String id;
  final DateTime dataHoraPartida;
  final String origem;
  final String destino;
  final String nomePassageiro;
  final double valorEstimado;
  final bool ehProxima;
  final int? minutosRestantes;
  final String? motivoRecusa;
  final TripTrackingSnapshot? trackingSnapshot;

  const CorridaDetalhe({
    required this.id,
    required this.dataHoraPartida,
    required this.origem,
    required this.destino,
    required this.nomePassageiro,
    required this.valorEstimado,
    this.ehProxima = false,
    this.minutosRestantes,
    this.motivoRecusa,
    this.trackingSnapshot,
  });

  @override
  List<Object?> get props => [
    id,
    dataHoraPartida,
    origem,
    destino,
    nomePassageiro,
    valorEstimado,
    ehProxima,
    minutosRestantes,
    motivoRecusa,
    trackingSnapshot,
  ];
}
