import 'package:get_it/get_it.dart';
import '../config/env.dart';
import '../core/maps/endereco_autocomplete_service.dart';
import '../core/maps/routing_service.dart';
import '../features/passageiro/solicitacao/data/datasources/solicitacao_remote_datasource.dart';
import '../features/passageiro/solicitacao/data/repositories/solicitacao_repository_impl.dart';
import '../features/passageiro/solicitacao/domain/repositories/solicitacao_repository.dart';
import '../features/passageiro/solicitacao/domain/usecases/buscar_catalogos_usecase.dart';
import '../features/passageiro/solicitacao/domain/usecases/criar_solicitacao_usecase.dart';
import '../features/passageiro/solicitacao/domain/usecases/simular_solicitacao_usecase.dart';
import '../features/passageiro/solicitacao/presentation/bloc/criar_solicitacao.bloc.dart';

void registerPassageiroSolicitacaoDependencies(GetIt sl) {
  mapRoutingService = BackendRoutingService(
    dio: sl(),
    url: Env.rotaSolicitacaoUrl,
  );
  enderecoAutocompleteService = BackendEnderecoAutocompleteService(
    dio: sl(),
    url: Env.sugestoesEnderecoUrl,
  );

  sl.registerLazySingleton<SolicitacaoRemoteDatasource>(
    () => SolicitacaoRemoteDatasourceImpl(
      dio: sl(),
      solicitacoesBaseUrl: Env.solicitacoesBaseUrl,
      centrosCustoBaseUrl: Env.centrosCustoBaseUrl,
    ),
  );

  sl.registerLazySingleton<SolicitacaoRepository>(
    () => SolicitacaoRepositoryImpl(remoteDatasource: sl()),
  );

  sl.registerLazySingleton(() => BuscarCatalogosUsecase(sl()));
  sl.registerLazySingleton(() => SimularSolicitacaoUsecase(sl()));
  sl.registerLazySingleton(() => CriarSolicitacaoUsecase(sl()));

  sl.registerFactory(
    () => CriarSolicitacaoBloc(
      buscarCatalogosUsecase: sl(),
      simularSolicitacaoUsecase: sl(),
      criarSolicitacaoUsecase: sl(),
      buscarUsuarioAtualUsecase: sl(),
    ),
  );
}
