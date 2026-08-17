import '../../../solicitacoes/domain/entities/solicitacao.dart';
import '../entities/catalogos_solicitacao.dart';
import '../entities/nova_solicitacao.dart';
import '../entities/simulacao_solicitacao.dart';

abstract class SolicitacaoRepository {
  Future<CatalogosSolicitacao> buscarCatalogos();

  Future<SimulacaoSolicitacao> simular(NovaSolicitacao nova);

  Future<Solicitacao> criar(NovaSolicitacao nova);
}
