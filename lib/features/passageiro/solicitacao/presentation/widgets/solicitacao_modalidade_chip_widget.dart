import 'package:flutter/material.dart';
import '../../../../../core/widgets/app_colors.dart';

/// Chip que exibe a modalidade da solicitação (ex: "Modalidade: Táxi", "Modalidade: Objetos").
class SolicitacaoModalidadeChipWidget extends StatelessWidget {
  final String modalidade;
  final Color? backgroundColor;
  final Color? textColor;

  const SolicitacaoModalidadeChipWidget({
    super.key,
    required this.modalidade,
    this.backgroundColor,
    this.textColor,
  });

  bool get _isObjeto => modalidade.toLowerCase().contains('objeto');

  @override
  Widget build(BuildContext context) {
    final background =
        backgroundColor ??
        (_isObjeto ? const Color(0xFFFFE0BE) : const Color(0xFFB9E5F8));
    final foreground =
        textColor ??
        (_isObjeto ? const Color(0xFFE88A16) : AppColors.primaryBlue);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'Modalidade: $modalidade',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: foreground,
        ),
      ),
    );
  }
}
