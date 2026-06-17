import 'package:get_it/get_it.dart';
import '../features/auth/data/datasources/auth_local_datasource.dart';
import '../features/auth/data/datasources/auth_remote_datasource.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/domain/usecases/buscar_usuario_atual_usecase.dart';
import '../features/auth/domain/usecases/login_usecase.dart';
import '../features/auth/domain/usecases/logout_usecase.dart';
import '../features/auth/presentation/bloc/auth.bloc.dart';

void registerAuthDependencies(GetIt sl) {
  // Datasources
  // Vamos trocar [AuthRemoteDatasourceMock] por [AuthRemoteDatasourceImpl] quando a API estiver pronta
  sl.registerLazySingleton<AuthRemoteDatasource>(
    () => AuthRemoteDatasourceMock(),
  );

  sl.registerLazySingleton<AuthLocalDatasource>(
    () => AuthLocalDatasourceImpl(sharedPreferences: sl()),
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDatasource: sl(),
      localDatasource: sl(),
    ),
  );

  // Usecases
  sl.registerLazySingleton(() => BuscarUsuarioAtualUsecase(sl()));
  sl.registerLazySingleton(() => LoginUsecase(sl()));
  sl.registerLazySingleton(() => LogoutUsecase(sl()));

  // Bloc
  sl.registerFactory(
    () => AuthBloc(
      buscarUsuarioAtualUsecase: sl(),
      loginUsecase: sl(),
      logoutUsecase: sl(),
    ),
  );
}