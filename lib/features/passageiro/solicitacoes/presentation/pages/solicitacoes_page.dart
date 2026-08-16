import 'package:flutter/material.dart';
import '../../../../../config/app_assets.dart';
import '../../../../../config/routes.dart';
import '../../../../../core/widgets/app_colors.dart';
import '../../../../auth/domain/entities/usuario.dart';
import '../widgets/solicitacao_card_widget.dart';
import '../widgets/solicitacao_status.dart';

/// Página de Solicitações do passageiro.
/// Exibe header com avatar/saudação/config, e lista de solicitações
/// agrupadas por status (aprovadas, pendentes, reprovadas).
class SolicitacoesPage extends StatelessWidget {
  final Usuario? usuario;

  const SolicitacoesPage({super.key, this.usuario});

  @override
  Widget build(BuildContext context) {
    final nome = usuario?.nome ?? 'Maria Julia';

    return SafeArea(
      bottom: false,
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
                const SizedBox(height: 20),
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
                      Image.asset(
                        AppAssets.iconFiltro,
                        width: 21,
                        height: 14,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(25, 0, 25, 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                _buildGruposSolicitacoes(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildGruposSolicitacoes() {
    // Dados mock conforme Figma
    return [
      _GrupoSolicitacoes(
        label: 'Solicitações aprovadas',
        corIndicador: SolicitacaoStatus.aprovada.corIndicador,
        solicitacoes: [
          _SolicitacaoMock(
            destino: 'Rod PR-340 - km 2.5, Jaguapitã',
            status: SolicitacaoStatus.aprovada,
            data: '30/04',
            horario: '20h30',
          ),
        ],
      ),
      _GrupoSolicitacoes(
        label: 'Solicitações pendentes',
        corIndicador: SolicitacaoStatus.pendente.corIndicador,
        solicitacoes: [
          _SolicitacaoMock(
            destino: 'Rua das Flores, 123 - Vila Rosa',
            status: SolicitacaoStatus.pendente,
            data: '02/05',
            horario: '20h30',
          ),
        ],
      ),
      _GrupoSolicitacoes(
        label: 'Solicitações reprovadas',
        corIndicador: SolicitacaoStatus.reprovada.corIndicador,
        solicitacoes: [
          _SolicitacaoMock(
            destino: 'Rod PR-340 - km 2.5, Jaguapitã',
            status: SolicitacaoStatus.reprovada,
            data: '02/05',
            horario: '20h30',
          ),
        ],
      ),
    ];
  }
}

class _SolicitacoesHeader extends StatelessWidget {
  final String nome;
  final VoidCallback? onConfiguracoes;

  const _SolicitacoesHeader({
    required this.nome,
    this.onConfiguracoes,
  });

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
                  'Unidade Jaguapitã',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMediumGrey,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onConfiguracoes,
            icon: Image.asset(
              AppAssets.iconConfig,
              width: 27,
              height: 30,
              fit: BoxFit.contain,
            ),
          ),
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
  final String label;
  final List<_SolicitacaoMock> solicitacoes;
  final Color corIndicador;

  const _GrupoSolicitacoes({
    required this.label,
    required this.solicitacoes,
    required this.corIndicador,
  });

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
                color: corIndicador,
                shape: BoxShape.circle,
              ),
            ),
            Expanded(
              child: Text(
                label,
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
        const SizedBox(height: 12),
        ...solicitacoes.map(
          (s) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: SolicitacaoCardWidget(
              destino: s.destino,
              status: s.status,
              data: s.data,
              horarioPartida: s.horario,
              onVerDetalhes: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.passageiroDetalheSolicitacao,
                  arguments: {
                    'status': s.status,
                    'origem': 'Rod PR-340 - km 2.5, Jaguapitã',
                    'destino': s.destino,
                    'data': '17/03/2026',
                    'horarioPartida': s.horario,
                    'horarioChegada': '20h00',
                    'valor': 'R\$68,90',
                    'motivo':
                        'Preciso ir ao aeroporto para viagem de trabalho',
                    'motivoReprovacao': s.status ==
                            SolicitacaoStatus.reprovada
                        ? 'Viagem vai exceder a verba do setor para corridas de táxi'
                        : null,
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _SolicitacaoMock {
  final String destino;
  final SolicitacaoStatus status;
  final String data;
  final String horario;

  const _SolicitacaoMock({
    required this.destino,
    required this.status,
    required this.data,
    required this.horario,
  });
}
