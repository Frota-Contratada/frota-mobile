import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Widget de timeline por dia, compartilhado entre motorista e passageiro.
/// Exibe o indicador circular do dia com linha conectora e lista de cards.
class TimelineDiaWidget extends StatelessWidget {
  final String labelDia;
  final List<Widget> cards;
  final bool isUltimoDia;

  const TimelineDiaWidget({
    super.key,
    required this.labelDia,
    required this.cards,
    this.isUltimoDia = false,
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
                    color: AppColors.primaryBlue,
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isUltimoDia)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: AppColors.timelineGrey,
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
                  labelDia,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.darkBlue,
                    letterSpacing: -0.16,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                ...cards,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
