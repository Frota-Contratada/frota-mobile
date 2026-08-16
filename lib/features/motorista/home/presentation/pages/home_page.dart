import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../config/routes.dart';
import '../../../../../core/widgets/empty_state_widget.dart';
import '../../../../../injection_container/injection_container.dart';
import '../../../../auth/domain/entities/usuario.dart';
import '../bloc/home.bloc.dart';
import '../utils/semana_util.dart';
import '../widgets/home_colors.dart';
import '../widgets/home_header_widget.dart';
import '../widgets/semana_seletor_widget.dart';
import '../widgets/timeline_dia_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final usuario = ModalRoute.of(context)?.settings.arguments as Usuario?;

    return BlocProvider(
      create: (_) => sl<HomeBloc>(),
      child: _HomeContent(usuario: usuario),
    );
  }
}

class _HomeContent extends StatefulWidget {
  final Usuario? usuario;

  const _HomeContent({this.usuario});

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<HomeBloc>().add(HomeIniciada(usuario: widget.usuario));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HomeColors.background,
      body: SafeArea(
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            final usuarioAtual = _resolverUsuario(state);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HomeHeaderWidget(
                  usuario: usuarioAtual,
                  onAvatarTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.motoristaPerfil,
                  ),
                  onConfiguracoes: () => Navigator.pushNamed(
                    context,
                    AppRoutes.motoristaConfiguracoes,
                  ),
                ),
                const SizedBox(height: 28),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25),
                  child: Text(
                    'Viagens agendadas',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w500,
                      color: HomeColors.darkBlue,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                SemanaSeletorWidget(
                  intervaloSemana: _resolverIntervaloSemana(state),
                  onSemanaAnterior: state is HomeCarregada
                      ? () =>
                          context.read<HomeBloc>().add(HomeSemanaAnterior())
                      : () {},
                  onSemanaProxima: state is HomeCarregada
                      ? () =>
                          context.read<HomeBloc>().add(HomeSemanaProxima())
                      : () {},
                ),
                const SizedBox(height: 24),
                Expanded(child: _buildConteudo(context, state)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildConteudo(BuildContext context, HomeState state) {
    if (state is HomeInitial || state is HomeLoading) {
      return const Center(
        child: CircularProgressIndicator(color: HomeColors.primaryBlue),
      );
    }

    if (state is HomeErro) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                state.mensagem,
                textAlign: TextAlign.center,
                style: const TextStyle(color: HomeColors.darkBlue),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  context.read<HomeBloc>().add(
                    HomeIniciada(usuario: state.usuario),
                  );
                },
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    if (state is HomeCarregada) {
      final dias = state.corridasPorDia.entries.toList();

      if (dias.isEmpty) {
        return const Center(
          child: EmptyStateWidget(
            icon: Icons.event_available_rounded,
            mensagem: 'Nenhuma viagem agendada',
            submensagem: 'Suas corridas para esta semana aparecerão aqui.',
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(25, 0, 16, 24),
        itemCount: dias.length,
        itemBuilder: (context, index) {
          final entrada = dias[index];
          return TimelineDiaWidget(
            dia: entrada.key,
            corridas: entrada.value,
            isUltimoDia: index == dias.length - 1,
          );
        },
      );
    }

    return const SizedBox.shrink();
  }

  Usuario? _resolverUsuario(HomeState state) {
    if (state is HomeCarregada) return state.usuario ?? widget.usuario;
    if (state is HomeLoading) return state.usuario ?? widget.usuario;
    if (state is HomeErro) return state.usuario ?? widget.usuario;
    return widget.usuario;
  }

  String _resolverIntervaloSemana(HomeState state) {
    if (state is HomeCarregada) return state.intervaloSemana;
    if (state is HomeLoading) {
      return SemanaUtil.formatarIntervaloSemana(
        state.inicioSemana,
        state.fimSemana,
      );
    }
    if (state is HomeErro) {
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
