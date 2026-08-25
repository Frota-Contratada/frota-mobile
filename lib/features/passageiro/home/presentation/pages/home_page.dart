import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../config/routes.dart';
import '../../../../../core/maps/map_point.dart';
import '../../../../../core/widgets/empty_state_widget.dart';
import '../../../../../core/widgets/map_picker_page.dart';
import '../../../../../injection_container/injection_container.dart';
import '../../../../auth/domain/entities/usuario.dart';
import '../../../shared/presentation/theme/passageiro_colors.dart';
import '../../../solicitacao/presentation/pages/solicitar_viagem_route_args.dart';
import '../bloc/home.bloc.dart';
import '../utils/semana_util.dart';
import '../widgets/home_header_widget.dart';
import '../widgets/mapa_busca_widget.dart';
import '../widgets/semana_seletor_widget.dart';
import '../widgets/solicitacao_cards_widget.dart';
import '../widgets/timeline_dia_widget.dart';

class PassageiroHomePage extends StatefulWidget {
  final Usuario? usuario;

  const PassageiroHomePage({super.key, this.usuario});

  @override
  State<PassageiroHomePage> createState() => _PassageiroHomePageState();
}

class _PassageiroHomePageState extends State<PassageiroHomePage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PassageiroHomeBloc>(),
      child: _PassageiroHomeContent(usuario: widget.usuario),
    );
  }
}

class _PassageiroHomeContent extends StatefulWidget {
  final Usuario? usuario;

  const _PassageiroHomeContent({this.usuario});

  @override
  State<_PassageiroHomeContent> createState() => _PassageiroHomeContentState();
}

class _PassageiroHomeContentState extends State<_PassageiroHomeContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<PassageiroHomeBloc>().add(
        PassageiroHomeIniciada(usuario: widget.usuario),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: BlocBuilder<PassageiroHomeBloc, PassageiroHomeState>(
        builder: (context, state) {
          final usuarioAtual = _resolverUsuario(state);

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HomeHeaderWidget(
                      usuario: usuarioAtual,
                      onConfiguracoes: () => Navigator.pushNamed(
                        context,
                        AppRoutes.passageiroConfiguracoes,
                      ),
                    ),
                    const SizedBox(height: 30),
                    MapaBuscaWidget(onBuscarLocal: _abrirBuscaLocal),
                    const SizedBox(height: 30),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 25),
                      child: Text(
                        'Solicitar transporte',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w500,
                          color: PassageiroColors.darkBlue,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    SolicitacaoCardsWidget(
                      onViagem: () => Navigator.pushNamed(
                        context,
                        AppRoutes.passageiroSolicitarViagem,
                      ),
                      onObjeto: () => Navigator.pushNamed(
                        context,
                        AppRoutes.passageiroSolicitarObjeto,
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 25),
                      child: Text(
                        'Viagens agendadas',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w500,
                          color: PassageiroColors.darkBlue,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SemanaSeletorWidget(
                      intervaloSemana: _resolverIntervaloSemana(state),
                      onSemanaAnterior: state is PassageiroHomeCarregada
                          ? () => context.read<PassageiroHomeBloc>().add(
                              PassageiroHomeSemanaAnterior(),
                            )
                          : () {},
                      onSemanaProxima: state is PassageiroHomeCarregada
                          ? () => context.read<PassageiroHomeBloc>().add(
                              PassageiroHomeSemanaProxima(),
                            )
                          : () {},
                    ),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
              SliverToBoxAdapter(child: _buildConteudo(context, state)),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildConteudo(BuildContext context, PassageiroHomeState state) {
    if (state is PassageiroHomeInitial || state is PassageiroHomeLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(
          child: CircularProgressIndicator(color: PassageiroColors.primaryBlue),
        ),
      );
    }

    if (state is PassageiroHomeErro) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              state.mensagem,
              textAlign: TextAlign.center,
              style: const TextStyle(color: PassageiroColors.darkBlue),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<PassageiroHomeBloc>().add(
                  PassageiroHomeIniciada(usuario: state.usuario),
                );
              },
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    if (state is PassageiroHomeCarregada) {
      final dias = state.viagensPorDia.entries.toList();

      if (dias.isEmpty) {
        return const Padding(
          padding: EdgeInsets.symmetric(horizontal: 25),
          child: EmptyStateWidget(
            icon: Icons.event_available_rounded,
            mensagem: 'Nenhuma viagem agendada',
            submensagem: 'Suas viagens para esta semana aparecerão aqui.',
          ),
        );
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          children: dias.asMap().entries.map((entry) {
            final index = entry.key;
            final diaEntry = entry.value;
            return TimelineDiaWidget(
              dia: diaEntry.key,
              viagens: diaEntry.value,
              isUltimoDia: index == dias.length - 1,
              onVerDetalhes: (viagem) {
                Navigator.pushNamed(
                  context,
                  AppRoutes.passageiroDetalheSolicitacao,
                  arguments: int.tryParse(viagem.id),
                );
              },
              onViagemEmAndamento: (viagem) {
                Navigator.pushNamed(
                  context,
                  AppRoutes.passageiroCorridaAndamento,
                  arguments: {
                    'origem': viagem.origem,
                    'destino': viagem.destino,
                    'motoristaNome': viagem.motoristaNome,
                    'placaVeiculo': viagem.placaVeiculo,
                  },
                );
              },
            );
          }).toList(),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Future<void> _abrirBuscaLocal() async {
    final result = await Navigator.push<MapSelectionResult>(
      context,
      MaterialPageRoute(
        builder: (_) => const MapPickerPage(
          title: 'Buscar local',
          selectionKind: MapSelectionKind.destination,
        ),
      ),
    );
    if (!mounted || result == null) return;

    await Navigator.pushNamed(
      context,
      AppRoutes.passageiroSolicitarViagem,
      arguments: SolicitarViagemRouteArgs(destinoInicial: result),
    );
  }

  Usuario? _resolverUsuario(PassageiroHomeState state) {
    if (state is PassageiroHomeCarregada) {
      return state.usuario ?? widget.usuario;
    }
    if (state is PassageiroHomeLoading) return state.usuario ?? widget.usuario;
    if (state is PassageiroHomeErro) return state.usuario ?? widget.usuario;
    return widget.usuario;
  }

  String _resolverIntervaloSemana(PassageiroHomeState state) {
    if (state is PassageiroHomeCarregada) return state.intervaloSemana;
    if (state is PassageiroHomeLoading) {
      return SemanaUtil.formatarIntervaloSemana(
        state.inicioSemana,
        state.fimSemana,
      );
    }
    if (state is PassageiroHomeErro) {
      return SemanaUtil.formatarIntervaloSemana(
        state.inicioSemana,
        state.fimSemana,
      );
    }

    final inicio = SemanaUtil.inicioSemanaAtual();
    final fim = SemanaUtil.fimSemanaUtil(inicio);
    return SemanaUtil.formatarIntervaloSemana(inicio, fim);
  }
}
