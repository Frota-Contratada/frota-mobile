import 'package:flutter/material.dart';
import '../../../../../config/routes.dart';
import '../../../../../core/widgets/corrida_card_base_widget.dart';
import '../../../../../core/widgets/empty_state_widget.dart';
import '../../../../../core/widgets/perfil_page_base.dart';
import '../../../../../core/widgets/timeline_dia_widget.dart';
import '../../../../auth/domain/entities/usuario.dart';
import '../../../solicitacoes/presentation/widgets/solicitacao_status.dart';

/// Página de Perfil do passageiro.
/// Usa o [PerfilPageBase] compartilhado com dados específicos do passageiro.
class PassageiroPerfilPage extends StatefulWidget {
  final Usuario? usuario;

  const PassageiroPerfilPage({super.key, this.usuario});

  @override
  State<PassageiroPerfilPage> createState() => _PassageiroPerfilPageState();
}

class _PassageiroPerfilPageState extends State<PassageiroPerfilPage> {
  String _busca = '';

  @override
  Widget build(BuildContext context) {
    final nome = widget.usuario?.nome ?? 'Maria Julia da Silva Oliveira';

    return PerfilPageBase(
      nome: nome,
      subtitulo: 'Analista de Qualidade',
      unidade: 'Unidade Jaguapitã',
      viagensFinalizadas: 20,
      transportesDeItens: 5,
      mostrarBotaoVoltar: false,
      onVoltar: () => Navigator.of(context).maybePop(),
      onBuscaChanged: (valor) => setState(() => _busca = valor),
      onFiltroTap: () {
        // TODO: implementar filtro
      },
      historicoContent: _buildHistorico(),
    );
  }

  List<Widget> _buildHistorico() {
    // Dados mock para visualização do layout
    final viagensMock = [
      _ViagemMock(
        origem: 'Av. das Flores, 150 - Vila Rosa',
        destino: 'Rod PR-340 - km 2.5, Jaguapitã',
        horario: '20h30',
      ),
      _ViagemMock(
        origem: 'Av. das Flores, 150 - Vila Rosa',
        destino: 'Rod PR-340 - km 2.5, Jaguapitã',
        horario: '08h15',
      ),
      _ViagemMock(
        origem: 'Av. das Flores, 150 - Vila Rosa',
        destino: 'Rod PR-340 - km 2.5, Jaguapitã',
        horario: '08h15',
      ),
    ];

    // Filtra por busca se necessário
    final viagensFiltradas = _busca.isEmpty
        ? viagensMock
        : viagensMock
              .where(
                (v) =>
                    v.destino.toLowerCase().contains(_busca.toLowerCase()) ||
                    v.origem.toLowerCase().contains(_busca.toLowerCase()),
              )
              .toList();

    if (viagensFiltradas.isEmpty) {
      return [
        const EmptyStateWidget(
          icon: Icons.search_off_rounded,
          mensagem: 'Nenhum resultado encontrado',
          submensagem: 'Tente buscar por outro destino ou limpe o filtro.',
        ),
      ];
    }

    return [
      TimelineDiaWidget(
        labelDia: 'Ontem - 20/04',
        cards: [
          if (viagensFiltradas.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: CorridaCardBaseWidget(
                origem: viagensFiltradas[0].origem,
                destino: viagensFiltradas[0].destino,
                horarioPartida: viagensFiltradas[0].horario,
                onVerDetalhes: () => _navegarDetalhe(viagensFiltradas[0]),
              ),
            ),
        ],
      ),
      TimelineDiaWidget(
        labelDia: 'Sexta-Feira 17/04',
        isUltimoDia: true,
        cards: [
          if (viagensFiltradas.length > 1)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: CorridaCardBaseWidget(
                origem: viagensFiltradas[1].origem,
                destino: viagensFiltradas[1].destino,
                horarioPartida: viagensFiltradas[1].horario,
                onVerDetalhes: () => _navegarDetalhe(viagensFiltradas[1]),
              ),
            ),
          if (viagensFiltradas.length > 2)
            CorridaCardBaseWidget(
              origem: viagensFiltradas[2].origem,
              destino: viagensFiltradas[2].destino,
              horarioPartida: viagensFiltradas[2].horario,
              onVerDetalhes: () => _navegarDetalhe(viagensFiltradas[2]),
            ),
        ],
      ),
    ];
  }

  void _navegarDetalhe(_ViagemMock viagem) {
    Navigator.pushNamed(
      context,
      AppRoutes.passageiroDetalheSolicitacao,
      arguments: {
        'status': SolicitacaoStatus.aprovada,
        'origem': viagem.origem,
        'destino': viagem.destino,
        'data': '17/03/2026',
        'horarioPartida': viagem.horario,
        'horarioChegada': '20h00',
        'valor': 'R\$68,90',
        'motivo': 'Preciso ir ao aeroporto para viagem de trabalho',
        'motorista': 'Filipi Inácio Penha dos Santos',
        'placa': 'DXU1921',
        'corridaRealizada': true,
      },
    );
  }
}

class _ViagemMock {
  final String origem;
  final String destino;
  final String horario;

  const _ViagemMock({
    required this.origem,
    required this.destino,
    required this.horario,
  });
}
