import 'package:flutter/material.dart';
import '../../../../../core/widgets/origem_destino_trajeto_widget.dart';

class CorridaTrajetoWidget extends StatelessWidget {
  final String origem;
  final String destino;

  const CorridaTrajetoWidget({
    super.key,
    required this.origem,
    required this.destino,
  });

  @override
  Widget build(BuildContext context) {
    return OrigemDestinoTrajetoWidget(
      origem: origem,
      destino: destino,
    );
  }
}
