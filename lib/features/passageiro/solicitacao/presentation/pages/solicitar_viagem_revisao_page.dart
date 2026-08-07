import 'package:flutter/material.dart';
import '../../../../../config/app_assets.dart';
import '../../../../../core/maps/map_point.dart';
import '../../../../../core/widgets/app_colors.dart';
import '../../../../../core/widgets/app_map_widget.dart';
import '../widgets/solicitacao_modalidade_chip_widget.dart';
import '../widgets/solicitacao_primary_button_widget.dart';
import '../../presentation/widgets/solicitacao_confirmacao_dialog.dart';

/// Página de revisão da solicitação de viagem - dados resumidos antes de enviar.
class SolicitarViagemRevisaoPage extends StatelessWidget {
  final String origem;
  final String destino;
  final String data;
  final String horario;
  final String motivo;
  final String centroCusto;
  final String veiculo;
  final MapPoint? origemPoint;
  final MapPoint? destinoPoint;

  const SolicitarViagemRevisaoPage({
    super.key,
    required this.origem,
    required this.destino,
    required this.data,
    required this.horario,
    required this.motivo,
    required this.centroCusto,
    required this.veiculo,
    this.origemPoint,
    this.destinoPoint,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          SizedBox(
            height: 306,
            width: double.infinity,
            child: MapRoutePreview(
              originAddress: origem,
              destinationAddress: destino,
              origin: origemPoint,
              destination: destinoPoint,
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              transform: Matrix4.translationValues(0, -19, 0),
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(25, 25, 25, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Image.asset(
                            AppAssets.iconVoltar,
                            width: 30,
                            height: 30,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(width: 15),
                        const Text(
                          'Dados da viagem',
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w500,
                            color: AppColors.darkBlue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Padding(
                      padding: EdgeInsets.only(left: 45),
                      child: Text(
                        'Revise as informações inseridas',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textMediumGrey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const SolicitacaoModalidadeChipWidget(modalidade: 'Táxi'),
                    const SizedBox(height: 24),

                    // Trajeto
                    _buildInfoItemAsset(
                      label: 'Origem',
                      valor: origem,
                      iconWidget: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: AppColors.textGrey,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    _buildLinhaConectora(),
                    _buildInfoItemAsset(
                      label: 'Destino',
                      valor: destino,
                      iconWidget: Image.asset(
                        AppAssets.iconDestino,
                        width: 12,
                        height: 15,
                        fit: BoxFit.contain,
                        color: AppColors.textGrey,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Data
                    _buildInfoItemAsset(
                      label: 'Data',
                      valor: data,
                      iconWidget: Image.asset(
                        AppAssets.iconData,
                        width: 12,
                        height: 14,
                        fit: BoxFit.contain,
                        color: AppColors.textGrey,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Horário partida
                    _buildInfoItemAsset(
                      label: 'Horário de partida',
                      valor: horario,
                      iconWidget: Image.asset(
                        AppAssets.iconHorario,
                        width: 12,
                        height: 12,
                        fit: BoxFit.contain,
                        color: AppColors.textGrey,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Horário estimado de chegada
                    _buildInfoItemAsset(
                      label: 'Horário de chegada',
                      valor: '20h00',
                      iconWidget: Image.asset(
                        AppAssets.iconHorario,
                        width: 12,
                        height: 12,
                        fit: BoxFit.contain,
                        color: AppColors.textGrey,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Valor estimado
                    _buildInfoItemAsset(
                      label: 'Valor da corrida',
                      valor: 'R\$68,90',
                      iconWidget: Image.asset(
                        AppAssets.iconCusto,
                        width: 12,
                        height: 10,
                        fit: BoxFit.contain,
                        color: AppColors.textGrey,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Centro de custos
                    _buildInfoItemAsset(
                      label: 'Centro de custos',
                      valor: centroCusto,
                      iconWidget: Image.asset(
                        AppAssets.iconCusto,
                        width: 12,
                        height: 10,
                        fit: BoxFit.contain,
                        color: AppColors.textGrey,
                      ),
                    ),
                    const SizedBox(height: 40),

                    SolicitacaoPrimaryButtonWidget(
                      label: 'Enviar solicitação',
                      onPressed: () => _enviarSolicitacao(context),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItemAsset({
    required String label,
    required String valor,
    required Widget iconWidget,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: iconWidget,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textGrey,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                valor,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColors.darkBlue,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLinhaConectora() {
    return Padding(
      padding: const EdgeInsets.only(left: 5),
      child: Container(
        width: 2,
        height: 20,
        margin: const EdgeInsets.symmetric(vertical: 2),
        color: AppColors.borderGrey,
      ),
    );
  }

  void _enviarSolicitacao(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => SolicitacaoConfirmacaoDialog(
        titulo: 'Sua viagem foi solicitada!',
        mensagem: 'Agora é só esperar os responsáveis aprovarem sua solicitação!',
        submensagem:
            'Você pode acompanhar o status da sua solicitação através da aba \'solicitações\' aqui no aplicativo',
        onFechar: () {
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
      ),
    );
  }
}
