import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_injection.dart';
import 'motorista_corrida_injection.dart';
import 'motorista_home_injection.dart';
import 'motorista_perfil_injection.dart';
import 'passageiro_home_injection.dart';
import 'passageiro_solicitacao_injection.dart';
import 'passageiro_solicitacoes_injection.dart';
import 'trip_tracking_injection.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // Features
  registerAuthDependencies(sl);
  registerMotoristaHomeDependencies(sl);
  registerMotoristaCorridaDependencies(sl);
  registerMotoristaPerfilDependencies(sl);
  registerPassageiroHomeDependencies(sl);
  registerPassageiroSolicitacoesDependencies(sl);
  registerPassageiroSolicitacaoDependencies(sl);
  registerTripTrackingDependencies(sl);
}
