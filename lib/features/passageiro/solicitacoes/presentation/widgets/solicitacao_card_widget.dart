import 'package:flutter/material.dart';
import '../../../../../config/app_assets.dart';
import '../../../../../core/widgets/app_colors.dart';
import 'solicitacao_status.dart';

/// Card de solicitação de corrida do passageiro.
/// Exibe destino, status (com barra colorida na lateral esquerda), data e horário de partida.
class SolicitacaoCardWidget extends StatelessWidget {
  final String destino;
  final SolicitacaoStatus status;
  final String data;
  final String horarioPartida;
  final VoidCallback? onVerDetalhes;

  const SolicitacaoCardWidget({
    super.key,
    required this.destino,
    required this.status,
    required this.data,
    required this.horarioPartida,
    this.onVerDetalhes,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.borderGrey),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Barra colorida lateral (full height)
            Container(
              width: 9,
              decoration: BoxDecoration(
                color: status.corIndicador,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                ),
              ),
            ),
            // Conteúdo do card
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(15, 14, 15, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Linha 1: Destino + Data
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _LabelText('Destino'),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Image.asset(
                                    AppAssets.iconDestino,
                                    width: 12,
                                    height: 14,
                                    fit: BoxFit.contain,
                                    color: AppColors.textGrey,
                                    colorBlendMode: BlendMode.srcIn,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      destino,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.darkBlue,
                                        height: 1.25,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const _LabelText('Data'),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  AppAssets.iconData,
                                  width: 16,
                                  height: 16,
                                  fit: BoxFit.contain,
                                  color: AppColors.textGrey,
                                  colorBlendMode: BlendMode.srcIn,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  data,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.darkBlue,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    // Linha 2: Status + Partida
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _LabelText('Status'),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    width: 9,
                                    height: 9,
                                    decoration: BoxDecoration(
                                      color: status.corIndicador,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      status.label,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.darkBlue,
                                        height: 1.25,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const _LabelText('Partida'),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  AppAssets.iconHorario,
                                  width: 16,
                                  height: 16,
                                  fit: BoxFit.contain,
                                  color: AppColors.textGrey,
                                  colorBlendMode: BlendMode.srcIn,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  horarioPartida,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.darkBlue,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Botão ver detalhes
                    SizedBox(
                      width: double.infinity,
                      height: 30,
                      child: ElevatedButton(
                        onPressed: onVerDetalhes,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.buttonBlue,
                          foregroundColor: AppColors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(150),
                          ),
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(double.infinity, 30),
                        ),
                        child: const Text(
                          'ver detalhes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LabelText extends StatelessWidget {
  final String text;

  const _LabelText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        color: AppColors.textGrey,
        letterSpacing: -0.12,
      ),
    );
  }
}
