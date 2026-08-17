import 'package:get_it/get_it.dart';
import '../config/env.dart';
import '../features/passageiro/solicitacoes/data/datasources/solicitacoes_remote_datasource.dart';
import '../features/passageiro/solicitacoes/data/repositories/solicitacoes_repository_impl.dart';
import '../features/passageiro/solicitacoes/domain/repositories/solicitacoes_repository.dart';
import '../features/passageiro/solicitacoes/domain/usecases/buscar_motivos_cancelamento_usecase.dart';
import '../features/passageiro/solicitacoes/domain/usecases/buscar_solicitacao_usecase.dart';
import '../features/passageiro/solicitacoes/domain/usecases/buscar_solicitacoes_usecase.dart';
import '../features/passageiro/solicitacoes/domain/usecases/cancelar_solicitacao_usecase.dart';
import '../features/passageiro/solicitacoes/presentation/bloc/detalhe_solicitacao.bloc.dart';
import '../features/passageiro/solicitacoes/presentation/bloc/solicitacoes.bloc.dart';

void registerPassageiroSolicitacoesDependencies(GetIt sl) {
  sl.registerLazySingleton<SolicitacoesRemoteDatasource>(
    () => SolicitacoesRemoteDatasourceImpl(
      dio: sl(),
      solicitacoesBaseUrl: Env.solicitacoesBaseUrl,
    ),
  );

  sl.registerLazySingleton<SolicitacoesRepository>(
    () => SolicitacoesRepositoryImpl(remoteDatasource: sl()),
  );

  sl.registerLazySingleton(() => BuscarSolicitacoesUsecase(sl()));
  sl.registerLazySingleton(() => BuscarSolicitacaoUsecase(sl()));
  sl.registerLazySingleton(() => CancelarSolicitacaoUsecase(sl()));
  sl.registerLazySingleton(() => BuscarMotivosCancelamentoUsecase(sl()));

  sl.registerFactory(() => SolicitacoesBloc(buscarSolicitacoesUsecase: sl()));

  sl.registerFactory(
    () => DetalheSolicitacaoBloc(
      buscarSolicitacaoUsecase: sl(),
      cancelarSolicitacaoUsecase: sl(),
      buscarMotivosCancelamentoUsecase: sl(),
    ),
  );
}
