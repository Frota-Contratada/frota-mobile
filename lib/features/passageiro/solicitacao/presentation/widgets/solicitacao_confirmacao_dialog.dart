import 'package:flutter/material.dart';

import '../../../../../core/widgets/app_colors.dart';

/// Diálogo exibido após o envio de uma solicitação.
class SolicitacaoConfirmacaoDialog extends StatelessWidget {
  final String titulo;
  final String mensagem;
  final String? submensagem;
  final VoidCallback onFechar;

  const SolicitacaoConfirmacaoDialog({
    super.key,
    required this.titulo,
    required this.mensagem,
    this.submensagem,
    required this.onFechar,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      backgroundColor: AppColors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 26, 24, 27),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 66,
              height: 66,
              decoration: const BoxDecoration(
                color: AppColors.accentGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                size: 48,
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.darkBlue,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              mensagem,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textMediumGrey,
                height: 1.35,
              ),
            ),
            if (submensagem != null) ...[
              const SizedBox(height: 12),
              Text(
                submensagem!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMediumGrey,
                  height: 1.35,
                ),
              ),
            ],
            const SizedBox(height: 18),
            SizedBox(
              width: 150,
              height: 38,
              child: ElevatedButton(
                onPressed: onFechar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: AppColors.white,
                  elevation: 0,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Fechar',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
