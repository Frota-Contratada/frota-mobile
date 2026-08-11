/// Coordenada usada pelo mobile sem acoplar as telas a um SDK específico.
class MapPoint {
  final double latitude;
  final double longitude;

  const MapPoint(this.latitude, this.longitude);

  @override
  bool operator ==(Object other) =>
      other is MapPoint &&
      other.latitude == latitude &&
      other.longitude == longitude;

  @override
  int get hashCode => Object.hash(latitude, longitude);
}

/// Resultado retornado pelo seletor de localização.
class MapSelectionResult {
  final MapPoint point;
  final String? address;

  const MapSelectionResult({required this.point, this.address});
}

enum MapSelectionKind { origin, stop, destination }
