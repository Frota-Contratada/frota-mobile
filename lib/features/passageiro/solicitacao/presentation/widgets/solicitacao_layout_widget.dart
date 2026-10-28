import 'package:flutter/material.dart';

import '../../../../../core/responsive/responsive.dart';
import '../../../../../core/widgets/app_colors.dart';

class SolicitacaoLayoutWidget extends StatelessWidget {
  static const double _raioPainel = 25;

  final Widget mapa;
  final double alturaMapa;
  final double sobreposicao;
  final List<Widget> children;

  const SolicitacaoLayoutWidget({
    super.key,
    required this.mapa,
    required this.alturaMapa,
    required this.sobreposicao,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final layout = AppLayout.of(context);
    final painelLateral = layout.usaPainelLateral;

    return LayoutBuilder(
      builder: (context, constraints) {
        final larguraPainel = layout.larguraPainelLateral;
        final altura = layout.alturaProporcional(alturaMapa);

        return Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: painelLateral ? larguraPainel - sobreposicao : 0,
              height: painelLateral ? constraints.maxHeight : altura,
              child: mapa,
            ),
            Positioned(
              top: painelLateral ? 0 : altura - sobreposicao,
              bottom: 0,
              right: 0,
              width: painelLateral ? larguraPainel : constraints.maxWidth,
              child: _Painel(painelLateral: painelLateral, children: children),
            ),
          ],
        );
      },
    );
  }
}

class _Painel extends StatelessWidget {
  final bool painelLateral;
  final List<Widget> children;

  const _Painel({required this.painelLateral, required this.children});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: painelLateral
            ? const BorderRadius.horizontal(
                left: Radius.circular(SolicitacaoLayoutWidget._raioPainel),
              )
            : const BorderRadius.vertical(
                top: Radius.circular(SolicitacaoLayoutWidget._raioPainel),
              ),
        boxShadow: painelLateral
            ? const [
                BoxShadow(
                  color: Color(0x1F000000),
                  blurRadius: 16,
                  offset: Offset(-4, 0),
                ),
              ]
            : null,
      ),
      child: SafeArea(
        top: painelLateral,
        bottom: false,
        left: false,
        child: SingleChildScrollView(
          padding: painelLateral
              ? const EdgeInsets.fromLTRB(28, 24, 28, 40)
              : const EdgeInsets.fromLTRB(25, 24, 25, 40),
          child: ConteudoResponsivo(
            larguraMaxima: AppLayout.larguraFormulario,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ),
      ),
    );
  }
}
