import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../config/app_assets.dart';
import '../../../../../core/widgets/app_colors.dart';
import '../../../../../core/widgets/app_map_widget.dart';
import '../../../../../core/widgets/empty_state_widget.dart';
import '../../../../../injection_container/injection_container.dart';
import '../../../solicitacao/presentation/utils/solicitacao_formatters.dart';
import '../../domain/entities/motivo.dart';
import '../../domain/entities/solicitacao.dart';
import '../bloc/detalhe_solicitacao.bloc.dart';
import '../widgets/solicitacao_status.dart';

class DetalheSolicitacaoPage extends StatelessWidget {
  final int? solicitacaoId;

  const DetalheSolicitacaoPage({super.key, required this.solicitacaoId});

  @override
  Widget build(BuildContext context) {
    final id = solicitacaoId;

    if (id == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              _Header(),
              Expanded(
                child: Center(
                  child: EmptyStateWidget(
                    icon: Icons.info_outline_rounded,
                    mensagem: 'Detalhes indisponíveis',
                    submensagem:
                        'Esta solicitação não foi identificada. Abra pela aba de solicitações.',
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return BlocProvider(
      create: (_) =>
          sl<DetalheSolicitacaoBloc>()..add(DetalheSolicitacaoCarregado(id)),
      child: const _DetalheSolicitacaoView(),
    );
  }
}

class _DetalheSolicitacaoView extends StatelessWidget {
  const _DetalheSolicitacaoView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocConsumer<DetalheSolicitacaoBloc, DetalheSolicitacaoState>(
          listenWhen: (anterior, atual) =>
              atual is DetalheSolicitacaoCarregada && atual.cancelada,
          listener: (context, state) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(content: Text('Solicitação cancelada.')),
              );
          },
          builder: (context, state) {
            if (state is DetalheSolicitacaoLoading ||
                state is DetalheSolicitacaoInitial) {
              return const Column(
                children: [
                  _Header(),
                  Expanded(child: Center(child: CircularProgressIndicator())),
                ],
              );
            }

            if (state is DetalheSolicitacaoErro) {
              return Column(
                children: [
                  const _Header(),
                  Expanded(
                    child: Center(
                      child: EmptyStateWidget(
                        icon: Icons.cloud_off_rounded,
                        mensagem: 'Não foi possível carregar a solicitação',
                        submensagem: state.mensagem,
                      ),
                    ),
                  ),
                ],
              );
            }

            final carregada = state as DetalheSolicitacaoCarregada;

            return _Conteudo(state: carregada);
          },
        ),
      ),
    );
  }
}

class _Conteudo extends StatelessWidget {
  final DetalheSolicitacaoCarregada state;

  const _Conteudo({required this.state});

  Solicitacao get solicitacao => state.solicitacao;
  bool get corridaRealizada => solicitacao.corrida?.dataFim != null;

  @override
  Widget build(BuildContext context) {
    final status = SolicitacaoStatus.deDominio(solicitacao.status);
    final corrida = solicitacao.corrida;

    final horarioChegada = corridaRealizada
        ? formatarHorarioSolicitacao(corrida!.dataFim!)
        : (solicitacao.dataChegadaEstimada == null
              ? null
              : formatarHorarioSolicitacao(solicitacao.dataChegadaEstimada!));

    final valor = corridaRealizada
        ? _formatarMoeda(corrida!.valorFinal)
        : _formatarMoeda(solicitacao.valorEstimado);

    return Column(
      children: [
        const _Header(),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: SizedBox(
                    height: 198,
                    width: double.infinity,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: MapRoutePreview(
                        originAddress: solicitacao.origem.descricao,
                        destinationAddress: solicitacao.destino.descricao,
                        origin: solicitacao.origem.ponto,
                        destination: solicitacao.destino.ponto,
                        viaPoints: solicitacao.paradas
                            .map((parada) => parada.ponto)
                            .toList(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!corridaRealizada) ...[
                        _StatusBadge(status: status),
                        const SizedBox(height: 16),
                      ],

                      if (solicitacao.motivoReprovacao != null) ...[
                        _BlocoMotivoRecusa(
                          motivo: solicitacao.motivoReprovacao!,
                        ),
                      ],

                      if (solicitacao.motivoCancelamento != null) ...[
                        _BlocoMotivoRecusa(
                          titulo: 'Motivo do cancelamento',
                          motivo: solicitacao.motivoCancelamento!,
                        ),
                      ],

                      _InfoRow(
                        iconWidget: Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryBlue,
                            shape: BoxShape.circle,
                          ),
                        ),
                        label: 'Origem',
                        valor: solicitacao.origem.descricao,
                      ),
                      const _LinhaConectora(),

                      ...solicitacao.paradas.map(
                        (parada) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _InfoRow(
                              iconWidget: const Icon(
                                Icons.adjust_rounded,
                                size: 12,
                                color: AppColors.primaryBlue,
                              ),
                              label: 'Parada',
                              valor: parada.descricao,
                            ),
                            const _LinhaConectora(),
                          ],
                        ),
                      ),

                      _InfoRow(
                        iconWidget: Image.asset(
                          AppAssets.iconDestino,
                          width: 12,
                          height: 15,
                          fit: BoxFit.contain,
                          color: AppColors.primaryBlue,
                        ),
                        label: 'Destino',
                        valor: solicitacao.destino.descricao,
                      ),
                      const SizedBox(height: 20),

                      _InfoRow(
                        iconWidget: Image.asset(
                          AppAssets.iconData,
                          width: 12,
                          height: 14,
                          fit: BoxFit.contain,
                          color: AppColors.primaryBlue,
                        ),
                        label: 'Data',
                        valor: formatarDataSolicitacao(solicitacao.dataCorrida),
                      ),
                      const SizedBox(height: 20),

                      _InfoRow(
                        iconWidget: Image.asset(
                          AppAssets.iconHorario,
                          width: 12,
                          height: 12,
                          fit: BoxFit.contain,
                          color: AppColors.primaryBlue,
                        ),
                        label: 'Horário de partida',
                        valor: formatarHorarioSolicitacao(
                          solicitacao.dataCorrida,
                        ),
                      ),
                      const SizedBox(height: 20),

                      if (horarioChegada != null) ...[
                        _InfoRow(
                          iconWidget: Image.asset(
                            AppAssets.iconHorario,
                            width: 12,
                            height: 12,
                            fit: BoxFit.contain,
                            color: AppColors.primaryBlue,
                          ),
                          label: corridaRealizada
                              ? 'Horário de chegada'
                              : 'Horário estimado de chegada',
                          valor: horarioChegada,
                        ),
                        const SizedBox(height: 20),
                      ],

                      _InfoRow(
                        iconWidget: Image.asset(
                          AppAssets.iconCusto,
                          width: 12,
                          height: 10,
                          fit: BoxFit.contain,
                          color: AppColors.primaryBlue,
                        ),
                        label: corridaRealizada
                            ? 'Valor da corrida'
                            : 'Valor estimado da corrida',
                        valor: valor,
                      ),
                      const SizedBox(height: 20),

                      if (corrida?.motoristaNome != null) ...[
                        _InfoRow(
                          iconWidget: Image.asset(
                            AppAssets.iconFuncionario,
                            width: 12,
                            height: 13,
                            fit: BoxFit.contain,
                            color: AppColors.primaryBlue,
                          ),
                          label: 'Nome do motorista',
                          valor: corrida!.motoristaNome!,
                        ),
                        const SizedBox(height: 20),
                      ],

                      if (corrida != null &&
                          corrida.placaVeiculo.isNotEmpty) ...[
                        _InfoRow(
                          iconWidget: Image.asset(
                            AppAssets.iconVeiculo,
                            width: 12,
                            height: 10,
                            fit: BoxFit.contain,
                            color: AppColors.primaryBlue,
                          ),
                          label: 'Placa do veículo',
                          valor: corrida.placaVeiculo,
                        ),
                        const SizedBox(height: 20),
                      ],

                      _InfoRow(
                        iconWidget: Image.asset(
                          AppAssets.iconMotivo,
                          width: 12,
                          height: 12,
                          fit: BoxFit.contain,
                          color: AppColors.primaryBlue,
                        ),
                        label: corridaRealizada ? 'Motivo' : 'Motivo da viagem',
                        valor: solicitacao.motivoSolicitacao,
                      ),
                      const SizedBox(height: 20),

                      if (solicitacao.centrosCusto.isNotEmpty) ...[
                        _InfoRow(
                          iconWidget: const Icon(
                            Icons.account_tree_outlined,
                            size: 12,
                            color: AppColors.primaryBlue,
                          ),
                          label: solicitacao.centrosCusto.length > 1
                              ? 'Centros de custo'
                              : 'Centro de custo',
                          valor: solicitacao.centrosCusto
                              .map(
                                (rateio) =>
                                    rateio.centroCustoNome ??
                                    rateio.centroCustoId.toString(),
                              )
                              .join(', '),
                        ),
                        const SizedBox(height: 20),
                      ],

                      if (solicitacao.compartilhada) ...[
                        _InfoRow(
                          iconWidget: const Icon(
                            Icons.people_outline_rounded,
                            size: 12,
                            color: AppColors.primaryBlue,
                          ),
                          label: 'Passageiros',
                          valor: solicitacao.passageiros
                              .map(
                                (passageiro) =>
                                    passageiro.nome ?? passageiro.cpf,
                              )
                              .join(', '),
                        ),
                        const SizedBox(height: 20),
                      ],

                      if (solicitacao.cancelavel) ...[
                        const SizedBox(height: 20),
                        _BotaoCancelar(
                          cancelando: state.cancelando,
                          motivos: state.motivosCancelamento,
                        ),
                        const SizedBox(height: 24),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatarMoeda(double valor) =>
      'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(25, 16, 25, 16),
      child: Row(
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
            'Detalhes da corrida',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w500,
              color: AppColors.darkBlue,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final SolicitacaoStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 17,
          height: 17,
          decoration: BoxDecoration(
            color: status.corIndicador,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          status.label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.darkBlue,
          ),
        ),
      ],
    );
  }
}

class _BlocoMotivoRecusa extends StatelessWidget {
  final String titulo;
  final String motivo;

  const _BlocoMotivoRecusa({
    this.titulo = 'Motivo da reprovação',
    required this.motivo,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: AppColors.textGrey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          motivo,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.darkBlue,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        const Divider(color: AppColors.borderGrey),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final Widget iconWidget;
  final String label;
  final String valor;

  const _InfoRow({
    required this.iconWidget,
    required this.label,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsets.only(top: 2), child: iconWidget),
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
}

class _LinhaConectora extends StatelessWidget {
  const _LinhaConectora();

  @override
  Widget build(BuildContext context) {
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
}

class _BotaoCancelar extends StatelessWidget {
  final bool cancelando;
  final List<Motivo> motivos;

  const _BotaoCancelar({required this.cancelando, required this.motivos});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 245,
        height: 60,
        child: ElevatedButton(
          onPressed: cancelando ? null : () => _abrirDialogo(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: AppColors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: cancelando
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.white,
                  ),
                )
              : const Text(
                  'Cancelar solicitação',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
        ),
      ),
    );
  }

  Future<void> _abrirDialogo(BuildContext context) async {
    if (motivos.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Não foi possível carregar os motivos de cancelamento.',
            ),
          ),
        );
      return;
    }

    final bloc = context.read<DetalheSolicitacaoBloc>();

    final motivoId = await showDialog<int>(
      context: context,
      builder: (dialogContext) => _DialogoCancelamento(motivos: motivos),
    );

    if (motivoId != null) {
      bloc.add(DetalheSolicitacaoCancelado(motivoId));
    }
  }
}

class _DialogoCancelamento extends StatefulWidget {
  final List<Motivo> motivos;

  const _DialogoCancelamento({required this.motivos});

  @override
  State<_DialogoCancelamento> createState() => _DialogoCancelamentoState();
}

class _DialogoCancelamentoState extends State<_DialogoCancelamento> {
  int? _motivoSelecionado;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      contentPadding: const EdgeInsets.all(24),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tem certeza de que deseja cancelar essa solicitação?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.darkBlue,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Informe o motivo',
            style: TextStyle(fontSize: 14, color: AppColors.textGrey),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<int>(
            initialValue: _motivoSelecionado,
            isExpanded: true,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: widget.motivos
                .map(
                  (motivo) => DropdownMenuItem(
                    value: motivo.id,
                    child: Text(motivo.nome, overflow: TextOverflow.ellipsis),
                  ),
                )
                .toList(),
            onChanged: (valor) => setState(() => _motivoSelecionado = valor),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 37,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primaryBlue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Não',
                      style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 37,
                  child: ElevatedButton(
                    onPressed: _motivoSelecionado == null
                        ? null
                        : () => Navigator.pop(context, _motivoSelecionado),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Sim',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
