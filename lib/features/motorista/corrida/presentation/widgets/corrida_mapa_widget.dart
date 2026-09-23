import 'package:flutter/material.dart';

import '../../../../../core/widgets/app_map_widget.dart';
import '../../../../../core/maps/map_point.dart';
import '../../domain/entities/corrida_detalhe.dart';
import 'corrida_colors.dart';

class CorridaMapaWidget extends StatelessWidget {
  final String origem;
  final String destino;
  final List<CorridaParada> paradas;

  const CorridaMapaWidget({
    super.key,
    required this.origem,
    required this.destino,
    this.paradas = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 198,
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
        viaPoints: paradas
            .map((parada) => MapPoint(parada.latitude, parada.longitude))
            .toList(),
      ),
    );
  }
}
