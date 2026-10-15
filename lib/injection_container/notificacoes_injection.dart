import 'package:get_it/get_it.dart';
import '../config/env.dart';
import '../core/navigation/app_navigator.dart';
import '../features/notificacoes/data/datasources/notificacoes_locais_datasource.dart';
import '../features/notificacoes/data/datasources/notificacoes_remote_datasource.dart';
import '../features/notificacoes/data/datasources/notificacoes_socket_datasource.dart';
import '../features/notificacoes/data/datasources/preferencias_notificacao_remote_datasource.dart';
import '../features/notificacoes/data/repositories/notificacoes_dispositivo_repository_impl.dart';
import '../features/notificacoes/data/repositories/notificacoes_repository_impl.dart';
import '../features/notificacoes/data/repositories/notificacoes_segundo_plano_repository_impl.dart';
import '../features/notificacoes/data/repositories/preferencias_notificacao_repository_impl.dart';
import '../features/notificacoes/domain/repositories/notificacoes_dispositivo_repository.dart';
import '../features/notificacoes/domain/repositories/notificacoes_repository.dart';
import '../features/notificacoes/domain/repositories/notificacoes_segundo_plano_repository.dart';
import '../features/notificacoes/domain/repositories/preferencias_notificacao_repository.dart';
import '../features/notificacoes/domain/usecases/atualizar_preferencia_notificacao_usecase.dart';
import '../features/notificacoes/domain/usecases/buscar_notificacoes_usecase.dart';
import '../features/notificacoes/domain/usecases/buscar_preferencias_notificacao_usecase.dart';
import '../features/notificacoes/domain/usecases/contar_notificacoes_nao_lidas_usecase.dart';
import '../features/notificacoes/domain/usecases/marcar_notificacao_como_lida_usecase.dart';
import '../features/notificacoes/presentation/bloc/notificacoes_bloc.dart';
import '../features/notificacoes/presentation/bloc/preferencias_notificacao_bloc.dart';
import '../features/notificacoes/presentation/sessao/notificacoes_sessao_controller.dart';

const _instanciaSessao = 'sessao';

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

  sl.registerLazySingleton<NotificacoesRepository>(
    () => NotificacoesRepositoryImpl(
      remoteDatasource: sl(),
      socketDatasource: sl(),
    ),
    instanceName: _instanciaSessao,
  );

  sl.registerLazySingleton<PreferenciasNotificacaoRemoteDatasource>(
    () => PreferenciasNotificacaoRemoteDatasourceImpl(
      dio: sl(),
      notificacoesBaseUrl: Env.notificacoesBaseUrl,
    ),
  );

  sl.registerLazySingleton<PreferenciasNotificacaoRepository>(
    () => PreferenciasNotificacaoRepositoryImpl(remoteDatasource: sl()),
  );

  sl.registerLazySingleton<NotificacoesLocaisDatasource>(
    FlutterNotificacoesLocaisDatasource.new,
  );

  sl.registerLazySingleton<NotificacoesDispositivoRepository>(
    () => NotificacoesDispositivoRepositoryImpl(datasource: sl()),
  );

  sl.registerLazySingleton<NotificacoesSegundoPlanoRepository>(
    () => NotificacoesSegundoPlanoRepositoryImpl(
      notificacoesBaseUrl: Env.notificacoesBaseUrl,
      authBaseUrl: Env.authBaseUrl,
    ),
  );

  sl.registerLazySingleton(() => BuscarNotificacoesUsecase(sl()));
  sl.registerLazySingleton(() => ContarNotificacoesNaoLidasUsecase(sl()));
  sl.registerLazySingleton(() => MarcarNotificacaoComoLidaUsecase(sl()));
  sl.registerLazySingleton(() => BuscarPreferenciasNotificacaoUsecase(sl()));
  sl.registerLazySingleton(() => AtualizarPreferenciaNotificacaoUsecase(sl()));

  sl.registerLazySingleton(
    () => NotificacoesSessaoController(
      notificacoesRepository: sl(instanceName: _instanciaSessao),
      dispositivoRepository: sl(),
      preferenciasRepository: sl(),
      segundoPlanoRepository: sl(),
      buscarPreferencias: sl(),
      marcarComoLida: sl(),
      navigatorKey: appNavigatorKey,
    ),
  );

  sl.registerFactory(
    () => NotificacoesBloc(
      buscarNotificacoesUsecase: sl(),
      contarNotificacoesNaoLidasUsecase: sl(),
      marcarNotificacaoComoLidaUsecase: sl(),
      repository: sl(),
    ),
  );

  sl.registerFactory(
    () => PreferenciasNotificacaoBloc(
      buscarPreferencias: sl(),
      atualizarPreferencia: sl(),
    ),
  );
}
