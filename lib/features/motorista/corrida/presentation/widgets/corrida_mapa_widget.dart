import 'package:flutter/material.dart';

import '../../../../../core/widgets/app_map_widget.dart';
import 'corrida_colors.dart';

class CorridaMapaWidget extends StatelessWidget {
  final String origem;
  final String destino;
  final double? altura;

  const CorridaMapaWidget({
    super.key,
    required this.origem,
    required this.destino,
    this.altura = 198,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: altura,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CorridaColors.borderGrey),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F101828),
            offset: Offset(0, 1),
            blurRadius: 2,
          ),
          BoxShadow(
            color: Color(0x1A101828),
            offset: Offset(0, 1),
            blurRadius: 3,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: MapRoutePreview(
        originAddress: origem,
        destinationAddress: destino,
      ),
    );
  }
}
