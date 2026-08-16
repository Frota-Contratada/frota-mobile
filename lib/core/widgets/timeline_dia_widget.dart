import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Widget de listagem por dia, compartilhado entre motorista e passageiro.
/// Exibe o indicador circular do dia e a lista de cards na mesma largura do seletor de semana.
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.only(right: 8),
              decoration: const BoxDecoration(
                color: AppColors.primaryBlue,
                shape: BoxShape.circle,
              ),
            ),
            Expanded(
              child: Text(
                labelDia,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.darkBlue,
                  letterSpacing: -0.16,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...cards,
      ],
    );
  }
}
