import 'historico_filtro.dart';

class SolicitacoesEmptyStateInfo {
  final String mensagem;
  final String submensagem;
  final bool mostrarLimparFiltros;

  const SolicitacoesEmptyStateInfo({
    required this.mensagem,
    required this.submensagem,
    required this.mostrarLimparFiltros,
  });

  factory SolicitacoesEmptyStateInfo.operacional(HistoricoFiltro filtro) {
    final temFiltroExtra =
        filtro.tipo != HistoricoTipo.todos ||
        filtro.statusCodigo != null ||
        (filtro.periodo != HistoricoPeriodo.todos &&
            filtro.periodo != HistoricoPeriodo.proximos7);

    if (!temFiltroExtra) {
      return const SolicitacoesEmptyStateInfo(
        mensagem: 'Nenhuma solicitação nos próximos dias',
        submensagem:
            'Novas solicitações aparecerão aqui quando forem cadastradas.',
        mostrarLimparFiltros: false,
      );
    }

    final status = _statusLabel(filtro.statusCodigo);
    return SolicitacoesEmptyStateInfo(
      mensagem: status == null
          ? 'Nenhum resultado encontrado'
          : 'Nenhuma solicitação $status encontrada',
      submensagem:
          'Tente ajustar os filtros ou limpe-os para ver outras solicitações.',
      mostrarLimparFiltros: true,
    );
  }

  static String? _statusLabel(String? codigo) {
    switch (codigo) {
      case 'A':
        return 'aprovada';
      case 'P':
        return 'pendente';
      case 'R':
        return 'reprovada';
      case 'C':
        return 'cancelada';
      default:
        return null;
    }
  }
}
