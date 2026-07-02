import 'package:flutter/material.dart';
import '../../domain/entities/corrida.dart';
import '../utils/semana_util.dart';
import 'corrida_card_widget.dart';
import 'viagens_colors.dart';

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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TimelineRail(terminaAqui: isUltimoDia),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                SemanaUtil.formatarDiaCorrida(dia),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: ViagensColors.darkBlue,
                  letterSpacing: -0.16,
                ),
              ),
              const SizedBox(height: 12),
              ...corridas.map(
                (corrida) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: CorridaCardWidget(corrida: corrida),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TimelineRail extends StatelessWidget {
  final bool terminaAqui;

  const _TimelineRail({required this.terminaAqui});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: ViagensColors.timelineGrey,
              shape: BoxShape.circle,
            ),
          ),
          if (!terminaAqui)
            Container(
              width: 2,
              height: 32,
              margin: const EdgeInsets.symmetric(vertical: 4),
              color: ViagensColors.timelineGrey,
            ),
        ],
      ),
    );
  }
}
