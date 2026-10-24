import 'package:flutter/material.dart';

import '../../../../../core/widgets/app_colors.dart';

class SolicitacaoErroSimulacaoWidget extends StatelessWidget {
  static const _corErro = Color(0xFFC62828);
  static const _fundoErro = Color(0xFFFDECEA);

  final String mensagem;
  final VoidCallback onTentarNovamente;

  const SolicitacaoErroSimulacaoWidget({
    super.key,
    required this.mensagem,
    required this.onTentarNovamente,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(14, 12, 8, 8),
        decoration: BoxDecoration(
          color: _fundoErro,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _corErro.withValues(alpha: 0.35)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.error_outline, color: _corErro, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Não foi possível calcular a estimativa',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _corErro,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        mensagem,
                        style: const TextStyle(
                          fontSize: 12,
                          height: 1.3,
                          color: AppColors.darkBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onTentarNovamente,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Tentar novamente'),
                style: TextButton.styleFrom(foregroundColor: _corErro),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
