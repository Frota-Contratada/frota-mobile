import 'package:flutter/widgets.dart';

import 'app_layout.dart';

class EscalaTela extends StatelessWidget {
  final Widget child;

  const EscalaTela({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final midia = MediaQuery.of(context);
    final fator = AppLayout.fatorEscalaPara(midia.size);
    if (fator == 1) return child;

    final tamanhoEscalado = midia.size / fator;

    return MediaQuery(
      data: midia.copyWith(
        size: tamanhoEscalado,
        devicePixelRatio: midia.devicePixelRatio * fator,
        padding: midia.padding / fator,
        viewPadding: midia.viewPadding / fator,
        viewInsets: midia.viewInsets / fator,
        systemGestureInsets: midia.systemGestureInsets / fator,
      ),
      child: FittedBox(
        fit: BoxFit.fill,
        alignment: Alignment.topLeft,
        child: SizedBox.fromSize(size: tamanhoEscalado, child: child),
      ),
    );
  }
}
