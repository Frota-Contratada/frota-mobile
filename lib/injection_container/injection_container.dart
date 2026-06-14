import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_injection.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // Features
  registerAuthDependencies(sl);
}