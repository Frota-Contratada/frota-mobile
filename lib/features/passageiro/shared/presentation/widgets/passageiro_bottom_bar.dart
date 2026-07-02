import 'package:flutter/material.dart';
import '../enums/passageiro_nav_destino.dart';
import '../theme/passageiro_colors.dart';

class PassageiroBottomBar extends StatelessWidget {
  final PassageiroNavDestino destinoAtivo;
  final ValueChanged<PassageiroNavDestino> onDestinoSelecionado;

  const PassageiroBottomBar({
    super.key,
    required this.destinoAtivo,
    required this.onDestinoSelecionado,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 75,
      decoration: const BoxDecoration(
        color: PassageiroColors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              label: 'solicitações',
              icon: Icons.event_available_outlined,
              ativo: destinoAtivo == PassageiroNavDestino.solicitacoes,
              onTap: () => onDestinoSelecionado(PassageiroNavDestino.solicitacoes),
            ),
            _NavItem(
              label: 'home',
              icon: Icons.location_on_outlined,
              ativo: destinoAtivo == PassageiroNavDestino.home,
              onTap: () => onDestinoSelecionado(PassageiroNavDestino.home),
            ),
            _NavItem(
              label: 'perfil',
              icon: Icons.person_outline,
              ativo: destinoAtivo == PassageiroNavDestino.perfil,
              onTap: () => onDestinoSelecionado(PassageiroNavDestino.perfil),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool ativo;
  final VoidCallback onTap;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.ativo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 90,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (ativo)
              Container(
                width: 24,
                height: 3,
                margin: const EdgeInsets.only(bottom: 6),
                decoration: BoxDecoration(
                  color: PassageiroColors.accentGreen,
                  borderRadius: BorderRadius.circular(2),
                ),
              )
            else
              const SizedBox(height: 9),
            Icon(
              icon,
              size: 28,
              color: PassageiroColors.darkBlue,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w500,
                color: PassageiroColors.darkBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
