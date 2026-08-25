import '../../../solicitacoes/domain/entities/solicitacao.dart';
import '../entities/nova_solicitacao.dart';
import '../repositories/solicitacao_repository.dart';

class CriarSolicitacaoUsecase {
  final SolicitacaoRepository repository;

  CriarSolicitacaoUsecase(this.repository);

  Future<Solicitacao> call(NovaSolicitacao nova) => repository.criar(nova);
}
