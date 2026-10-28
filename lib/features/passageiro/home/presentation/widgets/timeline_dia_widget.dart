import 'package:flutter/material.dart';
import '../../../../../core/widgets/timeline_dia_widget.dart' as shared;
import '../../domain/entities/viagem.dart';
import '../utils/semana_util.dart';
import 'viagem_card_widget.dart';

/// Timeline de dia do passageiro.
/// Delegação para o widget compartilhado [shared.TimelineDiaWidget],
/// construindo os cards específicos de viagem do passageiro.
class TimelineDiaWidget extends StatelessWidget {
  final DateTime dia;
  final List<Viagem> viagens;
  final bool isUltimoDia;
  final void Function(Viagem viagem)? onVerDetalhes;
  final void Function(Viagem viagem)? onViagemEmAndamento;

  const TimelineDiaWidget({
    super.key,
    required this.dia,
    required this.viagens,
    this.isUltimoDia = false,
    this.onVerDetalhes,
    this.onViagemEmAndamento,
  });

  @override
  Widget build(BuildContext context) {
    final cards = viagens.map((viagem) {
      return ViagemCardWidget(
        viagem: viagem,
        onVerDetalhes: onVerDetalhes == null
            ? null
            : () => onVerDetalhes!(viagem),
        onViagemEmAndamento: onViagemEmAndamento == null
            ? null
            : () => onViagemEmAndamento!(viagem),
      );
    }).toList();

    return shared.TimelineDiaWidget(
      labelDia: SemanaUtil.formatarDiaViagem(dia),
      cards: cards,
      isUltimoDia: isUltimoDia,
    );
  }
}
