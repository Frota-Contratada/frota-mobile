import '../../../../../core/error/exceptions.dart';
import '../../../../../core/error/failures.dart';
import '../../../solicitacoes/domain/entities/solicitacao.dart';
import '../../domain/entities/catalogos_solicitacao.dart';
import '../../domain/entities/nova_solicitacao.dart';
import '../../domain/entities/simulacao_solicitacao.dart';
import '../../domain/repositories/solicitacao_repository.dart';
import '../datasources/solicitacao_remote_datasource.dart';

class SolicitacaoRepositoryImpl implements SolicitacaoRepository {
  final SolicitacaoRemoteDatasource remoteDatasource;

  SolicitacaoRepositoryImpl({required this.remoteDatasource});

  @override
  Future<CatalogosSolicitacao> buscarCatalogos() {
    return _handleRemoteCall(() => remoteDatasource.buscarCatalogos());
  }

  @override
  Future<SimulacaoSolicitacao> simular(NovaSolicitacao nova) {
    return _handleRemoteCall(() => remoteDatasource.simular(nova));
  }

  @override
  Future<Solicitacao> criar(NovaSolicitacao nova) {
    return _handleRemoteCall(() => remoteDatasource.criar(nova));
  }

  Future<T> _handleRemoteCall<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }
}
