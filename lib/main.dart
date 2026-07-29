import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'config/env_loader.dart';
import 'config/themes.dart';
import 'config/routes.dart';
import 'features/auth/presentation/bloc/auth.bloc.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/domain/entities/usuario.dart';
import 'features/motorista/configuracoes/presentation/pages/configuracoes_page.dart';
import 'features/motorista/corrida/presentation/pages/corrida_detalhe_page.dart';
import 'features/motorista/home/presentation/pages/home_page.dart';
import 'features/motorista/perfil/presentation/pages/perfil_page.dart';
import 'features/passageiro/configuracoes/presentation/pages/configuracoes_page.dart';
import 'features/passageiro/shared/presentation/pages/passageiro_shell_page.dart';
import 'injection_container/injection_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadEnvironment();
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
      themeMode: ThemeMode.light,
      initialRoute: AppRoutes.login,
      routes: {
        AppRoutes.login: (_) => BlocProvider(
              create: (_) => sl<AuthBloc>(),
              child: const LoginPage(),
            ),
        AppRoutes.motoristaHome: (_) => const HomePage(),
        AppRoutes.motoristaCorridaDetalhe: (_) => const CorridaDetalhePage(),
        AppRoutes.motoristaPerfil: (_) => const MotoristPerfilPage(),
        AppRoutes.motoristaConfiguracoes: (_) =>
            const MotoristaConfiguracoesPage(),
        AppRoutes.passageiroHome: (context) {
          final usuario =
              ModalRoute.of(context)?.settings.arguments as Usuario?;
          return PassageiroShellPage(usuario: usuario);
        },
        AppRoutes.passageiroConfiguracoes: (_) =>
            const PassageiroConfiguracoesPage(),
      },
    );
  }
}
