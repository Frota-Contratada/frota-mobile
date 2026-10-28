import 'package:flutter/material.dart';
import '../../../../../config/app_assets.dart';
import '../../../../../core/responsive/responsive.dart';
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
  final VoidCallback? onRecusarCorrida;
  final bool isIniciando;
  final bool isRecusando;

  const CorridaDetalheConteudoWidget({
    super.key,
    required this.corrida,
    required this.onVoltar,
    this.onIniciarCorrida,
    this.onRecusarCorrida,
    this.isIniciando = false,
    this.isRecusando = false,
  });

  @override
  Widget build(BuildContext context) {
    final layout = AppLayout.of(context);

    if (layout.usaPainelLateral) {
      return Column(
        children: [
          CorridaHeaderWidget(onVoltar: onVoltar),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(25, 27, 12, 24),
                    child: CorridaMapaWidget(
                      origem: corrida.origem,
                      destino: corrida.destino,
                      altura: null,
                    ),
                  ),
                ),
                SizedBox(
                  width: layout.larguraPainelLateral,
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(12, 27, 25, 24),
                          child: _buildInformacoes(),
                        ),
                      ),
                      if (corrida.ehProxima) ...[
                        ..._buildAcoes(),
                        const SizedBox(height: 24),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        ConteudoResponsivo(child: CorridaHeaderWidget(onVoltar: onVoltar)),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(25, 27, 25, 24),
            child: ConteudoResponsivo(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CorridaMapaWidget(
                    origem: corrida.origem,
                    destino: corrida.destino,
                    altura: layout.alturaProporcional(198),
                  ),
                  const SizedBox(height: 30),
                  _buildInformacoes(),
                ],
              ),
            ),
          ),
        ),
        if (corrida.ehProxima) ...[
          ConteudoResponsivo(
            larguraMaxima: AppLayout.larguraFormulario,
            child: Column(children: _buildAcoes()),
          ),
          const SizedBox(height: 57),
        ],
      ],
    );
  }

  Widget _buildInformacoes() {
    final valorFormatado = CorridaFormatUtil.formatarValor(
      corrida.valorEstimado,
    );

    final dataFormatada =
        '${corrida.dataHoraPartida.day.toString().padLeft(2, '0')}/'
        '${corrida.dataHoraPartida.month.toString().padLeft(2, '0')}/'
        '${corrida.dataHoraPartida.year}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CorridaTrajetoWidget(origem: corrida.origem, destino: corrida.destino),
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
    );
  }

  List<Widget> _buildAcoes() {
    return [
      CorridaIniciarButtonWidget(
        onPressed: isRecusando ? null : onIniciarCorrida,
        isLoading: isIniciando,
      ),
      const SizedBox(height: 12),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 83),
        child: SizedBox(
          height: 48,
          width: double.infinity,
          child: OutlinedButton(
            onPressed: isIniciando || isRecusando ? null : onRecusarCorrida,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red.shade700,
              side: BorderSide(color: Colors.red.shade700),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: isRecusando
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Recusar corrida'),
          ),
        ),
      ),
    ];
  }
}
