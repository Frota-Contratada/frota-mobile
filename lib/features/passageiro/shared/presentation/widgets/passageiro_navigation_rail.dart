import 'package:flutter/material.dart';
import '../enums/passageiro_nav_destino.dart';
import '../theme/passageiro_assets.dart';
import '../theme/passageiro_colors.dart';

class PassageiroNavigationRail extends StatelessWidget {
  static const double largura = 96;

  final PassageiroNavDestino destinoAtivo;
  final ValueChanged<PassageiroNavDestino> onDestinoSelecionado;

  const PassageiroNavigationRail({
    super.key,
    required this.destinoAtivo,
    required this.onDestinoSelecionado,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: PassageiroColors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(2, 0),
          ),
        ],
      ),
      child: SafeArea(
        right: false,
        child: SizedBox(
          width: largura,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _RailItem(
                label: 'solicitações',
                iconPath: PassageiroAssets.bottomBarSolicitacoes,
                iconWidth: 26,
                iconHeight: 30,
                ativo: destinoAtivo == PassageiroNavDestino.solicitacoes,
                onTap: () =>
                    onDestinoSelecionado(PassageiroNavDestino.solicitacoes),
              ),
              const SizedBox(height: 12),
              _RailItem(
                label: 'home',
                iconPath: PassageiroAssets.bottomBarHome,
                iconWidth: 30,
                iconHeight: 30,
                ativo: destinoAtivo == PassageiroNavDestino.home,
                onTap: () => onDestinoSelecionado(PassageiroNavDestino.home),
              ),
              const SizedBox(height: 12),
              _RailItem(
                label: 'perfil',
                iconPath: PassageiroAssets.bottomBarPerfil,
                iconWidth: 28,
                iconHeight: 30,
                ativo: destinoAtivo == PassageiroNavDestino.perfil,
                onTap: () => onDestinoSelecionado(PassageiroNavDestino.perfil),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RailItem extends StatelessWidget {
  final String label;
  final String iconPath;
  final double iconWidth;
  final double iconHeight;
  final bool ativo;
  final VoidCallback onTap;

  const _RailItem({
    required this.label,
    required this.iconPath,
    required this.iconWidth,
    required this.iconHeight,
    required this.ativo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: ativo,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (ativo)
                  Positioned(
                    left: 0,
                    child: RotatedBox(
                      quarterTurns: 1,
                      child: Image.asset(
                        PassageiroAssets.bottomBarIndicadorAtivo,
                        width: 24,
                        height: 3,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      iconPath,
                      width: iconWidth,
                      height: iconHeight,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: ativo ? FontWeight.w600 : FontWeight.w500,
                        color: PassageiroColors.darkBlue,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
