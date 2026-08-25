import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../config/routes.dart';
import '../../../../../core/widgets/app_colors.dart';
import '../../../../../core/widgets/corrida_card_base_widget.dart';
import '../../../../../core/widgets/empty_state_widget.dart';
import '../../../../../core/widgets/historico_filtro.dart';
import '../../../../../core/widgets/perfil_page_base.dart';
import '../../../../../core/widgets/timeline_dia_widget.dart';
import '../../../../../injection_container/injection_container.dart';
import '../../../../auth/domain/entities/usuario.dart';
import '../../domain/entities/motorista_perfil.dart';
import '../bloc/motorista_perfil.bloc.dart';
import '../../../../passageiro/shared/presentation/widgets/filtro_historico_bottom_sheet.dart';

class MotoristPerfilPage extends StatelessWidget {
  final Usuario? usuario;

  const MotoristPerfilPage({super.key, this.usuario});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<MotoristaPerfilBloc>()..add(const MotoristaPerfilCarregado()),
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
    return BlocBuilder<MotoristaPerfilBloc, MotoristaPerfilState>(
      builder: (context, state) {
        final perfil = state is MotoristaPerfilCarregada ? state.perfil : null;

        return PerfilPageBase(
          nome: perfil?.nome ?? widget.usuario?.nome ?? 'Motorista',
          subtitulo: perfil?.email ?? widget.usuario?.email ?? '',
          unidade: perfil?.fornecedorNome,
          avatarDataUrl: perfil?.fotoPerfil,
          viagensFinalizadas: perfil?.viagensFinalizadas ?? 0,
          transportesDeItens: perfil?.transportesDeItens ?? 0,
          mostrarBotaoVoltar: true,
          mostrarLinhaAbaixoDoHeader: true,
          onVoltar: () => Navigator.of(context).maybePop(),
          onBuscaChanged: (valor) => setState(() => _busca = valor),
          onFiltroTap: () => _abrirFiltros(context),
          historicoContent: _buildHistorico(context, state),
        );
      },
    );
  }

  List<Widget> _buildHistorico(
    BuildContext context,
    MotoristaPerfilState state,
  ) {
    if (state is MotoristaPerfilInitial || state is MotoristaPerfilLoading) {
      return const [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }

    if (state is MotoristaPerfilErro) {
      return [
        EmptyStateWidget(
          icon: state.semConexao
              ? Icons.wifi_off_rounded
              : Icons.cloud_off_rounded,
          mensagem: state.semConexao
              ? 'Você está sem internet'
              : 'Não foi possível carregar seu perfil',
          submensagem: state.mensagem,
        ),
      ];
    }

    final perfil = (state as MotoristaPerfilCarregada).perfil;
    final porDia = _filtrarHistorico(perfil.historico);

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
      final corridas = entrada.value.value;

      return TimelineDiaWidget(
        labelDia: _formatarDia(dia),
        corIndicador: AppColors.timelineGrey,
        corLabel: AppColors.textMediumGrey,
        isUltimoDia: ultimo,
        cards: corridas.asMap().entries.map((item) {
          final ultimaDoDia = item.key == corridas.length - 1;
          final corrida = item.value;

          return Padding(
            padding: EdgeInsets.only(bottom: ultimo && ultimaDoDia ? 0 : 16),
            child: CorridaCardBaseWidget(
              origem: corrida.origem,
              destino: corrida.destino,
              horarioPartida: _formatarHorario(corrida.dataHoraPartida),
              onVerDetalhes: () => Navigator.pushNamed(
                context,
                AppRoutes.motoristaCorridaDetalhe,
                arguments: corrida.id,
              ),
            ),
          );
        }).toList(),
      );
    }).toList();
  }

  Future<void> _abrirFiltros(BuildContext context) async {
    final resultado = await FiltroHistoricoBottomSheet.show(
      context,
      inicial: _filtro,
    );

    if (!mounted || resultado == null) return;
    setState(() => _filtro = resultado);
  }

  Map<DateTime, List<MotoristaHistorico>> _filtrarHistorico(
    List<MotoristaHistorico> historico,
  ) {
    final termo = _busca.trim().toLowerCase();
    final filtradas = _filtro.ordenar(
      historico.where((corrida) {
        final buscaCoincide =
            termo.isEmpty ||
            corrida.origem.toLowerCase().contains(termo) ||
            corrida.destino.toLowerCase().contains(termo) ||
            corrida.tipoCorrida.toLowerCase().contains(termo);

        return buscaCoincide &&
            _filtro.correspondeTipo(corrida.tipoCorrida) &&
            _filtro.correspondeData(corrida.dataHoraPartida);
      }),
      (corrida) => corrida.dataHoraPartida,
    );

    final mapa = <DateTime, List<MotoristaHistorico>>{};
    for (final corrida in filtradas) {
      final dia = DateTime(
        corrida.dataHoraPartida.year,
        corrida.dataHoraPartida.month,
        corrida.dataHoraPartida.day,
      );
      mapa.putIfAbsent(dia, () => []).add(corrida);
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

  String _formatarDia(DateTime data) {
    final dias = [
      'Segunda-feira',
      'Terça-feira',
      'Quarta-feira',
      'Quinta-feira',
      'Sexta-feira',
      'Sábado',
      'Domingo',
    ];
    final dia = dias[data.weekday - 1];
    final dataFormatada =
        '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}';
    return '$dia - $dataFormatada';
  }

  String _formatarHorario(DateTime data) {
    return '${data.hour.toString().padLeft(2, '0')}h${data.minute.toString().padLeft(2, '0')}';
  }
}
