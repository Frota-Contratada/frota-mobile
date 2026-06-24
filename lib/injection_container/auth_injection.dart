import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../../config/env.dart';
import '../../core/network/dio_factory.dart';
import '../features/auth/data/datasources/auth_local_datasource.dart';
import '../features/auth/data/datasources/auth_remote_datasource.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/domain/usecases/confirmar_pin_usecase.dart';
import '../features/auth/domain/usecases/enviar_pin_email_usecase.dart';
import '../features/auth/domain/usecases/login_usecase.dart';
import '../features/auth/domain/usecases/logout_usecase.dart';
import '../features/auth/domain/usecases/redefinir_senha_usecase.dart';
import '../features/auth/domain/usecases/sign_up_usecase.dart';
import '../features/auth/domain/usecases/verificar_email_usecase.dart';
import '../features/auth/presentation/bloc/auth.bloc.dart';

void registerAuthDependencies(GetIt sl) {
  sl.registerLazySingleton<Dio>(() => createDio());

  sl.registerLazySingleton<AuthRemoteDatasource>(
    () => AuthRemoteDatasourceImpl(dio: sl(), authBaseUrl: Env.authBaseUrl),
  );

  sl.registerLazySingleton<AuthLocalDatasource>(
    () => AuthLocalDatasourceImpl(sharedPreferences: sl()),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDatasource: sl(), localDatasource: sl()),
  );

  sl.registerLazySingleton(() => VerificarEmailUsecase(sl()));
  sl.registerLazySingleton(() => LoginUsecase(sl()));
  sl.registerLazySingleton(() => SignUpUsecase(sl()));
  sl.registerLazySingleton(() => LogoutUsecase(sl()));
  sl.registerLazySingleton(() => EnviarPinEmailUsecase(sl()));
  sl.registerLazySingleton(() => ConfirmarPinUsecase(sl()));
  sl.registerLazySingleton(() => RedefinirSenhaUsecase(sl()));

  sl.registerFactory(
    () => AuthBloc(
      verificarEmailUsecase: sl(),
      loginUsecase: sl(),
      signUpUsecase: sl(),
      logoutUsecase: sl(),
      confirmarPinUsecase: sl(),
      enviarPinEmailUsecase: sl(),
      redefinirSenhaUsecase: sl(),
    ),
  );
}
