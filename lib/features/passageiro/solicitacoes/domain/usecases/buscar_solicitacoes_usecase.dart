import '../entities/solicitacao.dart';
import '../entities/status_solicitacao.dart';
import '../repositories/solicitacoes_repository.dart';

class BuscarSolicitacoesUsecase {
  final SolicitacoesRepository repository;

  BuscarSolicitacoesUsecase(this.repository);

  Future<PaginaSolicitacoes> call({
    StatusSolicitacao? status,
    DateTime? dataInicio,
    DateTime? dataFim,
    int page = 1,
    int limit = 50,
    bool historico = false,
    bool incluirAnteriores = false,
  }) {
    return repository.buscarVarias(
      status: status,
      dataInicio: dataInicio,
      dataFim: dataFim,
      page: page,
      limit: limit,
      historico: historico,
      incluirAnteriores: incluirAnteriores,
    );
  }
}
