import 'package:get_it/get_it.dart';
import '../features/motorista/home/data/datasources/home_remote_datasource.dart';
import '../features/motorista/home/data/repositories/home_repository_impl.dart';
import '../features/motorista/home/domain/repositories/home_repository.dart';
import '../features/motorista/home/domain/usecases/buscar_viagens_por_semana_usecase.dart';
import '../features/motorista/home/presentation/bloc/home.bloc.dart';

void registerMotoristaHomeDependencies(GetIt sl) {
  // Datasources
  // Vamos trocar [HomeRemoteDatasourceMock] por [HomeRemoteDatasourceImpl] quando a API estiver pronta:
  // HomeRemoteDatasourceImpl(dio: sl(), viagensBaseUrl: Env.motoristaViagensBaseUrl)
  sl.registerLazySingleton<HomeRemoteDatasource>(
    () => HomeRemoteDatasourceMock(),
  );

  // Repository
  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(remoteDatasource: sl()),
  );

  // Usecases
  sl.registerLazySingleton(() => BuscarViagensPorSemanaUsecase(sl()));

  // Bloc
  sl.registerFactory(
    () => HomeBloc(buscarViagensPorSemanaUsecase: sl()),
  );
}
