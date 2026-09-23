import 'package:flutter/material.dart';
import '../../../../../core/widgets/app_map_widget.dart';
import '../../../../../core/widgets/busca_barra_widget.dart';

class MapaBuscaWidget extends StatelessWidget {
  final VoidCallback? onBuscarLocal;

  const MapaBuscaWidget({super.key, this.onBuscarLocal});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: SizedBox(
        height: 185,
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
