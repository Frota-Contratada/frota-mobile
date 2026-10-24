import 'package:flutter_test/flutter_test.dart';
import 'package:frota_mobile/core/widgets/historico_filtro.dart';
import 'package:frota_mobile/core/widgets/solicitacoes_empty_state.dart';

void main() {
  test('usa mensagem operacional para a janela padrão sem filtros extras', () {
    final info = SolicitacoesEmptyStateInfo.operacional(
      HistoricoFiltro(
        ordenacao: HistoricoOrdenacao.maisAntiga,
        periodo: HistoricoPeriodo.proximos7,
      ),
    );

    expect(info.mensagem, 'Nenhuma solicitação nos próximos dias');
    expect(info.mostrarLimparFiltros, isFalse);
  });

  test('sugere limpar filtros quando o resultado foi restringido', () {
    final info = SolicitacoesEmptyStateInfo.operacional(
      HistoricoFiltro(periodo: HistoricoPeriodo.hoje, statusCodigo: 'P'),
    );

    expect(info.mensagem, 'Nenhuma solicitação pendente encontrada');
    expect(info.mostrarLimparFiltros, isTrue);
  });
}
