import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Widget de empty state compartilhado.
/// Exibe um icone sutil, mensagem principal e mensagem secundaria opcional.
/// Usado quando filtros ou buscas nao retornam resultados.
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String mensagem;
  final String? submensagem;
  final double iconSize;

  const EmptyStateWidget({
    super.key,
    this.icon = Icons.search_off_rounded,
    required this.mensagem,
    this.submensagem,
    this.iconSize = 48,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.weekSelectorBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: iconSize, color: AppColors.textGrey),
          ),
          const SizedBox(height: 20),
          Text(
            mensagem,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.darkBlue,
              height: 1.4,
            ),
          ),
          if (submensagem != null) ...[
            const SizedBox(height: 8),
            Text(
              submensagem!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.textMediumGrey,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
