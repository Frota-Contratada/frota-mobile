import '../entities/solicitacao.dart';
import '../entities/status_solicitacao.dart';
import '../repositories/solicitacoes_repository.dart';

class BuscarSolicitacoesUsecase {
  final SolicitacoesRepository repository;

  BuscarSolicitacoesUsecase(this.repository);

  Future<PaginaSolicitacoes> call({
    StatusSolicitacao? status,
    int page = 1,
    int limit = 50,
  }) {
    return repository.buscarVarias(status: status, page: page, limit: limit);
  }
}
