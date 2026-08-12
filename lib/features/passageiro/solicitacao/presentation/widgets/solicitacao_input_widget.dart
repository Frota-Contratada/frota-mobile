import 'package:flutter/material.dart';
import '../../../../../core/widgets/app_colors.dart';

/// Input reutilizável para formulários de solicitação.
/// Suporta estado vazio (placeholder), preenchido (label+valor) e dropdown.
///
/// Quando [isOpen] é `true` o campo ganha borda de destaque com halo suave e a
/// seta gira, indicando que a lista de opções está aberta logo abaixo.
class SolicitacaoInputWidget extends StatelessWidget {
  final String label;
  final String? valor;
  final bool isDropdown;
  final String? iconAsset;
  final VoidCallback? onTap;
  final double height;

  /// Indica que a lista de opções deste campo está aberta.
  final bool isOpen;

  /// Cor de destaque usada na borda/seta quando o campo está aberto.
  final Color accentColor;

  static const double borderRadius = 12;

  const SolicitacaoInputWidget({
    super.key,
    required this.label,
    this.valor,
    this.isDropdown = false,
    this.iconAsset,
    this.onTap,
    this.height = 45,
    this.isOpen = false,
    this.accentColor = AppColors.primaryBlue,
  });

  @override
  Widget build(BuildContext context) {
    final preenchido = valor != null && valor!.isNotEmpty;

    return Semantics(
      button: onTap != null,
      label: label,
      expanded: isDropdown ? isOpen : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          height: height,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: isOpen ? accentColor : AppColors.dropdownBorder,
              width: isOpen ? 1.4 : 1,
            ),
            boxShadow: isOpen
                ? [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.12),
                      blurRadius: 0,
                      spreadRadius: 3,
                    ),
                  ]
                : const [
                    BoxShadow(
                      color: Color(0x0A101038),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            children: [
              if (iconAsset != null) ...[
                Image.asset(
                  iconAsset!,
                  width: 15,
                  height: 15,
                  fit: BoxFit.contain,
                  color: AppColors.textGrey,
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: preenchido
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              height: 1.2,
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
                              fontSize: 15,
                              height: 1.2,
                              fontWeight: FontWeight.w600,
                              color: AppColors.darkBlue,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textGrey,
                        ),
                      ),
              ),
              if (isDropdown)
                AnimatedRotation(
                  turns: isOpen ? 0.5 : 0,
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 20,
                    color: isOpen ? accentColor : AppColors.textGrey,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
