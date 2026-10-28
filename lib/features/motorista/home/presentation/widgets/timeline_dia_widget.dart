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
    final cards = corridas.map((corrida) {
      return CorridaCardWidget(
        corrida: corrida,
        onVerDetalhes: () => Navigator.pushNamed(
          context,
          AppRoutes.motoristaCorridaDetalhe,
          arguments: corrida.id,
        ),
        onIniciarCorrida: () => Navigator.pushNamed(
          context,
          AppRoutes.motoristaCorridaDetalhe,
          arguments: corrida.id,
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
