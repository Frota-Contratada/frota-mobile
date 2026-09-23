import 'package:equatable/equatable.dart';

class RateioCentroCusto extends Equatable {
  final int centroCustoId;
  final String? centroCustoNome;
  final String? aprovadorNome;
  final String statusAprovacao;
  final String? motivoRecusa;

  const RateioCentroCusto({
    required this.centroCustoId,
    required this.statusAprovacao,
    this.centroCustoNome,
    this.aprovadorNome,
    this.motivoRecusa,
  });

  @override
  List<Object?> get props => [
    centroCustoId,
    centroCustoNome,
    aprovadorNome,
    statusAprovacao,
    motivoRecusa,
  ];
}
