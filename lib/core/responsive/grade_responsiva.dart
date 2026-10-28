import 'package:flutter/widgets.dart';

class GradeResponsiva extends StatelessWidget {
  final List<Widget> children;
  final double larguraMinimaItem;
  final double espacamento;
  final int maximoColunas;

  const GradeResponsiva({
    super.key,
    required this.children,
    this.larguraMinimaItem = 340,
    this.espacamento = 16,
    this.maximoColunas = 2,
  });

  int _colunasPara(double larguraDisponivel) {
    var colunas = 1;
    while (colunas < maximoColunas) {
      final proxima = colunas + 1;
      final larguraNecessaria =
          larguraMinimaItem * proxima + espacamento * (proxima - 1);
      if (larguraDisponivel < larguraNecessaria) break;
      colunas = proxima;
    }
    return colunas;
  }

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final colunas = _colunasPara(constraints.maxWidth);

        if (colunas == 1) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var index = 0; index < children.length; index++) ...[
                if (index > 0) SizedBox(height: espacamento),
                children[index],
              ],
            ],
          );
        }

        final larguraItem =
            ((constraints.maxWidth - espacamento * (colunas - 1)) / colunas)
                .floorToDouble();

        return Wrap(
          spacing: espacamento,
          runSpacing: espacamento,
          children: [
            for (final child in children)
              SizedBox(width: larguraItem, child: child),
          ],
        );
      },
    );
  }
}
