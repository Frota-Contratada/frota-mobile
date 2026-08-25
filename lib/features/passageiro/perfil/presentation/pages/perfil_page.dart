import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../config/routes.dart';
import '../../../../../core/widgets/corrida_card_base_widget.dart';
import '../../../../../core/widgets/empty_state_widget.dart';
import '../../../../../core/widgets/historico_filtro.dart';
import '../../../../../core/widgets/perfil_page_base.dart';
import '../../../../../core/widgets/timeline_dia_widget.dart';
import '../../../../../injection_container/injection_container.dart';
import '../../../../auth/domain/entities/usuario.dart';
import '../../../home/presentation/utils/semana_util.dart';
import '../../../solicitacoes/domain/entities/solicitacao.dart';
import '../../../solicitacoes/presentation/bloc/solicitacoes.bloc.dart';
import '../../../shared/presentation/widgets/filtro_historico_bottom_sheet.dart';

class PassageiroPerfilPage extends StatelessWidget {
  final Usuario? usuario;

  const PassageiroPerfilPage({super.key, this.usuario});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<SolicitacoesBloc>()
            ..add(const SolicitacoesCarregadas(apenasHistorico: true)),
      child: _PerfilView(usuario: usuario),
    );
  }
}

class _PerfilView extends StatefulWidget {
  final Usuario? usuario;

  const _PerfilView({this.usuario});

  @override
  State<_PerfilView> createState() => _PerfilViewState();
}

class _PerfilViewState extends State<_PerfilView> {
  String _busca = '';
  HistoricoFiltro _filtro = const HistoricoFiltro();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SolicitacoesBloc, SolicitacoesState>(
      builder: (context, state) {
        final carregada = state is SolicitacoesCarregada ? state : null;

        return PerfilPageBase(
          nome: widget.usuario?.nome ?? 'Passageiro',
          subtitulo: widget.usuario?.email ?? '',
          viagensFinalizadas: carregada?.totalViagens ?? 0,
          transportesDeItens: carregada?.totalTransportes ?? 0,
          mostrarBotaoVoltar: false,
          onVoltar: () => Navigator.of(context).maybePop(),
          onBuscaChanged: (valor) => setState(() => _busca = valor),
          onFiltroTap: () => _abrirFiltros(context),
          historicoContent: _buildHistorico(context, state),
        );
      },
    );
  }

  List<Widget> _buildHistorico(BuildContext context, SolicitacoesState state) {
    if (state is SolicitacoesLoading || state is SolicitacoesInitial) {
      return const [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }

    if (state is SolicitacoesErro) {
      return [
        EmptyStateWidget(
          icon: state.semConexao
              ? Icons.wifi_off_rounded
              : Icons.cloud_off_rounded,
          mensagem: state.semConexao
              ? 'Você está sem internet'
              : 'Não foi possível carregar seu histórico',
          submensagem: state.mensagem,
        ),
      ];
    }

    final carregada = state as SolicitacoesCarregada;
    final porDia = _filtrarHistorico(carregada.solicitacoes);

    if (porDia.isEmpty) {
      return [
        EmptyStateWidget(
          icon: _busca.isEmpty
              ? Icons.history_rounded
              : Icons.search_off_rounded,
          mensagem: _busca.isEmpty && _filtro.estaLimpo
              ? 'Você ainda não tem corridas anteriores'
              : 'Nenhum resultado encontrado',
          submensagem: _busca.isEmpty && _filtro.estaLimpo
              ? null
              : 'Tente buscar por outro destino ou limpe os filtros.',
        ),
      ];
    }

    final dias = porDia.entries.toList();

    return dias.asMap().entries.map((entrada) {
      final ultimo = entrada.key == dias.length - 1;
      final dia = entrada.value.key;
      final solicitacoes = entrada.value.value;

      return TimelineDiaWidget(
        labelDia: SemanaUtil.formatarDiaViagem(dia),
        isUltimoDia: ultimo,
        cards: solicitacoes.asMap().entries.map((item) {
          final ultimaDoDia = item.key == solicitacoes.length - 1;
          final solicitacao = item.value;

          return Padding(
            padding: EdgeInsets.only(bottom: ultimo && ultimaDoDia ? 0 : 16),
            child: CorridaCardBaseWidget(
              origem: solicitacao.origem.descricao,
              destino: solicitacao.destino.descricao,
              horarioPartida: SemanaUtil.formatarHorario(
                solicitacao.dataCorrida,
              ),
              onVerDetalhes: () => Navigator.pushNamed(
                context,
                AppRoutes.passageiroDetalheSolicitacao,
                arguments: solicitacao.id,
              ),
            ),
          );
        }).toList(),
      );
    }).toList();
  }

  Future<void> _abrirFiltros(BuildContext context) async {
    final bloc = context.read<SolicitacoesBloc>();
    final resultado = await FiltroHistoricoBottomSheet.show(
      context,
      inicial: _filtro,
    );

    if (!mounted || resultado == null) return;
    setState(() => _filtro = resultado);
    bloc.add(
      SolicitacoesCarregadas(
        apenasHistorico: true,
        dataInicio: _filtro.dataInicio,
        dataFim: _filtro.dataFim,
      ),
    );
  }

  Map<DateTime, List<Solicitacao>> _filtrarHistorico(
    List<Solicitacao> solicitacoes,
  ) {
    final termo = _busca.trim().toLowerCase();
    final filtradas = _filtro.ordenar(
      solicitacoes.where((solicitacao) {
        final buscaCoincide =
            termo.isEmpty ||
            solicitacao.destino.descricao.toLowerCase().contains(termo) ||
            solicitacao.origem.descricao.toLowerCase().contains(termo) ||
            solicitacao.tipoCorrida.toLowerCase().contains(termo);

        return buscaCoincide &&
            _filtro.correspondeTipo(solicitacao.tipoCorrida) &&
            _filtro.correspondeData(solicitacao.dataCorrida) &&
            _filtro.correspondeStatus(solicitacao.status.codigo);
      }),
      (solicitacao) => solicitacao.dataCorrida,
    );

    final mapa = <DateTime, List<Solicitacao>>{};
    for (final solicitacao in filtradas) {
      final dia = DateTime(
        solicitacao.dataCorrida.year,
        solicitacao.dataCorrida.month,
        solicitacao.dataCorrida.day,
      );
      mapa.putIfAbsent(dia, () => []).add(solicitacao);
    }

    final entradas = mapa.entries.toList()
      ..sort((a, b) {
        final comparacao = a.key.compareTo(b.key);
        return _filtro.ordenacao == HistoricoOrdenacao.maisRecente
            ? -comparacao
            : comparacao;
      });

    return Map.fromEntries(entradas);
  }
}
