import 'package:flutter/material.dart';
import '../../domain/entities/corrida.dart';
import '../utils/semana_util.dart';
import 'viagens_colors.dart';

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

    return _CorridaPadraoCard(
      corrida: corrida,
      onVerDetalhes: onVerDetalhes,
    );
  }
}

class _CorridaPadraoCard extends StatelessWidget {
  final Corrida corrida;
  final VoidCallback? onVerDetalhes;

  const _CorridaPadraoCard({
    required this.corrida,
    this.onVerDetalhes,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ViagensColors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: ViagensColors.borderGrey),
      ),
      child: _CorridaConteudo(
        corrida: corrida,
        onVerDetalhes: onVerDetalhes,
      ),
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
        color: ViagensColors.primaryBlue,
        borderRadius: BorderRadius.circular(15),
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
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: ViagensColors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Material(
                  color: ViagensColors.accentGreen,
                  borderRadius: BorderRadius.circular(15),
                  child: InkWell(
                    onTap: onIniciarCorrida,
                    borderRadius: BorderRadius.circular(15),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: Text(
                        'Iniciar corrida',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1E1E1E),
                          letterSpacing: -0.12,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              color: ViagensColors.white,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
            ),
            child: _CorridaConteudo(
              corrida: corrida,
              onVerDetalhes: onVerDetalhes,
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

  const _CorridaConteudo({
    required this.corrida,
    this.onVerDetalhes,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _RotaIndicador(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _EnderecoLinha(
                      label: 'Origem',
                      endereco: corrida.origem,
                    ),
                    const SizedBox(height: 14),
                    _EnderecoLinha(
                      label: 'Destino',
                      endereco: corrida.destino,
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
            height: 30,
            child: ElevatedButton(
              onPressed: onVerDetalhes,
              style: ElevatedButton.styleFrom(
                backgroundColor: ViagensColors.buttonBlue,
                foregroundColor: ViagensColors.white,
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
          decoration: const BoxDecoration(
            color: ViagensColors.buttonBlue,
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: 2,
          height: 35,
          color: ViagensColors.buttonBlue.withValues(alpha: 0.5),
        ),
        const Icon(
          Icons.location_on_outlined,
          color: ViagensColors.buttonBlue,
          size: 18,
        ),
      ],
    );
  }
}

class _EnderecoLinha extends StatelessWidget {
  final String label;
  final String endereco;

  const _EnderecoLinha({
    required this.label,
    required this.endereco,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: ViagensColors.textGrey,
            letterSpacing: -0.12,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          endereco,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: ViagensColors.darkBlue,
          ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Icon(
          Icons.schedule_outlined,
          color: ViagensColors.buttonBlue,
          size: 18,
        ),
        const SizedBox(height: 2),
        const Text(
          'Partida',
          style: TextStyle(
            fontSize: 11,
            color: ViagensColors.textGrey,
            letterSpacing: -0.12,
          ),
        ),
        Text(
          SemanaUtil.formatarHorario(dataHora),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: ViagensColors.darkBlue,
          ),
        ),
      ],
    );
  }
}
