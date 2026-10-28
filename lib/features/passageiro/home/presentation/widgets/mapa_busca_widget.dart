import 'package:flutter/material.dart';
import '../../../../../core/widgets/app_map_widget.dart';
import '../../../../../core/widgets/busca_barra_widget.dart';

class MapaBuscaWidget extends StatelessWidget {
  final VoidCallback? onBuscarLocal;
  final double altura;
  final EdgeInsetsGeometry padding;

  const MapaBuscaWidget({
    super.key,
    this.onBuscarLocal,
    this.altura = 185,
    this.padding = const EdgeInsets.symmetric(horizontal: 25),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: SizedBox(
        height: altura,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: AppMapWidget(
                interactive: false,
                showAttribution: false,
                onTap: (_) => onBuscarLocal?.call(),
              ),
            ),
            Positioned(
              top: -1,
              left: 0,
              right: 0,
              child: BuscaBarraWidget(
                hintText: 'Buscar local',
                readOnly: true,
                onTap: onBuscarLocal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
