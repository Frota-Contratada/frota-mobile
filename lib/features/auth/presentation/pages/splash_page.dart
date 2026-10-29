import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/routes.dart';
import '../../../../config/themes.dart';
import '../../../../injection_container/injection_container.dart';
import '../../../notificacoes/presentation/sessao/notificacoes_sessao_controller.dart';
import '../bloc/splash_cubit.dart';
import '../utils/auth_navigation.dart';

class SplashPage extends StatelessWidget {
  static const double larguraLogo = 260;

  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashCubit, SplashState>(
      listener: _navegar,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: AppTheme.primaryBlue,
          body: Stack(
            children: [
              Center(
                child: Image.asset(
                  'assets/images/splash_logo.png',
                  width: larguraLogo,
                  semanticLabel: 'Seara - Gestão de Frota Contratada',
                ),
              ),
              const Align(
                alignment: Alignment.bottomCenter,
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 48),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: AppTheme.white,
                        strokeWidth: 2.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navegar(BuildContext context, SplashState state) {
    switch (state) {
      case SplashSessaoRestaurada(:final usuario):
        Navigator.pushReplacementNamed(
          context,
          AuthNavigation.rotaHome(usuario),
          arguments: usuario,
        );
        sl<NotificacoesSessaoController>().iniciarSessao(usuario);
      case SplashSemSessao():
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      case SplashCarregando():
        break;
    }
  }
}
