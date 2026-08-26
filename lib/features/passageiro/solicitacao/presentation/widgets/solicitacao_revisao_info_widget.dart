import 'package:flutter/material.dart';

import '../../../../../core/widgets/app_colors.dart';

/// Item de informação das telas de revisão da solicitação.
///
/// Segue o padrão da tela de detalhes da corrida: ícone à esquerda em um slot
/// de largura fixa, centralizado verticalmente em relação ao bloco de texto,
/// com rótulo acima e valor(es) abaixo.
class SolicitacaoRevisaoInfoWidget extends StatelessWidget {
  final Widget icon;

  /// Rótulo acima do valor. Omitido quando a seção já identifica a informação.
  final String? label;

  /// Um ou mais valores, cada um em sua própria linha.
  final List<String> valores;

  /// Limite de linhas por valor (usado em endereços longos).
  final int? maxLines;

  /// Largura do slot do ícone. Mantém todos os textos alinhados
  /// independentemente do tamanho de cada ícone.
  static const double iconSlotWidth = 16;

  /// Espaço entre o ícone e o texto.
  static const double iconGap = 12;

  /// Espaço vertical recomendado entre dois itens.
  static const double itemSpacing = 14;

  const SolicitacaoRevisaoInfoWidget({
    super.key,
    required this.icon,
    required this.valores,
    this.label,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: iconSlotWidth,
          child: Center(child: icon),
        ),
        const SizedBox(width: iconGap),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (label != null) ...[
                Text(
                  label!,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.25,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textGrey,
                  ),
                ),
                const SizedBox(height: 2),
              ],
              for (var index = 0; index < valores.length; index++) ...[
                if (index > 0) const SizedBox(height: 3),
                Text(
                  valores[index],
                  maxLines: maxLines,
                  overflow: maxLines == null ? null : TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.3,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkBlue,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// Marcador de origem/parada, no tamanho usado pelo slot do ícone.
  static Widget dot({Color color = AppColors.primaryBlue}) {
    return Container(
      width: 9,
      height: 9,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  /// Linha vertical que conecta dois pontos do trajeto, alinhada ao centro do
  /// slot do ícone.
  static Widget connector() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: SizedBox(
        width: iconSlotWidth,
        child: Center(
          child: Container(width: 1.5, height: 14, color: AppColors.borderGrey),
        ),
      ),
    );
  }
}
