import 'package:get_it/get_it.dart';
import '../config/env.dart';
import '../features/notificacoes/data/datasources/notificacoes_remote_datasource.dart';
import '../features/notificacoes/data/datasources/notificacoes_socket_datasource.dart';
import '../features/notificacoes/data/repositories/notificacoes_repository_impl.dart';
import '../features/notificacoes/domain/repositories/notificacoes_repository.dart';
import '../features/notificacoes/domain/usecases/buscar_notificacoes_usecase.dart';
import '../features/notificacoes/domain/usecases/contar_notificacoes_nao_lidas_usecase.dart';
import '../features/notificacoes/domain/usecases/marcar_notificacao_como_lida_usecase.dart';
import '../features/notificacoes/presentation/bloc/notificacoes_bloc.dart';

void registerNotificacoesDependencies(GetIt sl) {
  sl.registerLazySingleton<NotificacoesRemoteDatasource>(
    () => NotificacoesRemoteDatasourceImpl(
      dio: sl(),
      notificacoesBaseUrl: Env.notificacoesBaseUrl,
    ),
  );

  sl.registerFactory<NotificacoesSocketDatasource>(
    () => NotificacoesSocketDatasourceImpl(
      notificacoesBaseUrl: Env.notificacoesBaseUrl,
      authLocalDatasource: sl(),
      authTokenProvider: sl(),
    ),
  );

  sl.registerLazySingleton<NotificacoesRepository>(
    () => NotificacoesRepositoryImpl(
      remoteDatasource: sl(),
      socketDatasource: sl(),
    ),
  );

  sl.registerLazySingleton(() => BuscarNotificacoesUsecase(sl()));
  sl.registerLazySingleton(() => ContarNotificacoesNaoLidasUsecase(sl()));
  sl.registerLazySingleton(() => MarcarNotificacaoComoLidaUsecase(sl()));

  sl.registerFactory(
    () => NotificacoesBloc(
      buscarNotificacoesUsecase: sl(),
      contarNotificacoesNaoLidasUsecase: sl(),
      marcarNotificacaoComoLidaUsecase: sl(),
      repository: sl(),
    ),
  );
}
