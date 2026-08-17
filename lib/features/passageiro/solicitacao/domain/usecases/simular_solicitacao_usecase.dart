import '../entities/nova_solicitacao.dart';
import '../entities/simulacao_solicitacao.dart';
import '../repositories/solicitacao_repository.dart';

class SimularSolicitacaoUsecase {
  final SolicitacaoRepository repository;

  SimularSolicitacaoUsecase(this.repository);

  Future<SimulacaoSolicitacao> call(NovaSolicitacao nova) =>
      repository.simular(nova);
}
