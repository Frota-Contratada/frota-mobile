import 'package:flutter/material.dart';
import '../../../../../core/widgets/app_colors.dart';

/// Input reutilizável para formulários de solicitação.
/// Suporta estado vazio (placeholder), preenchido (label+valor) e dropdown.
class SolicitacaoInputWidget extends StatelessWidget {
  final String label;
  final String? valor;
  final bool isDropdown;
  final VoidCallback? onTap;
  final double height;

  const SolicitacaoInputWidget({
    super.key,
    required this.label,
    this.valor,
    this.isDropdown = false,
    this.onTap,
    this.height = 45,
  });

  @override
  Widget build(BuildContext context) {
    final preenchido = valor != null && valor!.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.borderGrey),
        ),
        child: Row(
          children: [
            Expanded(
              child: preenchido
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          label,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textGrey,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          valor!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.darkBlue,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      label,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textGrey,
                      ),
                    ),
            ),
            if (isDropdown)
              const Icon(
                Icons.keyboard_arrow_down,
                size: 18,
                color: AppColors.textGrey,
              ),
          ],
        ),
      ),
    );
  }
}
