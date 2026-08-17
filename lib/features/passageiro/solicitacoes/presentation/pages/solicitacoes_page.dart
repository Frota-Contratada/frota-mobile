import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../config/routes.dart';
import '../../../../../core/widgets/app_colors.dart';
import '../../../../../core/widgets/empty_state_widget.dart';
import '../../../../../core/widgets/icone_configuracoes_button.dart';
import '../../../../../injection_container/injection_container.dart';
import '../../../../auth/domain/entities/usuario.dart';
import '../../../solicitacao/presentation/utils/solicitacao_formatters.dart';
import '../../domain/entities/solicitacao.dart';
import '../bloc/solicitacoes.bloc.dart';
import '../widgets/solicitacao_card_widget.dart';
import '../widgets/solicitacao_status.dart';

/// Página de solicitações do passageiro.
/// Exibe solicitações reais agrupadas por status e carregadas pela API.
class SolicitacoesPage extends StatelessWidget {
  final Usuario? usuario;

  const SolicitacoesPage({super.key, this.usuario});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<SolicitacoesBloc>()..add(const SolicitacoesCarregadas()),
      child: _SolicitacoesView(usuario: usuario),
    );
  }
}

class _SolicitacoesView extends StatelessWidget {
  final Usuario? usuario;

  const _SolicitacoesView({this.usuario});

  @override
  Widget build(BuildContext context) {
    final nome = usuario?.nome ?? 'Passageiro';

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: () async {
          context.read<SolicitacoesBloc>().add(const SolicitacoesCarregadas());
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SolicitacoesHeader(
                    nome: nome,
                    onConfiguracoes: () => Navigator.pushNamed(
                      context,
                      AppRoutes.passageiroConfiguracoes,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 25),
                    child: Divider(color: AppColors.borderGrey, height: 1),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Minhas solicitações',
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w500,
                              color: AppColors.darkBlue,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Material(
                          color: AppColors.primaryBlue,
                          shape: const CircleBorder(),
                          child: InkWell(
                            onTap: () {},
                            customBorder: const CircleBorder(),
                            child: const SizedBox(
                              width: 32,
                              height: 32,
                              child: Icon(
                                Icons.tune,
                                color: AppColors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            BlocBuilder<SolicitacoesBloc, SolicitacoesState>(
              builder: (context, state) {
                if (state is SolicitacoesLoading ||
                    state is SolicitacoesInitial) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (state is SolicitacoesErro) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyStateWidget(
                      icon: state.semConexao
                          ? Icons.wifi_off_rounded
                          : Icons.cloud_off_rounded,
                      mensagem: state.semConexao
                          ? 'Você está sem internet'
                          : 'Não foi possível carregar suas solicitações',
                      submensagem: state.mensagem,
                    ),
                  );
                }

                final carregada = state as SolicitacoesCarregada;
                final grupos = carregada.porStatus;

                if (grupos.isEmpty) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyStateWidget(
                      icon: Icons.inbox_rounded,
                      mensagem: 'Você ainda não fez solicitações',
                      submensagem:
                          'Toque em solicitar na home para pedir uma corrida.',
                    ),
                  );
                }

                final entradas = grupos.entries.toList();

                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(25, 0, 25, 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final entrada = entradas[index];

                      return _GrupoSolicitacoes(
                        status: SolicitacaoStatus.deDominio(entrada.key),
                        solicitacoes: entrada.value,
                      );
                    }, childCount: entradas.length),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SolicitacoesHeader extends StatelessWidget {
  final String nome;
  final VoidCallback? onConfiguracoes;

  const _SolicitacoesHeader({required this.nome, this.onConfiguracoes});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(25, 16, 25, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primaryBlue,
            child: Text(
              _iniciais(nome),
              style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Olá, $nome!',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.darkBlue,
                    letterSpacing: -0.16,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Unidade Jaguapitá',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMediumGrey,
                  ),
                ),
              ],
            ),
          ),
          IconeConfiguracoesButton(onPressed: onConfiguracoes),
        ],
      ),
    );
  }

  String _iniciais(String nome) {
    final partes = nome.trim().split(' ');
    if (partes.length >= 2) {
      return '${partes.first[0]}${partes.last[0]}'.toUpperCase();
    }
    return nome.isNotEmpty ? nome[0].toUpperCase() : '?';
  }
}

class _GrupoSolicitacoes extends StatelessWidget {
  final SolicitacaoStatus status;
  final List<Solicitacao> solicitacoes;

  const _GrupoSolicitacoes({required this.status, required this.solicitacoes});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: status.corIndicador,
                shape: BoxShape.circle,
              ),
            ),
            Expanded(
              child: Text(
                status.labelGrupo,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.darkBlue,
                  letterSpacing: -0.16,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...solicitacoes.map(
          (solicitacao) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: SolicitacaoCardWidget(
              destino: solicitacao.destino.descricao,
              status: status,
              data: _dataCurta(solicitacao.dataCorrida),
              horarioPartida: formatarHorarioSolicitacao(
                solicitacao.dataCorrida,
              ),
              onVerDetalhes: () => _abrirDetalhe(context, solicitacao),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _abrirDetalhe(
    BuildContext context,
    Solicitacao solicitacao,
  ) async {
    final bloc = context.read<SolicitacoesBloc>();

    await Navigator.pushNamed(
      context,
      AppRoutes.passageiroDetalheSolicitacao,
      arguments: solicitacao.id,
    );

    bloc.add(const SolicitacoesCarregadas());
  }

  String _dataCurta(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    return '$dia/$mes';
  }
}
