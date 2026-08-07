import 'package:google_maps_flutter/google_maps_flutter.dart' as google_maps;
import 'package:latlong2/latlong.dart' as leaflet;

/// Coordenada usada pelo mobile sem acoplar as telas a um SDK específico.
class MapPoint {
  final double latitude;
  final double longitude;

  const MapPoint(this.latitude, this.longitude);

  google_maps.LatLng get googleLatLng =>
      google_maps.LatLng(latitude, longitude);

  leaflet.LatLng get leafletLatLng => leaflet.LatLng(latitude, longitude);

  @override
  bool operator ==(Object other) =>
      other is MapPoint &&
      other.latitude == latitude &&
      other.longitude == longitude;

  @override
  int get hashCode => Object.hash(latitude, longitude);
}

class MapSelectionResult {
  final MapPoint point;
  final String? address;

  const MapSelectionResult({required this.point, this.address});
}

enum MapSelectionKind { origin, destination }
