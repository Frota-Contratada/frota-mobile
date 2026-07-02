import 'package:flutter/material.dart';
import '../../domain/entities/viagem.dart';
import '../utils/semana_util.dart';
import '../../../shared/presentation/theme/passageiro_colors.dart';

class ViagemCardWidget extends StatelessWidget {
  final Viagem viagem;
  final VoidCallback? onVerDetalhes;
  final VoidCallback? onViagemEmAndamento;

  const ViagemCardWidget({
    super.key,
    required this.viagem,
    this.onVerDetalhes,
    this.onViagemEmAndamento,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: PassageiroColors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: PassageiroColors.borderGrey),
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
                _RotaIndicador(),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        viagem.origem,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: PassageiroColors.darkBlue,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const _LabelText('Destino'),
                      const SizedBox(height: 4),
                      Text(
                        viagem.destino,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: PassageiroColors.darkBlue,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _HorarioPartida(dataHora: viagem.dataHoraPartida),
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
    if (viagem.emAndamento) {
      return SizedBox(
        width: double.infinity,
        height: 30,
        child: ElevatedButton(
          onPressed: onViagemEmAndamento,
          style: ElevatedButton.styleFrom(
            backgroundColor: PassageiroColors.emAndamentoBlue,
            foregroundColor: PassageiroColors.white,
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
                  color: PassageiroColors.accentGreen,
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
          backgroundColor: PassageiroColors.buttonBlue,
          foregroundColor: PassageiroColors.white,
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
        color: PassageiroColors.textGrey,
        letterSpacing: -0.12,
      ),
    );
  }
}

class _RotaIndicador extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 9,
          height: 9,
          margin: const EdgeInsets.only(top: 4),
          decoration: const BoxDecoration(
            color: PassageiroColors.primaryBlue,
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: 2,
          height: 35,
          margin: const EdgeInsets.symmetric(vertical: 2),
          color: PassageiroColors.borderGrey,
        ),
        const Icon(
          Icons.location_on_outlined,
          color: PassageiroColors.primaryBlue,
          size: 18,
        ),
      ],
    );
  }
}

class _HorarioPartida extends StatelessWidget {
  final DateTime dataHora;

  const _HorarioPartida({required this.dataHora});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.schedule_outlined,
          color: PassageiroColors.primaryBlue,
          size: 16,
        ),
        const SizedBox(width: 4),
        Text(
          SemanaUtil.formatarHorario(dataHora),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: PassageiroColors.darkBlue,
          ),
        ),
      ],
    );
  }
}
