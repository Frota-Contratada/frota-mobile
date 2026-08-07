import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart' as leaflet_map;
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as google_maps;
import 'package:latlong2/latlong.dart' as latlong;

import '../maps/map_point.dart';

const _defaultMapCenter = MapPoint(-23.3045, -51.1696);

/// Mapa compartilhado do aplicativo.
///
/// O mapa usa Flutter Map por padrão, com cache persistente dos tiles nativos.
/// Google Maps pode ser habilitado com USE_GOOGLE_MAPS=true e uma chave
/// configurada nativamente nas plataformas. A ausência de chave não impede o
/// uso do mapa OpenStreetMap/cacheado.
class AppMapWidget extends StatefulWidget {
  final MapPoint? origin;
  final MapPoint? destination;
  final MapPoint? initialCenter;
  final ValueChanged<MapPoint>? onTap;
  final VoidCallback? onCurrentLocation;
  final bool showCurrentLocation;
  final bool interactive;
  final bool showAttribution;

  const AppMapWidget({
    super.key,
    this.origin,
    this.destination,
    this.initialCenter,
    this.onTap,
    this.onCurrentLocation,
    this.showCurrentLocation = true,
    this.interactive = true,
    this.showAttribution = true,
  });

  @override
  State<AppMapWidget> createState() => _AppMapWidgetState();
}

class _AppMapWidgetState extends State<AppMapWidget> {
  MapPoint? _currentLocation;
  StreamSubscription<Position>? _positionSubscription;
  String? _locationMessage;
  bool _loadingLocation = true;

  bool get _useGoogleMaps {
    final enabled = dotenv.env['USE_GOOGLE_MAPS']?.toLowerCase() == 'true';
    final key = dotenv.env['GOOGLE_MAPS_API_KEY'];
    return enabled && key != null && key.trim().isNotEmpty;
  }

  MapPoint get _center =>
      widget.initialCenter ??
      widget.origin ??
      widget.destination ??
      _currentLocation ??
      _defaultMapCenter;

  @override
  void initState() {
    super.initState();
    if (widget.showCurrentLocation) {
      _startLocationTracking();
    } else {
      _loadingLocation = false;
    }
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }

  Future<void> _startLocationTracking() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          setState(() {
            _loadingLocation = false;
            _locationMessage = 'Ative a localização para usar sua posição.';
          });
        }
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() {
            _loadingLocation = false;
            _locationMessage = permission == LocationPermission.deniedForever
                ? 'Permissão de localização bloqueada nas configurações.'
                : 'Permissão de localização negada.';
          });
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      _updateCurrentLocation(position);

      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      ).listen(_updateCurrentLocation);
    } catch (_) {
      if (mounted) {
        setState(() {
          _loadingLocation = false;
          _locationMessage = 'Não foi possível obter a localização atual.';
        });
      }
    }
  }

  void _updateCurrentLocation(Position position) {
    if (!mounted) return;
    setState(() {
      _currentLocation = MapPoint(position.latitude, position.longitude);
      _loadingLocation = false;
      _locationMessage = null;
    });
  }

  void _selectCurrentLocation() {
    final current = _currentLocation;
    if (current == null) {
      _startLocationTracking();
      return;
    }
    widget.onTap?.call(current);
    widget.onCurrentLocation?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _useGoogleMaps ? _buildGoogleMap() : _buildFlutterMap(),
        if (widget.showAttribution && !_useGoogleMaps)
          const Positioned(
            right: 8,
            bottom: 6,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white70,
                borderRadius: BorderRadius.all(Radius.circular(4)),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                child: Text(
                  '© OpenStreetMap · cache local',
                  style: TextStyle(fontSize: 9, color: Colors.black54),
                ),
              ),
            ),
          ),
        if (widget.showCurrentLocation)
          Positioned(
            right: 10,
            bottom: widget.showAttribution && !_useGoogleMaps ? 28 : 10,
            child: Material(
              color: Colors.white,
              elevation: 3,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: _selectCurrentLocation,
                child: const Padding(
                  padding: EdgeInsets.all(10),
                  child: Icon(Icons.my_location, size: 20),
                ),
              ),
            ),
          ),
        if (_loadingLocation)
          const Positioned(
            top: 10,
            left: 10,
            child: _MapStatusChip(label: 'Obtendo localização...'),
          ),
        if (_locationMessage != null && !_loadingLocation)
          Positioned(
            top: 10,
            left: 10,
            right: 52,
            child: _MapStatusChip(label: _locationMessage!),
          ),
      ],
    );
  }

  Widget _buildFlutterMap() {
    final center = _center.leafletLatLng;
    final markers = <leaflet_map.Marker>[
      if (_currentLocation != null &&
          widget.origin == null &&
          widget.destination == null)
        leaflet_map.Marker(
          point: _currentLocation!.leafletLatLng,
          width: 24,
          height: 24,
          child: const _OriginMarker(color: Colors.blue),
        ),
      if (widget.origin != null)
        leaflet_map.Marker(
          point: widget.origin!.leafletLatLng,
          width: 28,
          height: 28,
          child: const _OriginMarker(color: Color(0xff1769aa)),
        ),
      if (widget.destination != null)
        leaflet_map.Marker(
          point: widget.destination!.leafletLatLng,
          width: 34,
          height: 40,
          alignment: Alignment.topCenter,
          child: const Icon(Icons.location_on, color: Color(0xffe45756), size: 34),
        ),
    ];

    final routePoints = <latlong.LatLng>[
      if (widget.origin != null) widget.origin!.leafletLatLng,
      if (widget.destination != null) widget.destination!.leafletLatLng,
    ];

    return leaflet_map.FlutterMap(
      options: leaflet_map.MapOptions(
        initialCenter: center,
        initialZoom: routePoints.length == 2 ? 11.5 : 13,
        interactionOptions: leaflet_map.InteractionOptions(
          flags: widget.interactive
              ? leaflet_map.InteractiveFlag.all
              : leaflet_map.InteractiveFlag.none,
        ),
        onTap: widget.onTap == null
            ? null
            : (_, point) => widget.onTap!(MapPoint(point.latitude, point.longitude)),
      ),
      children: [
        leaflet_map.TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.app_frota_seara',
          tileProvider: leaflet_map.NetworkTileProvider(
            cachingProvider: leaflet_map.BuiltInMapCachingProvider.getOrCreateInstance(
              maxCacheSize: 250 * 1024 * 1024,
              overrideFreshAge: const Duration(days: 30),
            ),
          ),
        ),
        if (routePoints.length == 2)
          leaflet_map.PolylineLayer(
            polylines: [
              leaflet_map.Polyline(
                points: routePoints,
                strokeWidth: 4,
                color: const Color(0xff1769aa),
              ),
            ],
          ),
        if (markers.isNotEmpty) leaflet_map.MarkerLayer(markers: markers),
      ],
    );
  }

  Widget _buildGoogleMap() {
    final markers = <google_maps.Marker>{
      if (_currentLocation != null &&
          widget.origin == null &&
          widget.destination == null)
        google_maps.Marker(
          markerId: const google_maps.MarkerId('current-location'),
          position: _currentLocation!.googleLatLng,
          icon: google_maps.BitmapDescriptor.defaultMarkerWithHue(
            google_maps.BitmapDescriptor.hueAzure,
          ),
        ),
      if (widget.origin != null)
        google_maps.Marker(
          markerId: const google_maps.MarkerId('origin'),
          position: widget.origin!.googleLatLng,
          icon: google_maps.BitmapDescriptor.defaultMarkerWithHue(
            google_maps.BitmapDescriptor.hueAzure,
          ),
        ),
      if (widget.destination != null)
        google_maps.Marker(
          markerId: const google_maps.MarkerId('destination'),
          position: widget.destination!.googleLatLng,
          icon: google_maps.BitmapDescriptor.defaultMarker,
        ),
    };
    final routePoints = <google_maps.LatLng>[
      if (widget.origin != null) widget.origin!.googleLatLng,
      if (widget.destination != null) widget.destination!.googleLatLng,
    ];

    return google_maps.GoogleMap(
      initialCameraPosition: google_maps.CameraPosition(
        target: _center.googleLatLng,
        zoom: routePoints.length == 2 ? 11.5 : 13,
      ),
      markers: markers,
      polylines: routePoints.length == 2
          ? {
              google_maps.Polyline(
                polylineId: const google_maps.PolylineId('route'),
                points: routePoints,
                color: const Color(0xff1769aa),
                width: 4,
              ),
            }
          : const {},
      myLocationEnabled: _currentLocation != null,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      onTap: widget.onTap == null
          ? null
          : (point) => widget.onTap!(
                MapPoint(point.latitude, point.longitude),
              ),
    );
  }
}

class MapRoutePreview extends StatefulWidget {
  final String originAddress;
  final String destinationAddress;
  final MapPoint? origin;
  final MapPoint? destination;
  final bool showCurrentLocation;

  const MapRoutePreview({
    super.key,
    required this.originAddress,
    required this.destinationAddress,
    this.origin,
    this.destination,
    this.showCurrentLocation = false,
  });

  @override
  State<MapRoutePreview> createState() => _MapRoutePreviewState();
}

class _MapRoutePreviewState extends State<MapRoutePreview> {
  MapPoint? _origin;
  MapPoint? _destination;

  @override
  void initState() {
    super.initState();
    _origin = widget.origin;
    _destination = widget.destination;
    _resolveAddresses();
  }

  Future<void> _resolveAddresses() async {
    final geocoder = Geocoding();
    if (_origin == null && widget.originAddress.trim().isNotEmpty) {
      try {
        final locations = await geocoder.locationFromAddress(widget.originAddress);
        if (locations.isNotEmpty && mounted) {
          setState(() => _origin = MapPoint(
                locations.first.latitude,
                locations.first.longitude,
              ));
        }
      } catch (_) {}
    }
    if (_destination == null && widget.destinationAddress.trim().isNotEmpty) {
      try {
        final locations =
            await geocoder.locationFromAddress(widget.destinationAddress);
        if (locations.isNotEmpty && mounted) {
          setState(() => _destination = MapPoint(
                locations.first.latitude,
                locations.first.longitude,
              ));
        }
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppMapWidget(
      origin: _origin,
      destination: _destination,
      showCurrentLocation: widget.showCurrentLocation,
      interactive: false,
    );
  }
}

class _OriginMarker extends StatelessWidget {
  final Color color;

  const _OriginMarker({required this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 3)],
        ),
      ),
    );
  }
}

class _MapStatusChip extends StatelessWidget {
  final String label;

  const _MapStatusChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Text(label, style: const TextStyle(fontSize: 11)),
      ),
    );
  }
}

/// Converte o ponto escolhido em um texto útil para os campos existentes.
Future<String?> reverseGeocodeMapPoint(MapPoint point) async {
  try {
    final placemarks = await Geocoding().placemarkFromCoordinates(
      point.latitude,
      point.longitude,
    );
    if (placemarks.isEmpty) return null;
    final place = placemarks.first;
    final parts = <String>[
      if ((place.street ?? '').trim().isNotEmpty) place.street!.trim(),
      if ((place.subLocality ?? '').trim().isNotEmpty) place.subLocality!.trim(),
      if ((place.locality ?? '').trim().isNotEmpty) place.locality!.trim(),
    ];
    return parts.isEmpty ? null : parts.join(', ');
  } catch (_) {
    return null;
  }
}

