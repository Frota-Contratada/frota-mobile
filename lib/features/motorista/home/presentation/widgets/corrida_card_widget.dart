import 'package:flutter/material.dart';
import '../../../../../core/widgets/app_colors.dart';
import '../../../../../core/widgets/corrida_card_base_widget.dart';
import '../../domain/entities/corrida.dart';
import '../utils/semana_util.dart';

/// Card de corrida do motorista.
/// Usa o [CorridaCardBaseWidget] compartilhado como base para corridas normais,
/// e adiciona o layout especial "corrida próxima" com banner e botão "Iniciar corrida".
class CorridaCardWidget extends StatelessWidget {
  final Corrida corrida;
  final VoidCallback? onVerDetalhes;
  final VoidCallback? onIniciarCorrida;

  const CorridaCardWidget({
    super.key,
    required this.corrida,
    this.onVerDetalhes,
    this.onIniciarCorrida,
  });

  @override
  Widget build(BuildContext context) {
    final horario = SemanaUtil.formatarHorario(corrida.dataHoraPartida);

    if (corrida.ehProxima) {
      return _CorridaProximaCard(
        corrida: corrida,
        horario: horario,
        onVerDetalhes: onVerDetalhes,
        onIniciarCorrida: onIniciarCorrida,
      );
    }

    return CorridaCardBaseWidget(
      origem: corrida.origem,
      destino: corrida.destino,
      horarioPartida: horario,
      onVerDetalhes: onVerDetalhes,
    );
  }
}

class _CorridaProximaCard extends StatelessWidget {
  final Corrida corrida;
  final String horario;
  final VoidCallback? onVerDetalhes;
  final VoidCallback? onIniciarCorrida;

  const _CorridaProximaCard({
    required this.corrida,
    required this.horario,
    this.onVerDetalhes,
    this.onIniciarCorrida,
  });

  @override
  Widget build(BuildContext context) {
    final minutos = corrida.minutosRestantes ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD1D2D5)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Faltam $minutos minutos para a corrida!',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.white,
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Material(
                  color: AppColors.accentGreen,
                  borderRadius: BorderRadius.circular(15),
                  child: InkWell(
                    onTap: onIniciarCorrida,
                    borderRadius: BorderRadius.circular(15),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      child: Text(
                        'Iniciar corrida',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: AppColors.darkBlue,
                          letterSpacing: -0.12,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 0, 6, 6),
            child: CorridaCardBaseWidget(
              origem: corrida.origem,
              destino: corrida.destino,
              horarioPartida: horario,
              onVerDetalhes: onVerDetalhes,
            ),
          ),
        ],
      ),
    );
  }
}
