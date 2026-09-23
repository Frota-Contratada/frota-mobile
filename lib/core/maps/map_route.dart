import 'map_point.dart';

// Trajeto calculado por vias reais entre os pontos escolhidos.
class MapRoute {
  // Geometria completa do caminho, para desenhar a linha no mapa.
  final List<MapPoint> points;
  final double distanceKm;
  final Duration duration;

  const MapRoute({
    required this.points,
    required this.distanceKm,
    required this.duration,
  });
}
