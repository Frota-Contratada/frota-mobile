import 'package:flutter/material.dart';
import '../../../../../core/widgets/semana_seletor_widget.dart' as shared;

/// Seletor de semana do passageiro.
/// Delegação para o widget compartilhado [shared.SemanaSeletorWidget].
class SemanaSeletorWidget extends StatelessWidget {
  final String intervaloSemana;
  final VoidCallback onSemanaAnterior;
  final VoidCallback onSemanaProxima;

  const SemanaSeletorWidget({
    super.key,
    required this.intervaloSemana,
    required this.onSemanaAnterior,
    required this.onSemanaProxima,
  });

  @override
  Widget build(BuildContext context) {
    return shared.SemanaSeletorWidget(
      intervaloSemana: intervaloSemana,
      onSemanaAnterior: onSemanaAnterior,
      onSemanaProxima: onSemanaProxima,
    );
  }
}
