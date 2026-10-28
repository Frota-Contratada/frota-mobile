import 'package:flutter/material.dart';
import '../../../../../core/responsive/app_layout.dart';
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
    final medidas = _NavMedidas.para(AppLayout.of(context));

    return ColoredBox(
      color: PassageiroColors.white,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: medidas.altura,
          child: Row(
            children: [
              Expanded(
                child: _NavItem(
                  label: 'solicitações',
                  iconPath: PassageiroAssets.bottomBarSolicitacoes,
                  iconWidth: 26,
                  iconHeight: 30,
                  medidas: medidas,
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
                  medidas: medidas,
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
                  medidas: medidas,
                  ativo: destinoAtivo == PassageiroNavDestino.perfil,
                  onTap: () =>
                      onDestinoSelecionado(PassageiroNavDestino.perfil),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavMedidas {
  final double altura;
  final double topoLabel;
  final double tamanhoLabel;

  const _NavMedidas({
    required this.altura,
    required this.topoLabel,
    required this.tamanhoLabel,
  });

  factory _NavMedidas.para(AppLayout layout) => layout.compacto
      ? const _NavMedidas(altura: 75, topoLabel: 53, tamanhoLabel: 8)
      : const _NavMedidas(altura: 80, topoLabel: 55, tamanhoLabel: 11);
}

class _NavItem extends StatelessWidget {
  final String label;
  final String iconPath;
  final double iconWidth;
  final double iconHeight;
  final _NavMedidas medidas;
  final bool ativo;
  final VoidCallback onTap;

  const _NavItem({
    required this.label,
    required this.iconPath,
    required this.iconWidth,
    required this.iconHeight,
    required this.medidas,
    required this.ativo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: medidas.altura,
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
              top: medidas.topoLabel,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: medidas.tamanhoLabel,
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
