import 'package:flutter/material.dart';
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
          const _TimelineRail(),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  SemanaUtil.formatarDiaCorrida(dia),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: HomeColors.darkBlue,
                    letterSpacing: -0.16,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                ...corridas.asMap().entries.map(
                  (entry) {
                    final isUltimaCorrida = entry.key == corridas.length - 1;
                    final bottomPadding =
                        isUltimoDia && isUltimaCorrida ? 0.0 : 16.0;

                    return Padding(
                      padding: EdgeInsets.only(bottom: bottomPadding),
                      child: CorridaCardWidget(corrida: entry.value),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineRail extends StatelessWidget {
  const _TimelineRail();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            top: 5,
            left: 0,
            right: 0,
            bottom: 0,
            child: Center(
              child: Container(
                width: 2,
                color: HomeColors.timelineGrey,
              ),
            ),
          ),
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(top: 1),
            decoration: const BoxDecoration(
              color: HomeColors.timelineGrey,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}
