import 'package:flutter/widgets.dart';

import 'app_layout.dart';

class ConteudoResponsivo extends StatelessWidget {
  final Widget child;
  final double larguraMaxima;
  final AlignmentGeometry alinhamento;

  const ConteudoResponsivo({
    super.key,
    required this.child,
    this.larguraMaxima = AppLayout.larguraConteudo,
    this.alinhamento = Alignment.topCenter,
  });

  @override
  Widget build(BuildContext context) {
    final respiro = AppLayout.of(context).respiroLateral;

    return Align(
      alignment: alinhamento,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: larguraMaxima),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: respiro),
          child: child,
        ),
      ),
    );
  }
}
