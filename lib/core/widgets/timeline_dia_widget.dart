import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Widget de listagem por dia, compartilhado entre motorista e passageiro.
/// Exibe o indicador circular do dia e a lista de cards na mesma largura do seletor de semana.
class TimelineDiaWidget extends StatelessWidget {
  final String labelDia;
  final List<Widget> cards;
  final bool isUltimoDia;
  final Color corIndicador;
  final Color corLabel;

  const TimelineDiaWidget({
    super.key,
    required this.labelDia,
    required this.cards,
    this.isUltimoDia = false,
    this.corIndicador = AppColors.primaryBlue,
    this.corLabel = AppColors.darkBlue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: corIndicador,
                shape: BoxShape.circle,
              ),
            ),
            Expanded(
              child: Text(
                labelDia,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: corLabel,
                  letterSpacing: -0.16,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...cards,
      ],
    );
  }
}
