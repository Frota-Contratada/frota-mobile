import 'package:flutter/material.dart';
import '../../domain/entities/corrida.dart';
import '../utils/semana_util.dart';
import 'home_colors.dart';

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
    if (corrida.ehProxima) {
      return _CorridaProximaCard(
        corrida: corrida,
        onVerDetalhes: onVerDetalhes,
        onIniciarCorrida: onIniciarCorrida,
      );
    }

    return _CorridaPadraoCard(corrida: corrida, onVerDetalhes: onVerDetalhes);
  }
}

class _CorridaPadraoCard extends StatelessWidget {
  final Corrida corrida;
  final VoidCallback? onVerDetalhes;

  const _CorridaPadraoCard({required this.corrida, this.onVerDetalhes});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: HomeColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: HomeColors.borderGrey),
      ),
      child: _CorridaConteudo(corrida: corrida, onVerDetalhes: onVerDetalhes),
    );
  }
}

class _CorridaProximaCard extends StatelessWidget {
  final Corrida corrida;
  final VoidCallback? onVerDetalhes;
  final VoidCallback? onIniciarCorrida;

  const _CorridaProximaCard({
    required this.corrida,
    this.onVerDetalhes,
    this.onIniciarCorrida,
  });

  @override
  Widget build(BuildContext context) {
    final minutos = corrida.minutosRestantes ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: HomeColors.primaryBlue,
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
                      color: HomeColors.white,
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Material(
                  color: HomeColors.accentGreen,
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
                          color: HomeColors.darkBlue,
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
            child: Container(
              decoration: BoxDecoration(
                color: HomeColors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: HomeColors.borderGrey),
              ),
              child: _CorridaConteudo(
                corrida: corrida,
                onVerDetalhes: onVerDetalhes,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CorridaConteudo extends StatelessWidget {
  final Corrida corrida;
  final VoidCallback? onVerDetalhes;

  const _CorridaConteudo({required this.corrida, this.onVerDetalhes});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(width: 26),
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
                      corrida.origem,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: HomeColors.darkBlue,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const _LabelText('Destino'),
                    const SizedBox(height: 4),
                    Text(
                      corrida.destino,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: HomeColors.darkBlue,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _HorarioPartida(dataHora: corrida.dataHoraPartida),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 36,
            child: ElevatedButton(
              onPressed: onVerDetalhes,
              style: ElevatedButton.styleFrom(
                backgroundColor: HomeColors.buttonBlue,
                foregroundColor: HomeColors.white,
                disabledBackgroundColor: HomeColors.buttonBlue,
                disabledForegroundColor: HomeColors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(150),
                ),
                padding: EdgeInsets.zero,
                minimumSize: const Size(double.infinity, 36),
              ),
              child: const Text(
                'ver detalhes',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
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
        fontSize: 11,
        color: HomeColors.textGrey,
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
            color: HomeColors.primaryBlue,
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: 2,
          height: 36,
          margin: const EdgeInsets.symmetric(vertical: 2),
          color: HomeColors.borderGrey,
        ),
        const Icon(
          Icons.location_on_outlined,
          color: HomeColors.primaryBlue,
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
          color: HomeColors.primaryBlue,
          size: 18,
        ),
        const SizedBox(width: 4),
        Text(
          SemanaUtil.formatarHorario(dataHora),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: HomeColors.darkBlue,
          ),
        ),
      ],
    );
  }
}
