import 'package:flutter/material.dart';
import '../../../../../core/widgets/app_colors.dart';

/// Header de seção do formulário de solicitação (ex: "Trajeto", "Data e horário").
/// Exibe um ícone de número/emoji seguido do label.
class SolicitacaoSecaoHeaderWidget extends StatelessWidget {
  final String? emoji;
  final String? number;
  final String? iconAsset;
  final String label;

  const SolicitacaoSecaoHeaderWidget({
    super.key,
    this.emoji,
    this.number,
    this.iconAsset,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (number != null)
          Text(
            number!,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.darkBlue,
            ),
          ),
        if (iconAsset != null)
          Padding(
            padding: EdgeInsets.only(left: number == null ? 0 : 7),
            child: Image.asset(
              iconAsset!,
              width: 16,
              height: 16,
              fit: BoxFit.contain,
              color: AppColors.textGrey,
            ),
          )
        else if (emoji != null)
          Text(emoji!, style: const TextStyle(fontSize: 14)),
        if (number != null || iconAsset != null || emoji != null)
          const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.darkBlue,
          ),
        ),
      ],
    );
  }
}
