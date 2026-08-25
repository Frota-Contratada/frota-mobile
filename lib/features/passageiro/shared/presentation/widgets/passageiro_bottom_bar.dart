import 'package:flutter/material.dart';
import '../enums/passageiro_nav_destino.dart';
import '../theme/passageiro_assets.dart';
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
      color: PassageiroColors.white,
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: _NavItem(
                label: 'solicitações',
                iconPath: PassageiroAssets.bottomBarSolicitacoes,
                iconWidth: 26,
                iconHeight: 30,
                ativo: destinoAtivo == PassageiroNavDestino.solicitacoes,
                onTap: () =>
                    onDestinoSelecionado(PassageiroNavDestino.solicitacoes),
              ),
            ),
            Expanded(
              child: _NavItem(
                label: 'home',
                iconPath: PassageiroAssets.bottomBarHome,
                iconWidth: 30,
                iconHeight: 30,
                ativo: destinoAtivo == PassageiroNavDestino.home,
                onTap: () => onDestinoSelecionado(PassageiroNavDestino.home),
              ),
            ),
            Expanded(
              child: _NavItem(
                label: 'perfil',
                iconPath: PassageiroAssets.bottomBarPerfil,
                iconWidth: 28,
                iconHeight: 30,
                ativo: destinoAtivo == PassageiroNavDestino.perfil,
                onTap: () => onDestinoSelecionado(PassageiroNavDestino.perfil),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  final String iconPath;
  final double iconWidth;
  final double iconHeight;
  final bool ativo;
  final VoidCallback onTap;

  const _NavItem({
    required this.label,
    required this.iconPath,
    required this.iconWidth,
    required this.iconHeight,
    required this.ativo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 75,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (ativo)
              Positioned(
                top: 8,
                child: Image.asset(
                  PassageiroAssets.bottomBarIndicadorAtivo,
                  width: 24,
                  height: 3,
                  fit: BoxFit.fill,
                ),
              ),
            Positioned(
              top: 18,
              child: Image.asset(
                iconPath,
                width: iconWidth,
                height: iconHeight,
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              top: 53,
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w500,
                  color: PassageiroColors.darkBlue,
                  height: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
