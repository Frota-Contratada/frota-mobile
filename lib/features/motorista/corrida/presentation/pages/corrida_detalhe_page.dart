import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../injection_container/injection_container.dart';
import '../../domain/entities/corrida_detalhe.dart';
import '../bloc/corrida.bloc.dart';
import '../widgets/corrida_colors.dart';
import '../widgets/corrida_detalhe_conteudo_widget.dart';

class CorridaDetalhePage extends StatefulWidget {
  const CorridaDetalhePage({super.key});

  @override
  State<CorridaDetalhePage> createState() => _CorridaDetalhePageState();
}

class _CorridaDetalhePageState extends State<CorridaDetalhePage> {
  @override
  Widget build(BuildContext context) {
    final corridaId = ModalRoute.of(context)?.settings.arguments as String?;

    return BlocProvider(
      create: (_) => sl<CorridaBloc>(),
      child: _CorridaDetalheContent(corridaId: corridaId),
    );
  }
}

class _CorridaDetalheContent extends StatefulWidget {
  final String? corridaId;

  const _CorridaDetalheContent({this.corridaId});

  @override
  State<_CorridaDetalheContent> createState() => _CorridaDetalheContentState();
}

class _CorridaDetalheContentState extends State<_CorridaDetalheContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final corridaId = widget.corridaId;
      if (corridaId == null || corridaId.isEmpty) {
        Navigator.of(context).pop();
        return;
      }
      context.read<CorridaBloc>().add(
            CorridaDetalheSolicitado(corridaId: corridaId),
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CorridaColors.background,
      body: SafeArea(
        child: BlocConsumer<CorridaBloc, CorridaState>(
          listener: (context, state) {
            if (state is CorridaIniciada) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Corrida iniciada com sucesso!'),
                  backgroundColor: CorridaColors.primaryBlue,
                ),
              );
              Navigator.of(context).pop(true);
            }

            if (state is CorridaErro && state.corrida == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.mensagem),
                  backgroundColor: Colors.red.shade700,
                ),
              );
            }

            if (state is CorridaErro && state.corrida != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.mensagem),
                  backgroundColor: Colors.red.shade700,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is CorridaInitial || state is CorridaLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: CorridaColors.primaryBlue,
                ),
              );
            }

            if (state is CorridaErro && state.corrida == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        state.mensagem,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: CorridaColors.darkBlue),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Voltar'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final corrida = _resolverCorrida(state);
            if (corrida == null) {
              return const SizedBox.shrink();
            }

            return CorridaDetalheConteudoWidget(
              corrida: corrida,
              onVoltar: () => Navigator.of(context).pop(),
              onIniciarCorrida: corrida.ehProxima
                  ? () => context.read<CorridaBloc>().add(
                        CorridaIniciarSolicitado(corridaId: corrida.id),
                      )
                  : null,
              isIniciando: state is CorridaIniciando,
            );
          },
        ),
      ),
    );
  }

  CorridaDetalhe? _resolverCorrida(CorridaState state) {
    if (state is CorridaDetalheCarregado) return state.corrida;
    if (state is CorridaIniciando) return state.corrida;
    if (state is CorridaErro) return state.corrida;
    return null;
  }
}
