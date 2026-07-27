import 'package:flutter/material.dart';
import '../../config/app_assets.dart';
import 'app_colors.dart';

/// Card de visualização de corrida compartilhado entre motorista e passageiro.
/// Exibe origem, destino, horário de partida e botão de ação.
class CorridaCardBaseWidget extends StatelessWidget {
  final String origem;
  final String destino;
  final String horarioPartida;
  final VoidCallback? onVerDetalhes;

  /// Se `true`, exibe o botão "viagem em andamento" no lugar de "ver detalhes".
  final bool emAndamento;
  final VoidCallback? onViagemEmAndamento;

  const CorridaCardBaseWidget({
    super.key,
    required this.origem,
    required this.destino,
    required this.horarioPartida,
    this.onVerDetalhes,
    this.emAndamento = false,
    this.onViagemEmAndamento,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15, 14, 15, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const SizedBox(width: 14),
                const _LabelText('Origem'),
                const Spacer(),
                const _LabelText('Partida'),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _RotaIndicador(),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        origem,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.darkBlue,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const _LabelText('Destino'),
                      const SizedBox(height: 4),
                      Text(
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
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _HorarioPartida(horario: horarioPartida),
              ],
            ),
            const SizedBox(height: 16),
            _buildAcao(),
          ],
        ),
      ),
    );
  }

  Widget _buildAcao() {
    if (emAndamento) {
      return SizedBox(
        width: double.infinity,
        height: 30,
        child: ElevatedButton(
          onPressed: onViagemEmAndamento,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.emAndamentoBlue,
            foregroundColor: AppColors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(150),
            ),
            padding: EdgeInsets.zero,
            minimumSize: const Size(double.infinity, 30),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 9,
                height: 9,
                decoration: const BoxDecoration(
                  color: AppColors.accentGreen,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'viagem em andamento',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
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
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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

class _RotaIndicador extends StatelessWidget {
  const _RotaIndicador();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 9,
          height: 9,
          margin: const EdgeInsets.only(top: 4),
          decoration: const BoxDecoration(
            color: AppColors.primaryBlue,
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: 2,
          height: 35,
          margin: const EdgeInsets.symmetric(vertical: 2),
          color: AppColors.borderGrey,
        ),
        Image.asset(
          AppAssets.iconDestino,
          width: 9,
          height: 11,
          fit: BoxFit.contain,
        ),
      ],
    );
  }
}

class _HorarioPartida extends StatelessWidget {
  final String horario;

  const _HorarioPartida({required this.horario});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.schedule_outlined,
          color: AppColors.primaryBlue,
          size: 16,
        ),
        const SizedBox(width: 4),
        Text(
          horario,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.darkBlue,
          ),
        ),
      ],
    );
  }
}
