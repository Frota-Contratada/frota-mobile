import '../../../../../core/error/exceptions.dart';
import '../../../../../core/error/failures.dart';
import '../../domain/entities/motivo.dart';
import '../../domain/entities/solicitacao.dart';
import '../../domain/entities/status_solicitacao.dart';
import '../../domain/repositories/solicitacoes_repository.dart';
import '../datasources/solicitacoes_remote_datasource.dart';

const _tipoMotivoCancelamento = '2';

class SolicitacoesRepositoryImpl implements SolicitacoesRepository {
  final SolicitacoesRemoteDatasource remoteDatasource;

  SolicitacoesRepositoryImpl({required this.remoteDatasource});

  @override
  Future<PaginaSolicitacoes> buscarVarias({
    StatusSolicitacao? status,
    DateTime? dataInicio,
    DateTime? dataFim,
    int page = 1,
    int limit = 50,
  }) {
    return _handleRemoteCall(
      () => remoteDatasource.buscarVarias(
        status: status,
        dataInicio: dataInicio,
        dataFim: dataFim,
        page: page,
        limit: limit,
      ),
    );
  }

  @override
  Future<Solicitacao> buscar(int id) {
    return _handleRemoteCall(() => remoteDatasource.buscar(id));
  }

  @override
  Future<Solicitacao> cancelar({
    required int id,
    required int motivoCancelamentoId,
  }) {
    return _handleRemoteCall(
      () => remoteDatasource.cancelar(
        id: id,
        motivoCancelamentoId: motivoCancelamentoId,
      ),
    );
  }

  @override
  Future<List<Motivo>> buscarMotivosCancelamento() {
    return _handleRemoteCall(
      () => remoteDatasource.buscarMotivos(_tipoMotivoCancelamento),
    );
  }

  Future<T> _handleRemoteCall<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }
}
