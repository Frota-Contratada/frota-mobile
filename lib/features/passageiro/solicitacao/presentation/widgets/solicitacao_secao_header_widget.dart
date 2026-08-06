import 'package:flutter/material.dart';
import '../../../../../core/widgets/app_colors.dart';

/// Header de seção do formulário de solicitação (ex: "Trajeto", "Data e horário").
/// Exibe um ícone de número/emoji seguido do label.
class SolicitacaoSecaoHeaderWidget extends StatelessWidget {
  final String emoji;
  final String label;

  const SolicitacaoSecaoHeaderWidget({
    super.key,
    required this.emoji,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.darkBlue,
          ),
        ),
      ],
    );
  }
}
