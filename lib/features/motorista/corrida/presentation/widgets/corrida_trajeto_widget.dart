import 'package:flutter/material.dart';
import '../../../../../core/widgets/origem_destino_trajeto_widget.dart';
import '../../domain/entities/corrida_detalhe.dart';

class CorridaTrajetoWidget extends StatelessWidget {
  final String origem;
  final String destino;
  final List<CorridaParada> paradas;

  const CorridaTrajetoWidget({
    super.key,
    required this.origem,
    required this.destino,
    this.paradas = const [],
  });

  @override
  Widget build(BuildContext context) {
    return OrigemDestinoTrajetoWidget(
      origem: origem,
      destino: destino,
      paradas: paradas.map((parada) => parada.endereco).toList(),
    );
  }
}
