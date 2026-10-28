import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/app_assets.dart';
import '../../../../../core/maps/map_point.dart';
import '../../../../../core/widgets/app_colors.dart';
import '../../../../../core/widgets/app_map_widget.dart';
import '../../domain/entities/catalogos_solicitacao.dart';
import '../bloc/criar_solicitacao.bloc.dart';
import '../utils/solicitacao_formatters.dart';
import '../widgets/solicitacao_confirmacao_dialog.dart';
import '../widgets/solicitacao_erro_simulacao_widget.dart';
import '../widgets/solicitacao_layout_widget.dart';
import '../widgets/solicitacao_modalidade_chip_widget.dart';
import '../widgets/solicitacao_primary_button_widget.dart';
import '../widgets/solicitacao_revisao_info_widget.dart';

class SolicitarObjetoRevisaoPage extends StatelessWidget {
  final String origem;
  final String destino;
  final String data;
  final String horario;
  final List<String> centrosCusto;
  final String objeto;
  final String veiculo;
  final MapPoint? origemPoint;
  final MapPoint? destinoPoint;

  const SolicitarObjetoRevisaoPage({
    super.key,
    required this.origem,
    required this.destino,
    required this.data,
    required this.horario,
    required this.centrosCusto,
    required this.objeto,
    required this.veiculo,
    this.origemPoint,
    this.destinoPoint,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SolicitacaoLayoutWidget(
        alturaMapa: 306,
        sobreposicao: 19,
        mapa: MapRoutePreview(
          originAddress: origem,
          destinationAddress: destino,
          origin: origemPoint,
          destination: destinoPoint,
        ),
        children: [
          _buildHeader(context),
          const SizedBox(height: 16),
          const SolicitacaoModalidadeChipWidget(modalidade: 'Objetos'),
          const SizedBox(height: 12),
          _buildErroSimulacao(),
          _buildSectionTitle('1.', 'Trajeto'),
          const SizedBox(height: 8),
          _buildRouteValue(
            value: origem,
            iconAsset: null,
            isDestination: false,
          ),
          SolicitacaoRevisaoInfoWidget.connector(),
          _buildRouteValue(
            value: destino,
            iconAsset: AppAssets.iconDestinoCinza,
            isDestination: true,
          ),
          const SizedBox(height: 16),
          _buildSectionTitle('2.', 'Data e horário'),
          const SizedBox(height: 8),
          _buildSectionValue(
            iconAsset: AppAssets.iconData,
            valores: ['Dia $data às $horario'],
          ),
          const SizedBox(height: 16),
          _buildSectionTitle('3.', 'Custos'),
          const SizedBox(height: 8),
          _buildSectionValue(
            iconAsset: AppAssets.iconCusto,
            valores: _descricoesCentrosCusto(context),
          ),
          const SizedBox(height: 16),
          _buildSectionTitle('4.', 'Objeto'),
          const SizedBox(height: 8),
          _buildSectionValue(
            iconAsset: AppAssets.iconTransporteItens,
            valores: [objeto],
          ),
          const SizedBox(height: 16),
          _buildSectionTitle('5.', 'Meio de transporte'),
          const SizedBox(height: 8),
          _buildSectionValue(
            iconAsset: AppAssets.iconVeiculo,
            valores: [veiculo],
          ),
          const SizedBox(height: 16),
          _buildSectionTitle('6.', 'Estimativa'),
          const SizedBox(height: 8),
          BlocBuilder<CriarSolicitacaoBloc, CriarSolicitacaoState>(
            builder: (context, state) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionValue(
                  iconAsset: AppAssets.iconCusto,
                  valores: [_valorEstimado(state)],
                ),
                const SizedBox(height: 8),
                _buildSectionValue(
                  iconAsset: AppAssets.iconHorario,
                  valores: ['Chegada prevista: ${_chegadaEstimada(state)}'],
                ),
              ],
            ),
          ),
          const SizedBox(height: 26),
          BlocConsumer<CriarSolicitacaoBloc, CriarSolicitacaoState>(
            listenWhen: (previous, current) =>
                (previous.criada == null && current.criada != null) ||
                (previous.enviando &&
                    !current.enviando &&
                    current.erro != null),
            listener: _reagirAoEnvio,
            builder: (context, state) => SolicitacaoPrimaryButtonWidget(
              label: state.enviando ? 'Enviando...' : 'Enviar solicitação',
              backgroundColor: AppColors.accentGreen,
              foregroundColor: AppColors.darkBlue,
              width: 194,
              height: 48,
              fontSize: 14,
              onPressed: state.enviando
                  ? null
                  : () => _enviarSolicitacao(context),
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
                'Dados do transporte',
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

  Widget _buildErroSimulacao() {
    return BlocBuilder<CriarSolicitacaoBloc, CriarSolicitacaoState>(
      buildWhen: (previous, current) =>
          previous.erroSimulacao != current.erroSimulacao,
      builder: (context, state) {
        final erro = state.erroSimulacao;
        if (erro == null) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: SolicitacaoErroSimulacaoWidget(
            mensagem: erro,
            onTentarNovamente: () {
              final bloc = context.read<CriarSolicitacaoBloc>();
              bloc.add(SimulacaoSolicitada(bloc.state.rascunho.toRascunho()));
            },
          ),
        );
      },
    );
  }

  List<String> _descricoesCentrosCusto(BuildContext context) {
    if (centrosCusto.isEmpty) return const ['Não informado'];

    final catalogos = context
        .select<CriarSolicitacaoBloc, CatalogosSolicitacao>(
          (bloc) => bloc.state.catalogos,
        );

    return centrosCusto.map(catalogos.descricaoCentroCusto).toList();
  }

  Widget _buildSectionTitle(String number, String label) {
    return Text(
      '$number $label',
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textGrey,
      ),
    );
  }

  Widget _buildRouteValue({
    required String value,
    required String? iconAsset,
    required bool isDestination,
  }) {
    return SolicitacaoRevisaoInfoWidget(
      icon: isDestination
          ? Image.asset(
              iconAsset!,
              width: 14,
              height: 16,
              fit: BoxFit.contain,
              color: AppColors.primaryBlue,
            )
          : SolicitacaoRevisaoInfoWidget.dot(),
      valores: [value],
      maxLines: 2,
    );
  }

  Widget _buildSectionValue({
    required String iconAsset,
    required List<String> valores,
  }) {
    return SolicitacaoRevisaoInfoWidget(
      icon: Image.asset(
        iconAsset,
        width: 15,
        height: 15,
        fit: BoxFit.contain,
        color: AppColors.primaryBlue,
      ),
      valores: valores,
    );
  }

  void _enviarSolicitacao(BuildContext context) {
    context.read<CriarSolicitacaoBloc>().add(
      SolicitacaoEnviada(
        RascunhoSolicitacao(
          data: data,
          horario: horario,
          motivoNome: objeto,
          veiculoNome: veiculo,
          centrosCusto: centrosCusto,
          origemDescricao: origem,
          origemPoint: origemPoint,
          destinoDescricao: destino,
          destinoPoint: destinoPoint,
          objeto: true,
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
        titulo: 'Seu transporte foi solicitado!',
        mensagem:
            'Partida às ${formatarHorarioSolicitacao(criada.dataCorrida)}'
            '${chegada == null ? '' : ', com chegada prevista às ${formatarHorarioSolicitacao(chegada)}'}.'
            ' Valor estimado de ${_moeda(criada.valorEstimado)}.'
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
        ? 'Valor não disponível'
        : 'Valor estimado: ${_moeda(simulacao.valorEstimado)}';
  }

  String _moeda(double valor) =>
      'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
}
