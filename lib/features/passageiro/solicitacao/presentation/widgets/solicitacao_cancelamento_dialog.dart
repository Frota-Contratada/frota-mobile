import 'package:flutter/material.dart';

import '../../../../../core/widgets/app_colors.dart';

/// Confirmação visual para cancelar uma solicitação existente.
class SolicitacaoCancelamentoDialog extends StatelessWidget {
  final VoidCallback onNao;
  final VoidCallback onSim;

  const SolicitacaoCancelamentoDialog({
    super.key,
    required this.onNao,
    required this.onSim,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      backgroundColor: AppColors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 26, 18, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Tem certeza de que deseja\ncancelar esta solicitação?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.darkBlue,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ActionButton(
                  label: 'Não',
                  color: Colors.red,
                  onPressed: onNao,
                ),
                const SizedBox(width: 8),
                _ActionButton(
                  label: 'Sim',
                  color: AppColors.primaryBlue,
                  onPressed: onSim,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 94,
      height: 26,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: AppColors.white,
          elevation: 0,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
