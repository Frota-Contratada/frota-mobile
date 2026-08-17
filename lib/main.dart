import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'config/env_loader.dart';
import 'config/themes.dart';
import 'config/routes.dart';
import 'features/auth/presentation/bloc/auth.bloc.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/domain/entities/usuario.dart';
import 'core/maps/map_point.dart';
import 'features/motorista/configuracoes/presentation/pages/configuracoes_page.dart';
import 'features/motorista/corrida/presentation/pages/corrida_detalhe_page.dart';
import 'features/motorista/home/presentation/pages/home_page.dart';
import 'features/motorista/perfil/presentation/pages/perfil_page.dart';
import 'features/passageiro/configuracoes/presentation/pages/configuracoes_page.dart';
import 'features/passageiro/corrida/presentation/pages/corrida_andamento_page.dart';
import 'features/passageiro/shared/presentation/pages/passageiro_shell_page.dart';
import 'features/passageiro/solicitacao/presentation/bloc/criar_solicitacao.bloc.dart';
import 'features/passageiro/solicitacao/presentation/pages/solicitar_viagem_page.dart';
import 'features/passageiro/solicitacao/presentation/pages/solicitar_objeto_page.dart';
import 'features/passageiro/solicitacoes/presentation/pages/detalhe_solicitacao_page.dart';
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
        // O bloc é criado na entrada do wizard e repassado aos passos
        // seguintes, para que catálogos e envio compartilhem o mesmo estado.
        AppRoutes.passageiroSolicitarViagem: (_) => BlocProvider(
          create: (_) =>
              sl<CriarSolicitacaoBloc>()..add(const CatalogosSolicitados()),
          child: const SolicitarViagemPage(),
        ),
        AppRoutes.passageiroSolicitarObjeto: (_) => BlocProvider(
          create: (_) =>
              sl<CriarSolicitacaoBloc>()..add(const CatalogosSolicitados()),
          child: const SolicitarObjetoPage(),
        ),
        AppRoutes.passageiroCorridaAndamento: (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
          return CorridaAndamentoPage(
            origem: args?['origem'] as String? ?? '',
            destino: args?['destino'] as String? ?? '',
            origemPoint: args?['origemPoint'] as MapPoint?,
            destinoPoint: args?['destinoPoint'] as MapPoint?,
          );
        },
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
