import 'package:flutter/material.dart';
import '../../../../../core/widgets/corrida_card_base_widget.dart';
import '../../domain/entities/viagem.dart';
import '../utils/semana_util.dart';

/// Card de viagem do passageiro.
/// Usa o [CorridaCardBaseWidget] compartilhado, com suporte ao estado "em andamento".
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
    final horario = SemanaUtil.formatarHorario(viagem.dataHoraPartida);

    return CorridaCardBaseWidget(
      origem: viagem.origem,
      destino: viagem.destino,
      horarioPartida: horario,
      onVerDetalhes: onVerDetalhes,
      emAndamento: viagem.emAndamento,
      onViagemEmAndamento: onViagemEmAndamento,
    );
  }
}
