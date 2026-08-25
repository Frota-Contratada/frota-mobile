import '../entities/catalogos_solicitacao.dart';
import '../repositories/solicitacao_repository.dart';

class BuscarCatalogosUsecase {
  final SolicitacaoRepository repository;

  BuscarCatalogosUsecase(this.repository);

  Future<CatalogosSolicitacao> call() => repository.buscarCatalogos();
}
