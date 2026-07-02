import 'package:get_it/get_it.dart';
import '../features/motorista/corrida/data/datasources/corrida_remote_datasource.dart';
import '../features/motorista/corrida/data/repositories/corrida_repository_impl.dart';
import '../features/motorista/corrida/domain/repositories/corrida_repository.dart';
import '../features/motorista/corrida/domain/usecases/buscar_corrida_detalhe_usecase.dart';
import '../features/motorista/corrida/domain/usecases/iniciar_corrida_usecase.dart';
import '../features/motorista/corrida/presentation/bloc/corrida.bloc.dart';

void registerMotoristaCorridaDependencies(GetIt sl) {
  // Datasources
  // Vamos trocar [CorridaRemoteDatasourceMock] por [CorridaRemoteDatasourceImpl] quando a API estiver pronta:
  // CorridaRemoteDatasourceImpl(dio: sl(), corridasBaseUrl: Env.motoristaCorridasBaseUrl)
  sl.registerLazySingleton<CorridaRemoteDatasource>(
    () => CorridaRemoteDatasourceMock(),
  );

  // Repository
  sl.registerLazySingleton<CorridaRepository>(
    () => CorridaRepositoryImpl(remoteDatasource: sl()),
  );

  // Usecases
  sl.registerLazySingleton(() => BuscarCorridaDetalheUsecase(sl()));
  sl.registerLazySingleton(() => IniciarCorridaUsecase(sl()));

  // Bloc
  sl.registerFactory(
    () => CorridaBloc(
      buscarCorridaDetalheUsecase: sl(),
      iniciarCorridaUsecase: sl(),
    ),
  );
}
