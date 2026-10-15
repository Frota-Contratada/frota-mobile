import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/routes.dart';
import '../../../../core/widgets/app_colors.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../auth/domain/entities/usuario.dart';
import '../../../auth/domain/enums/perfil_usuario.dart';
import '../../domain/entities/notificacao.dart';
import '../bloc/notificacoes_bloc.dart';
import '../widgets/notificacao_card_widget.dart';

class NotificacoesPage extends StatefulWidget {
  final Usuario? usuario;

  const NotificacoesPage({super.key, this.usuario});

  @override
  State<NotificacoesPage> createState() => _NotificacoesPageState();
}

class _NotificacoesPageState extends State<NotificacoesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notificações'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.darkBlue,
        elevation: 0,
      ),
      body: BlocConsumer<NotificacoesBloc, NotificacoesState>(
        listener: (context, state) {
          if (state is NotificacoesCarregada &&
              state.mensagemErro != null &&
              mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.mensagemErro!)));
          }
        },
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () async {
              final bloc = context.read<NotificacoesBloc>();
              bloc.add(const NotificacoesCarregadas());
              await bloc.stream.firstWhere(
                (novoEstado) =>
                    novoEstado is NotificacoesCarregada ||
                    novoEstado is NotificacoesErro,
              );
            },
            child: _buildConteudo(context, state),
          );
        },
      ),
    );
  }

  Widget _buildConteudo(BuildContext context, NotificacoesState state) {
    if (state is NotificacoesInitial || state is NotificacoesLoading) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(
            height: 320,
            child: Center(child: CircularProgressIndicator()),
          ),
        ],
      );
    }

    if (state is NotificacoesErro) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 64),
          EmptyStateWidget(
            icon: state.semConexao
                ? Icons.wifi_off_rounded
                : Icons.cloud_off_rounded,
            mensagem: state.semConexao
                ? 'Você está sem internet'
                : 'Não foi possível carregar suas notificações',
            submensagem: state.mensagem,
          ),
          Center(
            child: ElevatedButton(
              onPressed: () => context.read<NotificacoesBloc>().add(
                const NotificacoesCarregadas(),
              ),
              child: const Text('Tentar novamente'),
            ),
          ),
        ],
      );
    }

    final carregada = state as NotificacoesCarregada;
    if (carregada.notificacoes.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 64),
          EmptyStateWidget(
            icon: Icons.notifications_none_rounded,
            mensagem: 'Nenhuma notificação',
            submensagem: 'Suas notificações aparecerão aqui.',
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      itemCount: carregada.notificacoes.length + 1,
      separatorBuilder: (_, index) => SizedBox(height: index == 0 ? 12 : 10),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Text(
            '${carregada.quantidadeNaoLidas} não ${carregada.quantidadeNaoLidas == 1 ? 'lida' : 'lidas'}',
            style: const TextStyle(
              color: AppColors.textMediumGrey,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          );
        }

        final notificacao = carregada.notificacoes[index - 1];
        return NotificacaoCardWidget(
          notificacao: notificacao,
          onTap: () => _abrirNotificacao(context, notificacao),
        );
      },
    );
  }

  Future<void> _abrirNotificacao(
    BuildContext context,
    Notificacao notificacao,
  ) async {
    final navigator = Navigator.of(context);
    final marcada = await context.read<NotificacoesBloc>().marcarComoLida(
      notificacao.id,
    );
    if (!mounted || !marcada) return;

    final acao = notificacao.acao;
    if (widget.usuario?.perfil != PerfilUsuario.passageiro || acao == null) {
      return;
    }
    if (acao.rota != '/solicitacoes') return;

    final solicitacaoId = int.tryParse(acao.parametros['solicitacaoId'] ?? '');
    if (solicitacaoId == null) return;
    await navigator.pushNamed(
      AppRoutes.passageiroDetalheSolicitacao,
      arguments: solicitacaoId,
    );
  }
}
