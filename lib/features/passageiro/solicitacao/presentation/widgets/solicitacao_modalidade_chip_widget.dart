import 'package:flutter/material.dart';
import '../../../../../core/widgets/app_colors.dart';

/// Chip que exibe a modalidade da solicitação (ex: "Modalidade: Táxi", "Modalidade: Objetos").
class SolicitacaoModalidadeChipWidget extends StatelessWidget {
  final String modalidade;

  const SolicitacaoModalidadeChipWidget({
    super.key,
    required this.modalidade,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.weekSelectorBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Modalidade: $modalidade',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.darkBlue,
        ),
      ),
    );
  }
}
