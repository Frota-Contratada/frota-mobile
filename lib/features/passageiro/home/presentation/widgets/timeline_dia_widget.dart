import 'package:flutter/material.dart';
import '../../domain/entities/viagem.dart';
import '../utils/semana_util.dart';
import '../../../shared/presentation/theme/passageiro_colors.dart';
import 'viagem_card_widget.dart';

class TimelineDiaWidget extends StatelessWidget {
  final DateTime dia;
  final List<Viagem> viagens;
  final bool isUltimoDia;
  final void Function(Viagem viagem)? onVerDetalhes;
  final void Function(Viagem viagem)? onViagemEmAndamento;

  const TimelineDiaWidget({
    super.key,
    required this.dia,
    required this.viagens,
    this.isUltimoDia = false,
    this.onVerDetalhes,
    this.onViagemEmAndamento,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 18,
            child: Column(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.only(top: 5),
                  decoration: const BoxDecoration(
                    color: PassageiroColors.primaryBlue,
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isUltimoDia)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: PassageiroColors.timelineGrey,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  SemanaUtil.formatarDiaViagem(dia),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: PassageiroColors.darkBlue,
                    letterSpacing: -0.16,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                ...viagens.asMap().entries.map((entry) {
                  final isUltimaViagem = entry.key == viagens.length - 1;
                  final bottomPadding =
                      isUltimoDia && isUltimaViagem ? 0.0 : 16.0;

                  return Padding(
                    padding: EdgeInsets.only(bottom: bottomPadding),
                    child: ViagemCardWidget(
                      viagem: entry.value,
                      onVerDetalhes: onVerDetalhes == null
                          ? null
                          : () => onVerDetalhes!(entry.value),
                      onViagemEmAndamento: onViagemEmAndamento == null
                          ? null
                          : () => onViagemEmAndamento!(entry.value),
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
