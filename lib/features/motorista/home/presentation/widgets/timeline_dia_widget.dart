import 'package:flutter/material.dart';
import '../../../../../config/routes.dart';
import '../../domain/entities/corrida.dart';
import '../utils/semana_util.dart';
import 'corrida_card_widget.dart';
import 'home_colors.dart';

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
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  SemanaUtil.formatarDiaCorrida(dia),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: HomeColors.darkBlue,
                    letterSpacing: -0.16,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                ...corridas.asMap().entries.map((entry) {
                  final isUltimaCorrida = entry.key == corridas.length - 1;
                  final bottomPadding = isUltimoDia && isUltimaCorrida
                      ? 0.0
                      : 16.0;

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
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
