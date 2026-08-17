import '../entities/solicitacao.dart';
import '../repositories/solicitacoes_repository.dart';

class BuscarSolicitacaoUsecase {
  final SolicitacoesRepository repository;

  BuscarSolicitacaoUsecase(this.repository);

  Future<Solicitacao> call(int id) => repository.buscar(id);
}
