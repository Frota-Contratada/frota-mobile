import 'package:flutter/material.dart';
import '../../../../../config/routes.dart';
import '../../../../../core/widgets/timeline_dia_widget.dart' as shared;
import '../../domain/entities/corrida.dart';
import '../utils/semana_util.dart';
import 'corrida_card_widget.dart';

/// Timeline de dia do motorista.
/// Delegação para o widget compartilhado [shared.TimelineDiaWidget],
/// construindo os cards específicos de corrida do motorista.
class TimelineDiaWidget extends StatelessWidget {
  final DateTime dia;
  final List<Corrida> corridas;
  final bool isUltimoDia;

  const TimelineDiaWidget({
    super.key,
    required this.dia,
    required this.corridas,
    this.isUltimoDia = false,
  });

  @override
  Widget build(BuildContext context) {
    final cards = corridas.asMap().entries.map((entry) {
      final isUltimaCorrida = entry.key == corridas.length - 1;
      final bottomPadding = isUltimoDia && isUltimaCorrida ? 0.0 : 16.0;

      return Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: CorridaCardWidget(
          corrida: entry.value,
          onVerDetalhes: () => Navigator.pushNamed(
            context,
            AppRoutes.motoristaCorridaDetalhe,
            arguments: entry.value.id,
          ),
          onIniciarCorrida: () => Navigator.pushNamed(
            context,
            AppRoutes.motoristaCorridaDetalhe,
            arguments: entry.value.id,
          ),
        ),
      );
    }).toList();

    return shared.TimelineDiaWidget(
      labelDia: SemanaUtil.formatarDiaCorrida(dia),
      cards: cards,
      isUltimoDia: isUltimoDia,
    );
  }
}
