import '../entities/motivo.dart';
import '../entities/solicitacao.dart';
import '../entities/status_solicitacao.dart';

abstract class SolicitacoesRepository {
  Future<PaginaSolicitacoes> buscarVarias({
    StatusSolicitacao? status,
    DateTime? dataInicio,
    DateTime? dataFim,
    int page,
    int limit,
  });

  Future<Solicitacao> buscar(int id);

  Future<Solicitacao> cancelar({
    required int id,
    required int motivoCancelamentoId,
  });

  Future<List<Motivo>> buscarMotivosCancelamento();
}
