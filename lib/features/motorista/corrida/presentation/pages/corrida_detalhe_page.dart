import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../config/routes.dart';
import '../../../../../injection_container/injection_container.dart';
import '../../../../shared/trip_tracking/domain/entities/trip_tracking_snapshot.dart';
import '../../../../shared/trip_tracking/presentation/pages/trip_webview_page.dart';
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
  Future<void> _abrirDialogoRecusa(String corridaId) async {
    final controller = TextEditingController();
    final motivo = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        String? erro;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Recusar corrida'),
              content: TextField(
                controller: controller,
                maxLines: 4,
                maxLength: 500,
                decoration: InputDecoration(
                  hintText: 'Informe o motivo da recusa',
                  errorText: erro,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () {
                    final valor = controller.text.trim();
                    if (valor.length < 5) {
                      setState(() => erro = 'Informe ao menos 5 caracteres');
                      return;
                    }
                    Navigator.of(dialogContext).pop(valor);
                  },
                  child: const Text('Recusar'),
                ),
              ],
            );
          },
        );
      },
    );
    controller.dispose();

    if (!mounted || motivo == null) return;
    context.read<CorridaBloc>().add(
      CorridaRecusarSolicitado(corridaId: corridaId, motivo: motivo),
    );
  }

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
              Navigator.of(context).pushReplacementNamed(
                AppRoutes.tripWebView,
                arguments: TripWebViewArgs(
                  tripId: state.corrida.id,
                  role: TripRole.driver,
                ),
              );
            }

            if (state is CorridaRecusada) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Corrida recusada com sucesso.'),
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
              onRecusarCorrida: corrida.ehProxima
                  ? () => _abrirDialogoRecusa(corrida.id)
                  : null,
              isIniciando: state is CorridaIniciando,
              isRecusando: state is CorridaRecusando,
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
