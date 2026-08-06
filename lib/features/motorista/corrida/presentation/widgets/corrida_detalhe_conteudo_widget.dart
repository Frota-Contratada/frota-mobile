import 'package:flutter/material.dart';
import '../../../../../config/app_assets.dart';
import '../../../../../core/widgets/app_colors.dart';
import '../../../home/presentation/utils/semana_util.dart';
import '../utils/corrida_format_util.dart';
import '../../domain/entities/corrida_detalhe.dart';
import 'corrida_header_widget.dart';
import 'corrida_info_item_widget.dart';
import 'corrida_iniciar_button_widget.dart';
import 'corrida_mapa_widget.dart';
import 'corrida_trajeto_widget.dart';

class CorridaDetalheConteudoWidget extends StatelessWidget {
  final CorridaDetalhe corrida;
  final VoidCallback onVoltar;
  final VoidCallback? onIniciarCorrida;
  final bool isIniciando;

  const CorridaDetalheConteudoWidget({
    super.key,
    required this.corrida,
    required this.onVoltar,
    this.onIniciarCorrida,
    this.isIniciando = false,
  });

  @override
  Widget build(BuildContext context) {
    final valorFormatado = CorridaFormatUtil.formatarValor(corrida.valorEstimado);

    final dataFormatada =
        '${corrida.dataHoraPartida.day.toString().padLeft(2, '0')}/'
        '${corrida.dataHoraPartida.month.toString().padLeft(2, '0')}/'
        '${corrida.dataHoraPartida.year}';

    return Column(
      children: [
        CorridaHeaderWidget(onVoltar: onVoltar),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(25, 27, 25, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const CorridaMapaWidget(),
                const SizedBox(height: 30),
                CorridaTrajetoWidget(
                  origem: corrida.origem,
                  destino: corrida.destino,
                ),
                const SizedBox(height: 20),
                CorridaInfoItemWidget(
                  icon: Image.asset(
                    AppAssets.iconData,
                    width: 12,
                    height: 14,
                    fit: BoxFit.contain,
                    color: AppColors.primaryBlue,
                  ),
                  label: 'Data',
                  valor: dataFormatada,
                ),
                const SizedBox(height: 20),
                CorridaInfoItemWidget(
                  icon: Image.asset(
                    AppAssets.iconHorario,
                    width: 12,
                    height: 12,
                    fit: BoxFit.contain,
                    color: AppColors.primaryBlue,
                  ),
                  label: 'Horário de partida',
                  valor: SemanaUtil.formatarHorario(corrida.dataHoraPartida),
                ),
                const SizedBox(height: 20),
                CorridaInfoItemWidget(
                  icon: Image.asset(
                    AppAssets.iconFuncionario,
                    width: 12,
                    height: 13,
                    fit: BoxFit.contain,
                    color: AppColors.primaryBlue,
                  ),
                  label: 'Nome do passageiro',
                  valor: corrida.nomePassageiro,
                ),
                const SizedBox(height: 20),
                CorridaInfoItemWidget(
                  icon: Image.asset(
                    AppAssets.iconCusto,
                    width: 12,
                    height: 10,
                    fit: BoxFit.contain,
                    color: AppColors.primaryBlue,
                  ),
                  label: 'Valor estimado da corrida',
                  valor: valorFormatado,
                ),
              ],
            ),
          ),
        ),
        if (corrida.ehProxima) ...[
          CorridaIniciarButtonWidget(
            onPressed: onIniciarCorrida,
            isLoading: isIniciando,
          ),
          const SizedBox(height: 57),
        ],
      ],
    );
  }
}
