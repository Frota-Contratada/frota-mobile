import 'package:get_it/get_it.dart';
import '../features/passageiro/home/data/datasources/home_remote_datasource.dart';
import '../features/passageiro/home/data/repositories/home_repository_impl.dart';
import '../features/passageiro/home/domain/repositories/home_repository.dart';
import '../features/passageiro/home/domain/usecases/buscar_viagens_por_semana_usecase.dart';
import '../features/passageiro/home/presentation/bloc/home.bloc.dart';

void registerPassageiroHomeDependencies(GetIt sl) {
  sl.registerLazySingleton<PassageiroHomeRemoteDatasource>(
    () => PassageiroHomeRemoteDatasourceMock(),
  );

  sl.registerLazySingleton<PassageiroHomeRepository>(
    () => PassageiroHomeRepositoryImpl(remoteDatasource: sl()),
  );

  sl.registerLazySingleton(() => PassageiroBuscarViagensPorSemanaUsecase(sl()));

  sl.registerFactory(
    () => PassageiroHomeBloc(buscarViagensPorSemanaUsecase: sl()),
  );
}
