import 'package:flutter/material.dart';
import '../../../../../config/routes.dart';
import '../../../../../core/widgets/corrida_card_base_widget.dart';
import '../../../../../core/widgets/empty_state_widget.dart';
import '../../../../../core/widgets/perfil_page_base.dart';
import '../../../../../core/widgets/timeline_dia_widget.dart';
import '../../../../auth/domain/entities/usuario.dart';

/// Página de Perfil do motorista.
/// Usa o [PerfilPageBase] compartilhado e popula com dados mock
/// até a integração com o backend.
class MotoristPerfilPage extends StatefulWidget {
  final Usuario? usuario;

  const MotoristPerfilPage({super.key, this.usuario});

  @override
  State<MotoristPerfilPage> createState() => _MotoristPerfilPageState();
}

class _MotoristPerfilPageState extends State<MotoristPerfilPage> {
  String _busca = '';

  @override
  Widget build(BuildContext context) {
    final nome = widget.usuario?.nome ?? 'Antônio Gonçalves';

    return PerfilPageBase(
      nome: nome,
      subtitulo: 'Moreira Transportes',
      viagensFinalizadas: 20,
      transportesDeItens: 5,
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
    final corridasMock = [
      _CorridaMock(
        origem: 'Av. das Flores, 150 - Vila Rosa',
        destino: 'Rod PR-340 - km 2.5, Jaguapitã',
        horario: '20h30',
      ),
      _CorridaMock(
        origem: 'Av. das Flores, 150 - Vila Rosa',
        destino: 'Rod PR-340 - km 2.5, Jaguapitã',
        horario: '08h15',
      ),
      _CorridaMock(
        origem: 'Av. das Flores, 150 - Vila Rosa',
        destino: 'Rod PR-340 - km 2.5, Jaguapitã',
        horario: '08h15',
      ),
    ];

    // Filtra por busca se necessário
    final corridasFiltradas = _busca.isEmpty
        ? corridasMock
        : corridasMock
              .where(
                (c) =>
                    c.destino.toLowerCase().contains(_busca.toLowerCase()) ||
                    c.origem.toLowerCase().contains(_busca.toLowerCase()),
              )
              .toList();

    if (corridasFiltradas.isEmpty) {
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
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: CorridaCardBaseWidget(
              origem: corridasFiltradas[0].origem,
              destino: corridasFiltradas[0].destino,
              horarioPartida: corridasFiltradas[0].horario,
              onVerDetalhes: () => _navegarDetalhe(corridasFiltradas[0]),
            ),
          ),
        ],
      ),
      TimelineDiaWidget(
        labelDia: 'Sexta-Feira 17/04',
        isUltimoDia: true,
        cards: [
          if (corridasFiltradas.length > 1)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: CorridaCardBaseWidget(
                origem: corridasFiltradas[1].origem,
                destino: corridasFiltradas[1].destino,
                horarioPartida: corridasFiltradas[1].horario,
                onVerDetalhes: () => _navegarDetalhe(corridasFiltradas[1]),
              ),
            ),
          if (corridasFiltradas.length > 2)
            CorridaCardBaseWidget(
              origem: corridasFiltradas[2].origem,
              destino: corridasFiltradas[2].destino,
              horarioPartida: corridasFiltradas[2].horario,
              onVerDetalhes: () => _navegarDetalhe(corridasFiltradas[2]),
            ),
        ],
      ),
    ];
  }

  void _navegarDetalhe(_CorridaMock corrida) {
    Navigator.pushNamed(
      context,
      AppRoutes.motoristaCorridaDetalhe,
      arguments: corrida.destino, // corridaId mock
    );
  }
}

class _CorridaMock {
  final String origem;
  final String destino;
  final String horario;

  const _CorridaMock({
    required this.origem,
    required this.destino,
    required this.horario,
  });
}
