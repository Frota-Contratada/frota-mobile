import 'package:flutter/material.dart';
import '../../../../../core/widgets/app_colors.dart';

/// Dialog de confirmação de solicitação (viagem ou objeto).
/// Exibe ícone de sucesso, título, mensagem e botão fechar.
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppColors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ícone de sucesso
            Container(
              width: 107,
              height: 107,
              decoration: BoxDecoration(
                color: AppColors.accentGreen.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                size: 60,
                color: AppColors.accentGreen,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.darkBlue,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              mensagem,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.textMediumGrey,
                height: 1.5,
              ),
            ),
            if (submensagem != null) ...[
              const SizedBox(height: 12),
              Text(
                submensagem!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textMediumGrey,
                  height: 1.5,
                ),
              ),
            ],
            const SizedBox(height: 28),
            SizedBox(
              width: 245,
              height: 60,
              child: ElevatedButton(
                onPressed: onFechar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: AppColors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Fechar',
                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
