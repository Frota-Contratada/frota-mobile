import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/app_assets.dart';
import '../../../../../core/maps/map_point.dart';
import '../../../../../core/widgets/app_colors.dart';
import '../../../../../core/widgets/app_map_widget.dart';
import '../bloc/criar_solicitacao.bloc.dart';
import '../utils/solicitacao_formatters.dart';
import '../widgets/solicitacao_confirmacao_dialog.dart';
import '../widgets/solicitacao_modalidade_chip_widget.dart';
import '../widgets/solicitacao_primary_button_widget.dart';
import '../widgets/solicitacao_revisao_info_widget.dart';

class SolicitarViagemRevisaoPage extends StatelessWidget {
  final String origem;
  final String destino;
  final List<String> paradas;
  final String data;
  final String horario;
  final String motivo;
  final List<String> centrosCusto;
  final String veiculo;
  final List<String> acompanhantes;
  final String? cpfAcompanhante;
  final MapPoint? origemPoint;
  final List<MapPoint> paradaPoints;
  final MapPoint? destinoPoint;

  const SolicitarViagemRevisaoPage({
    super.key,
    required this.origem,
    required this.destino,
    this.paradas = const [],
    required this.data,
    required this.horario,
    required this.motivo,
    required this.centrosCusto,
    required this.veiculo,
    this.acompanhantes = const [],
    this.cpfAcompanhante,
    this.origemPoint,
    this.paradaPoints = const [],
    this.destinoPoint,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          SizedBox(
            height: 306,
            width: double.infinity,
            child: MapRoutePreview(
              originAddress: origem,
              destinationAddress: destino,
              origin: origemPoint,
              viaPoints: paradaPoints,
              destination: destinoPoint,
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              transform: Matrix4.translationValues(0, -19, 0),
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(25, 24, 25, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 16),
                    const SolicitacaoModalidadeChipWidget(modalidade: 'Táxi'),
                    const SizedBox(height: 12),
                    _buildRouteDetails(),
                    _buildInfoItem(
                      label: 'Data',
                      valores: [data],
                      iconAsset: AppAssets.iconData,
                    ),
                    _buildInfoItem(
                      label: 'Horário de partida',
                      valores: [horario],
                      iconAsset: AppAssets.iconHorario,
                    ),
                    BlocBuilder<CriarSolicitacaoBloc, CriarSolicitacaoState>(
                      builder: (context, state) => Column(
                        children: [
                          _buildInfoItem(
                            label: 'Horário de chegada',
                            valores: [_chegadaEstimada(state)],
                            iconAsset: AppAssets.iconHorario,
                          ),
                          _buildInfoItem(
                            label: 'Valor da corrida',
                            valores: [_valorEstimado(state)],
                            iconAsset: AppAssets.iconCusto,
                          ),
                        ],
                      ),
                    ),
                    _buildInfoItem(
                      label: 'Motivo da corrida',
                      valores: [motivo],
                      iconAsset: AppAssets.iconMotivo,
                    ),
                    _buildInfoItem(
                      label: 'Veículo',
                      valores: [veiculo],
                      iconAsset: AppAssets.iconVeiculo,
                    ),
                    _buildInfoItem(
                      label: centrosCusto.length == 1
                          ? 'Centro de custo'
                          : 'Centros de custo',
                      valores: centrosCusto.isNotEmpty
                          ? centrosCusto
                          : const ['Não informado'],
                      iconAsset: AppAssets.iconCusto,
                    ),
                    _buildInfoItem(
                      label: acompanhantes.length == 1
                          ? 'Acompanhante'
                          : 'Acompanhantes',
                      valores: _valoresAcompanhantes(),
                      iconAsset: AppAssets.iconFuncionario,
                    ),
                    const SizedBox(height: 26),
                    BlocConsumer<CriarSolicitacaoBloc, CriarSolicitacaoState>(
                      listener: _reagirAoEnvio,
                      builder: (context, state) =>
                          SolicitacaoPrimaryButtonWidget(
                            label: state.enviando
                                ? 'Enviando...'
                                : 'Enviar solicitação',
                            backgroundColor: AppColors.accentGreen,
                            foregroundColor: AppColors.darkBlue,
                            width: 175,
                            height: 45,
                            fontSize: 14,
                            onPressed: state.enviando
                                ? null
                                : () => _enviarSolicitacao(context),
                          ),
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

  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Image.asset(
            AppAssets.iconVoltar,
            width: 27,
            height: 27,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dados da viagem',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkBlue,
                ),
              ),
              SizedBox(height: 1),
              Text(
                'Revise as informações inseridas',
                style: TextStyle(fontSize: 11, color: AppColors.textGrey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRouteDetails() {
    final locations = <String>[origem, ...paradas, destino];
    return Column(
      children: [
        for (var index = 0; index < locations.length; index++) ...[
          _buildRouteLocation(
            label: index == 0
                ? 'Origem'
                : index == locations.length - 1
                ? 'Destino'
                : 'Parada $index',
            value: locations[index],
            isDestination: index == locations.length - 1,
          ),
          if (index < locations.length - 1) _buildConnector(),
        ],
      ],
    );
  }

  Widget _buildRouteLocation({
    required String label,
    required String value,
    required bool isDestination,
  }) {
    return SolicitacaoRevisaoInfoWidget(
      icon: isDestination
          ? Image.asset(
              AppAssets.iconDestinoCinza,
              width: 14,
              height: 16,
              fit: BoxFit.contain,
              color: AppColors.primaryBlue,
            )
          : SolicitacaoRevisaoInfoWidget.dot(),
      label: label,
      valores: [value],
      maxLines: 2,
    );
  }

  Widget _buildConnector() => SolicitacaoRevisaoInfoWidget.connector();

  List<String> _valoresAcompanhantes() {
    if (acompanhantes.isNotEmpty) return acompanhantes;
    if (cpfAcompanhante?.isNotEmpty == true) return [cpfAcompanhante!];
    return const ['Não informado'];
  }

  Widget _buildInfoItem({
    required String label,
    required List<String> valores,
    required String iconAsset,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        top: SolicitacaoRevisaoInfoWidget.itemSpacing,
      ),
      child: SolicitacaoRevisaoInfoWidget(
        icon: Image.asset(
          iconAsset,
          width: 15,
          height: 15,
          fit: BoxFit.contain,
          color: AppColors.primaryBlue,
        ),
        label: label,
        valores: valores,
      ),
    );
  }

  void _enviarSolicitacao(BuildContext context) {
    context.read<CriarSolicitacaoBloc>().add(
      SolicitacaoEnviada(
        RascunhoSolicitacao(
          data: data,
          horario: horario,
          motivoNome: motivo,
          veiculoNome: veiculo,
          centrosCusto: centrosCusto,
          cpfsAcompanhantes: acompanhantes,
          origemDescricao: origem,
          origemPoint: origemPoint,
          destinoDescricao: destino,
          destinoPoint: destinoPoint,
          paradasDescricao: paradas,
          paradaPoints: paradaPoints,
        ),
      ),
    );
  }

  void _reagirAoEnvio(BuildContext context, CriarSolicitacaoState state) {
    if (state.erro != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(state.erro!)));
      return;
    }

    final criada = state.criada;

    if (criada == null) return;

    final chegada = criada.dataChegadaEstimada;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => SolicitacaoConfirmacaoDialog(
        titulo: 'Sua viagem foi solicitada!',
        mensagem:
            'Valor estimado de ${_moeda(criada.valorEstimado)}'
            '${chegada == null ? '' : ' com chegada prevista às ${formatarHorarioSolicitacao(chegada)}'}.'
            ' Agora é só esperar os responsáveis aprovarem sua solicitação!',
        submensagem:
            'Você pode acompanhar o status da sua solicitação através da aba ‘solicitações’ aqui no aplicativo',
        onFechar: () {
          context.read<CriarSolicitacaoBloc>().add(
            const SolicitacaoRascunhoDescartado(),
          );
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
      ),
    );
  }

  String _chegadaEstimada(CriarSolicitacaoState state) {
    if (state.simulando) return 'calculando...';

    final simulacao = state.simulacao;

    return simulacao == null
        ? 'não disponível'
        : formatarHorarioSolicitacao(simulacao.dataChegadaEstimada);
  }

  String _valorEstimado(CriarSolicitacaoState state) {
    if (state.simulando) return 'calculando...';

    final simulacao = state.simulacao;

    return simulacao == null
        ? 'não disponível'
        : _moeda(simulacao.valorEstimado);
  }

  String _moeda(double valor) =>
      'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
}
