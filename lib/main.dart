import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'config/themes.dart';
import 'config/routes.dart';
import 'features/auth/presentation/bloc/auth.bloc.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'injection_container/injection_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(const FrotaApp());
}

class FrotaApp extends StatelessWidget {
  const FrotaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Frota Mobile',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      initialRoute: AppRoutes.login,
      routes: {
        AppRoutes.login: (_) => BlocProvider(
              create: (_) => sl<AuthBloc>(),
              child: const LoginPage(),
            ),
        AppRoutes.home: (_) => const HomePage(),
      },
    );
  }
}