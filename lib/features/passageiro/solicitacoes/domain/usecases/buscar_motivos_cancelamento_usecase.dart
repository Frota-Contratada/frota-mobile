import '../entities/motivo.dart';
import '../repositories/solicitacoes_repository.dart';

class BuscarMotivosCancelamentoUsecase {
  final SolicitacoesRepository repository;

  BuscarMotivosCancelamentoUsecase(this.repository);

  Future<List<Motivo>> call() => repository.buscarMotivosCancelamento();
}
