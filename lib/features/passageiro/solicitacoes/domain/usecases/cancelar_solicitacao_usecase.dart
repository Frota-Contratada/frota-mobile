import '../entities/solicitacao.dart';
import '../repositories/solicitacoes_repository.dart';

class CancelarSolicitacaoUsecase {
  final SolicitacoesRepository repository;

  CancelarSolicitacaoUsecase(this.repository);

  Future<Solicitacao> call({
    required int id,
    required int motivoCancelamentoId,
  }) {
    return repository.cancelar(
      id: id,
      motivoCancelamentoId: motivoCancelamentoId,
    );
  }
}
