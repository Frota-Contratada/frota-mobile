import 'package:get_it/get_it.dart';
import '../config/env.dart';
import '../features/motorista/perfil/data/datasources/motorista_perfil_remote_datasource.dart';
import '../features/motorista/perfil/data/repositories/motorista_perfil_repository_impl.dart';
import '../features/motorista/perfil/domain/repositories/motorista_perfil_repository.dart';
import '../features/motorista/perfil/domain/usecases/buscar_motorista_perfil_usecase.dart';
import '../features/motorista/perfil/presentation/bloc/motorista_perfil.bloc.dart';

void registerMotoristaPerfilDependencies(GetIt sl) {
  sl.registerLazySingleton<MotoristaPerfilRemoteDatasource>(
    () => MotoristaPerfilRemoteDatasourceImpl(
      dio: sl(),
      perfilBaseUrl: Env.motoristaPerfilBaseUrl,
    ),
  );

  sl.registerLazySingleton<MotoristaPerfilRepository>(
    () => MotoristaPerfilRepositoryImpl(remoteDatasource: sl()),
  );

  sl.registerLazySingleton(() => BuscarMotoristaPerfilUsecase(sl()));

  sl.registerFactory(
    () => MotoristaPerfilBloc(buscarMotoristaPerfilUsecase: sl()),
  );
}
