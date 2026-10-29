import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'config/env_loader.dart';
import 'config/env.dart';
import 'core/navigation/app_navigator.dart';
import 'core/navigation/app_route_observer.dart';
import 'core/responsive/escala_tela.dart';
import 'config/themes.dart';
import 'config/routes.dart';
import 'features/auth/presentation/bloc/auth.bloc.dart';
import 'features/auth/presentation/bloc/splash_cubit.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/splash_page.dart';
import 'features/auth/domain/entities/usuario.dart';
import 'features/motorista/configuracoes/presentation/pages/configuracoes_page.dart';
import 'features/motorista/corrida/presentation/pages/corrida_detalhe_page.dart';
import 'features/motorista/home/presentation/pages/home_page.dart';
import 'features/motorista/perfil/presentation/pages/perfil_page.dart';
import 'features/passageiro/configuracoes/presentation/pages/configuracoes_page.dart';
import 'features/shared/trip_tracking/presentation/pages/trip_webview_page.dart';
import 'features/passageiro/shared/presentation/pages/passageiro_shell_page.dart';
import 'features/passageiro/solicitacao/presentation/bloc/criar_solicitacao.bloc.dart';
import 'features/passageiro/solicitacao/presentation/pages/solicitar_viagem_page.dart';
import 'features/passageiro/solicitacao/presentation/pages/solicitar_viagem_route_args.dart';
import 'features/passageiro/solicitacao/presentation/pages/solicitar_objeto_page.dart';
import 'features/passageiro/solicitacoes/presentation/pages/detalhe_solicitacao_page.dart';
import 'features/notificacoes/presentation/bloc/notificacoes_bloc.dart';
import 'features/notificacoes/presentation/bloc/preferencias_notificacao_bloc.dart';
import 'features/notificacoes/presentation/pages/notificacoes_page.dart';
import 'injection_container/injection_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterForegroundTask.initCommunicationPort();
  await loadEnvironment();
  Env.validateRelease();
  await initDependencies();
  runApp(const FrotaApp());
}

class FrotaApp extends StatelessWidget {
  const FrotaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Frota Contratada',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      themeMode: ThemeMode.light,
      navigatorKey: appNavigatorKey,
      navigatorObservers: [appRouteObserver],
      builder: (_, child) => EscalaTela(child: child ?? const SizedBox()),
      home: BlocProvider(
        create: (_) => sl<SplashCubit>()..iniciar(),
        child: const SplashPage(),
      ),
      routes: {
        AppRoutes.login: (_) => BlocProvider(
          create: (_) => sl<AuthBloc>(),
          child: const LoginPage(),
        ),
        AppRoutes.motoristaHome: (_) => const HomePage(),
        AppRoutes.motoristaCorridaDetalhe: (_) => const CorridaDetalhePage(),
        AppRoutes.motoristaPerfil: (_) => const MotoristPerfilPage(),
        AppRoutes.motoristaConfiguracoes: (_) => BlocProvider(
          create: (_) =>
              sl<PreferenciasNotificacaoBloc>()
                ..add(const PreferenciasNotificacaoCarregadas()),
          child: const MotoristaConfiguracoesPage(),
        ),
        AppRoutes.passageiroHome: (context) {
          final usuario =
              ModalRoute.of(context)?.settings.arguments as Usuario?;
          return PassageiroShellPage(usuario: usuario);
        },
        AppRoutes.passageiroConfiguracoes: (_) => BlocProvider(
          create: (_) =>
              sl<PreferenciasNotificacaoBloc>()
                ..add(const PreferenciasNotificacaoCarregadas()),
          child: const PassageiroConfiguracoesPage(),
        ),
        AppRoutes.notificacoes: (context) {
          final usuario =
              ModalRoute.of(context)?.settings.arguments as Usuario?;
          return BlocProvider(
            create: (_) =>
                sl<NotificacoesBloc>()..add(const NotificacoesCarregadas()),
            child: NotificacoesPage(usuario: usuario),
          );
        },
        AppRoutes.passageiroSolicitarViagem: (context) {
          final arguments = ModalRoute.of(context)?.settings.arguments;
          final routeArgs = arguments is SolicitarViagemRouteArgs
              ? arguments
              : null;

          return BlocProvider(
            create: (_) =>
                sl<CriarSolicitacaoBloc>()..add(const CatalogosSolicitados()),
            child: SolicitarViagemPage(routeArgs: routeArgs),
          );
        },
        AppRoutes.passageiroSolicitarObjeto: (_) => BlocProvider(
          create: (_) =>
              sl<CriarSolicitacaoBloc>()..add(const CatalogosSolicitados()),
          child: const SolicitarObjetoPage(),
        ),
        AppRoutes.passageiroCorridaAndamento: (context) => TripWebViewPage(
          args: ModalRoute.of(context)!.settings.arguments as TripWebViewArgs,
        ),
        AppRoutes.tripWebView: (context) => TripWebViewPage(
          args: ModalRoute.of(context)!.settings.arguments as TripWebViewArgs,
        ),
        AppRoutes.passageiroDetalheSolicitacao: (context) {
          // A tela carrega os dados pelo id; telas que ainda usam mock passam
          // outro tipo de argumento e caem no estado de indisponível.
          final args = ModalRoute.of(context)?.settings.arguments;
          return DetalheSolicitacaoPage(
            solicitacaoId: args is int ? args : null,
          );
        },
      },
    );
  }
}
