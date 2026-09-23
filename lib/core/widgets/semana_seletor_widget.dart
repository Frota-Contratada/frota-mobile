import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Seletor de semana compartilhado entre motorista e passageiro.
/// Exibe o intervalo da semana com botões de navegação (anterior/próxima).
/// Componente "component_mudar_listagem" do Figma.
class SemanaSeletorWidget extends StatelessWidget {
  final String intervaloSemana;
  final VoidCallback onSemanaAnterior;
  final VoidCallback onSemanaProxima;

  const SemanaSeletorWidget({
    super.key,
    required this.intervaloSemana,
    required this.onSemanaAnterior,
    required this.onSemanaProxima,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 25),
      decoration: BoxDecoration(
        color: AppColors.weekSelectorBg,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          _BotaoNavegacao(
            icon: Icons.chevron_left,
            onPressed: onSemanaAnterior,
          ),
          Expanded(
            child: Text(
              intervaloSemana,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.darkBlue,
              ),
            ),
          ),
          _BotaoNavegacao(
            icon: Icons.chevron_right,
            onPressed: onSemanaProxima,
          ),
        ],
      ),
    );
  }
}

class _BotaoNavegacao extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _BotaoNavegacao({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Material(
        color: AppColors.primaryBlue,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 30,
            height: 30,
            child: Icon(icon, color: AppColors.white, size: 22),
          ),
        ),
      ),
    );
  }
}
