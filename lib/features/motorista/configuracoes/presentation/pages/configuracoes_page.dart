import 'package:flutter/material.dart';
import '../../../../../config/app_assets.dart';
import '../../../../../core/widgets/app_colors.dart';
import '../../../shared/presentation/theme/motorista_colors.dart';

/// Página de Configurações do motorista.
/// Exibe toggles de notificação e botão de logout conforme o Figma.
class MotoristaConfiguracoesPage extends StatefulWidget {
  const MotoristaConfiguracoesPage({super.key});

  @override
  State<MotoristaConfiguracoesPage> createState() =>
      _MotoristaConfiguracoesPageState();
}

class _MotoristaConfiguracoesPageState
    extends State<MotoristaConfiguracoesPage> {
  bool _corridaProximaAtiva = false;
  bool _mudancaStatusAtiva = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
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
            _buildNotificacoes(),
            const Spacer(),
            _buildLogoutButton(),
            const SizedBox(height: 57),
          ],
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

  Widget _buildNotificacoes() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Notificações',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: AppColors.darkBlue,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Escolha quais notificações deseja receber',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: AppColors.textMediumGrey,
            ),
          ),
          const SizedBox(height: 20),
          _NotificacaoToggle(
            label: 'Corrida próxima do início',
            ativo: _corridaProximaAtiva,
            onChanged: (valor) => setState(() => _corridaProximaAtiva = valor),
          ),
          const SizedBox(height: 15),
          _NotificacaoToggle(
            label: 'Mudança de status da solicitação',
            ativo: _mudancaStatusAtiva,
            onChanged: (valor) => setState(() => _mudancaStatusAtiva = valor),
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
          onPressed: () {
            // TODO: implementar logout
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil('/login', (route) => false);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: MotoristaColors.logoutButton,
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

class _NotificacaoToggle extends StatelessWidget {
  final String label;
  final bool ativo;
  final ValueChanged<bool> onChanged;

  const _NotificacaoToggle({
    required this.label,
    required this.ativo,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => onChanged(!ativo),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 36,
            height: 20,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: ativo
                  ? MotoristaColors.toggleActive
                  : MotoristaColors.toggleInactive,
              borderRadius: BorderRadius.circular(30),
            ),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 200),
              alignment: ativo ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: AppColors.darkBlue,
            ),
          ),
        ),
      ],
    );
  }
}
