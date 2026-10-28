import 'package:flutter/material.dart';
import '../../../../../config/app_assets.dart';
import '../../../../../core/responsive/responsive.dart';
import '../../../../../core/widgets/app_colors.dart';
import '../../../../../features/auth/domain/usecases/logout_usecase.dart';
import '../../../../../injection_container/injection_container.dart';
import '../../../../auth/domain/enums/perfil_usuario.dart';
import '../../../../notificacoes/presentation/sessao/notificacoes_sessao_controller.dart';
import '../../../../notificacoes/presentation/widgets/preferencias_notificacao_section.dart';

/// Página de Configurações do passageiro.
/// Exibe toggles de notificação e botão de logout conforme o Figma.
class PassageiroConfiguracoesPage extends StatefulWidget {
  const PassageiroConfiguracoesPage({super.key});

  @override
  State<PassageiroConfiguracoesPage> createState() =>
      _PassageiroConfiguracoesPageState();
}

class _PassageiroConfiguracoesPageState
    extends State<PassageiroConfiguracoesPage> {
  bool _loggingOut = false;

  Future<void> _logout() async {
    if (_loggingOut) return;
    setState(() => _loggingOut = true);
    try {
      await sl<NotificacoesSessaoController>().encerrarSessao();
      await sl<LogoutUsecase>()();
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível sair da conta.')),
      );
      setState(() => _loggingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ConteudoResponsivo(
          larguraMaxima: 640,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const Divider(
                color: AppColors.borderGrey,
                height: 1,
                indent: 25,
                endIndent: 25,
              ),
              const SizedBox(height: 15),
              const Expanded(
                child: SingleChildScrollView(
                  child: PreferenciasNotificacaoSection(
                    perfil: PerfilUsuario.passageiro,
                    corAtiva: AppColors.accentGreen,
                    corInativa: Color(0xFFC4C4C4),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              _buildLogoutButton(),
              SizedBox(
                height: AppLayout.of(context).usaPainelLateral ? 24 : 57,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(25, 16, 25, 15),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Image.asset(
              AppAssets.iconVoltar,
              width: 30,
              height: 30,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 15),
          const Text(
            'Configurações',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w500,
              color: AppColors.darkBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Center(
      child: SizedBox(
        width: 245,
        height: 60,
        child: ElevatedButton(
          onPressed: _loggingOut ? null : _logout,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: AppColors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: const Text(
            'Sair da conta',
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
