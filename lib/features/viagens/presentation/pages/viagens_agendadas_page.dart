import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/domain/entities/usuario.dart';
import '../bloc/viagens.bloc.dart';
import '../utils/semana_util.dart';
import '../widgets/semana_seletor_widget.dart';
import '../widgets/timeline_dia_widget.dart';
import '../widgets/viagens_colors.dart';
import '../widgets/viagens_header_widget.dart';

class ViagensAgendadasPage extends StatelessWidget {
  final Usuario? usuario;

  const ViagensAgendadasPage({super.key, this.usuario});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ViagensColors.background,
      body: SafeArea(
        child: BlocBuilder<ViagensBloc, ViagensState>(
          builder: (context, state) {
            final usuarioAtual = _resolverUsuario(state);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ViagensHeaderWidget(usuario: usuarioAtual),
                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 23),
                  child: Text(
                    'Viagens agendadas',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: ViagensColors.darkBlue,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SemanaSeletorWidget(
                  intervaloSemana: _resolverIntervaloSemana(state),
                  onSemanaAnterior: state is ViagensCarregadas
                      ? () => context
                          .read<ViagensBloc>()
                          .add(ViagensSemanaAnterior())
                      : () {},
                  onSemanaProxima: state is ViagensCarregadas
                      ? () => context
                          .read<ViagensBloc>()
                          .add(ViagensSemanaProxima())
                      : () {},
                ),
                const SizedBox(height: 20),
                Expanded(child: _buildConteudo(context, state)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildConteudo(BuildContext context, ViagensState state) {
    if (state is ViagensInitial || state is ViagensLoading) {
      return const Center(
        child: CircularProgressIndicator(color: ViagensColors.primaryBlue),
      );
    }

    if (state is ViagensErro) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                state.mensagem,
                textAlign: TextAlign.center,
                style: const TextStyle(color: ViagensColors.darkBlue),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  context.read<ViagensBloc>().add(
                        ViagensIniciada(usuario: state.usuario),
                      );
                },
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    if (state is ViagensCarregadas) {
      final dias = state.corridasPorDia.entries.toList();

      if (dias.isEmpty) {
        return const Center(
          child: Text(
            'Nenhuma viagem agendada para esta semana.',
            style: TextStyle(
              fontSize: 14,
              color: ViagensColors.textMediumGrey,
            ),
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

  Usuario? _resolverUsuario(ViagensState state) {
    if (state is ViagensCarregadas) return state.usuario ?? usuario;
    if (state is ViagensLoading) return state.usuario ?? usuario;
    if (state is ViagensErro) return state.usuario ?? usuario;
    return usuario;
  }

  String _resolverIntervaloSemana(ViagensState state) {
    if (state is ViagensCarregadas) return state.intervaloSemana;
    if (state is ViagensLoading) {
      return SemanaUtil.formatarIntervaloSemana(
        state.inicioSemana,
        state.fimSemana,
      );
    }
    if (state is ViagensErro) {
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
