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
const _routePadding = EdgeInsets.fromLTRB(44, 44, 44, 56);

/// Mapa compartilhado do aplicativo.
///
/// Flutter Map é o backend padrão, com cache persistente de tiles nativos.
/// Google Maps pode ser habilitado com USE_GOOGLE_MAPS=true e uma chave
/// configurada nativamente nas plataformas. Sem chave, o mapa cacheado do
/// Flutter Map continua funcionando.
class AppMapWidget extends StatefulWidget {
  final MapPoint? origin;
  final MapPoint? destination;
  final MapPoint? initialCenter;
  final ValueChanged<MapPoint>? onTap;
  final VoidCallback? onCurrentLocation;
  final bool showCurrentLocation;
  final bool showCurrentLocationMarker;
  final bool centerOnCurrentLocation;
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
    this.showCurrentLocationMarker = true,
    this.centerOnCurrentLocation = true,
    this.interactive = true,
    this.showAttribution = true,
  });

  @override
  State<AppMapWidget> createState() => _AppMapWidgetState();
}

class _AppMapWidgetState extends State<AppMapWidget> {
  final leaflet_map.MapController _leafletController =
      leaflet_map.MapController();

  MapPoint? _currentLocation;
  StreamSubscription<Position>? _positionSubscription;
  google_maps.GoogleMapController? _googleController;
  String? _locationMessage;
  bool _loadingLocation = true;
  bool _leafletReady = false;
  bool _centeredOnCurrentLocation = false;

  bool get _useGoogleMaps {
    final enabled = dotenv.env['USE_GOOGLE_MAPS']?.toLowerCase() == 'true';
    final key = dotenv.env['GOOGLE_MAPS_API_KEY'];
    return enabled && key != null && key.trim().isNotEmpty;
  }

  bool get _hasRoute => widget.origin != null && widget.destination != null;

  List<MapPoint> get _routeMapPoints => [
        if (widget.origin != null) widget.origin!,
        if (widget.destination != null) widget.destination!,
      ];

  MapPoint get _center =>
      widget.initialCenter ??
      widget.origin ??
      widget.destination ??
      (_currentLocation ?? _defaultMapCenter);

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
  void didUpdateWidget(covariant AppMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final routeChanged = oldWidget.origin != widget.origin ||
        oldWidget.destination != widget.destination;
    if (routeChanged) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_hasRoute) return;
        _fitRoute();
      });
    }
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _leafletController.dispose();
    super.dispose();
  }

  Future<void> _startLocationTracking() async {
    if (_positionSubscription != null) return;

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _setLocationMessage('Ative a localização para usar sua posição.');
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _setLocationMessage(
          permission == LocationPermission.deniedForever
              ? 'Permissão bloqueada nas configurações.'
              : 'Permissão de localização negada.',
        );
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
      _setLocationMessage('Não foi possível obter a localização atual.');
    }
  }

  void _setLocationMessage(String message) {
    if (!mounted) return;
    setState(() {
      _loadingLocation = false;
      _locationMessage = message;
    });
  }

  void _updateCurrentLocation(Position position) {
    if (!mounted) return;
    final wasFirstLocation = _currentLocation == null;
    setState(() {
      _currentLocation = MapPoint(position.latitude, position.longitude);
      _loadingLocation = false;
      _locationMessage = null;
    });

    if (wasFirstLocation &&
        widget.centerOnCurrentLocation &&
        !_hasRoute &&
        widget.initialCenter == null) {
      _moveToCurrentLocation();
    }
  }

  void _selectCurrentLocation() {
    final current = _currentLocation;
    if (current == null) {
      _startLocationTracking();
      return;
    }
    _moveToCurrentLocation();
    widget.onTap?.call(current);
    widget.onCurrentLocation?.call();
  }

  Future<void> _moveToCurrentLocation() async {
    final current = _currentLocation;
    if (current == null) return;

    if (_useGoogleMaps) {
      final controller = _googleController;
      if (controller == null) return;
      await controller.animateCamera(
        google_maps.CameraUpdate.newCameraPosition(
          google_maps.CameraPosition(
            target: current.googleLatLng,
            zoom: 16,
          ),
        ),
      );
      _centeredOnCurrentLocation = true;
      return;
    }

    if (_leafletReady) {
      _leafletController.move(current.leafletLatLng, 16);
      _centeredOnCurrentLocation = true;
    }
  }

  void _onLeafletMapReady() {
    _leafletReady = true;
    if (_hasRoute) {
      _fitRoute();
    } else if (_currentLocation != null &&
        widget.centerOnCurrentLocation &&
        widget.initialCenter == null &&
        !_centeredOnCurrentLocation) {
      _moveToCurrentLocation();
    }
  }

  void _onGoogleMapCreated(google_maps.GoogleMapController controller) {
    _googleController = controller;
    if (_hasRoute) {
      _fitRoute();
    } else if (_currentLocation != null &&
        widget.centerOnCurrentLocation &&
        widget.initialCenter == null &&
        !_centeredOnCurrentLocation) {
      _moveToCurrentLocation();
    }
  }

  Future<void> _fitRoute() async {
    final points = _routeMapPoints;
    if (points.length < 2) return;

    if (_useGoogleMaps) {
      final controller = _googleController;
      if (controller == null) return;
      final googlePoints = points.map((point) => point.googleLatLng).toList();
      final latitudes = googlePoints.map((point) => point.latitude);
      final longitudes = googlePoints.map((point) => point.longitude);
      final south = latitudes.reduce((a, b) => a < b ? a : b);
      final north = latitudes.reduce((a, b) => a > b ? a : b);
      final west = longitudes.reduce((a, b) => a < b ? a : b);
      final east = longitudes.reduce((a, b) => a > b ? a : b);

      if ((north - south).abs() < 0.0001 && (east - west).abs() < 0.0001) {
        await controller.animateCamera(
          google_maps.CameraUpdate.newCameraPosition(
            google_maps.CameraPosition(target: googlePoints.first, zoom: 16),
          ),
        );
      } else {
        await controller.animateCamera(
          google_maps.CameraUpdate.newLatLngBounds(
            google_maps.LatLngBounds(
              southwest: google_maps.LatLng(south, west),
              northeast: google_maps.LatLng(north, east),
            ),
            52,
          ),
        );
      }
      return;
    }

    if (_leafletReady) {
      _leafletController.fitCamera(
        leaflet_map.CameraFit.coordinates(
          coordinates: points.map((point) => point.leafletLatLng).toList(),
          padding: _routePadding,
          maxZoom: 15,
        ),
      );
    }
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
      if (widget.showCurrentLocationMarker && _currentLocation != null)
        leaflet_map.Marker(
          point: _currentLocation!.leafletLatLng,
          width: 28,
          height: 28,
          child: const _CurrentLocationMarker(),
        ),
      if (widget.origin != null)
        leaflet_map.Marker(
          point: widget.origin!.leafletLatLng,
          width: 28,
          height: 28,
          child: const _OriginMarker(),
        ),
      if (widget.destination != null)
        leaflet_map.Marker(
          point: widget.destination!.leafletLatLng,
          width: 34,
          height: 40,
          alignment: Alignment.topCenter,
          child: const Icon(
            Icons.location_on,
            color: Color(0xffe45756),
            size: 34,
          ),
        ),
    ];

    final routePoints = <latlong.LatLng>[
      if (widget.origin != null) widget.origin!.leafletLatLng,
      if (widget.destination != null) widget.destination!.leafletLatLng,
    ];

    return leaflet_map.FlutterMap(
      mapController: _leafletController,
      options: leaflet_map.MapOptions(
        initialCenter: center,
        initialZoom: routePoints.length == 2 ? 12 : 13,
        initialCameraFit: routePoints.length == 2
            ? leaflet_map.CameraFit.coordinates(
                coordinates: routePoints,
                padding: _routePadding,
                maxZoom: 15,
              )
            : null,
        interactionOptions: leaflet_map.InteractionOptions(
          flags: widget.interactive
              ? leaflet_map.InteractiveFlag.all
              : leaflet_map.InteractiveFlag.none,
        ),
        onMapReady: _onLeafletMapReady,
        onTap: widget.onTap == null
            ? null
            : (_, point) => widget.onTap!(
                  MapPoint(point.latitude, point.longitude),
                ),
      ),
      children: [
        leaflet_map.TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.app_frota_seara',
          tileProvider: leaflet_map.NetworkTileProvider(
            cachingProvider:
                leaflet_map.BuiltInMapCachingProvider.getOrCreateInstance(
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
                strokeWidth: 5,
                color: const Color(0xff1769aa),
                borderStrokeWidth: 1,
                borderColor: Colors.white,
              ),
            ],
          ),
        if (markers.isNotEmpty) leaflet_map.MarkerLayer(markers: markers),
      ],
    );
  }

  Widget _buildGoogleMap() {
    final markers = <google_maps.Marker>{
      if (widget.showCurrentLocationMarker && _currentLocation != null)
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
        zoom: routePoints.length == 2 ? 12 : 13,
      ),
      markers: markers,
      polylines: routePoints.length == 2
          ? {
              google_maps.Polyline(
                polylineId: const google_maps.PolylineId('route'),
                points: routePoints,
                color: const Color(0xff1769aa),
                width: 5,
              ),
            }
          : const {},
      myLocationEnabled: widget.showCurrentLocation,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      onMapCreated: _onGoogleMapCreated,
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

  @override
  void didUpdateWidget(covariant MapRoutePreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.originAddress != widget.originAddress ||
        oldWidget.destinationAddress != widget.destinationAddress ||
        oldWidget.origin != widget.origin ||
        oldWidget.destination != widget.destination) {
      _origin = widget.origin;
      _destination = widget.destination;
      _resolveAddresses();
    }
  }

  Future<void> _resolveAddresses() async {
    final geocoder = Geocoding();
    if (_origin == null && widget.originAddress.trim().isNotEmpty) {
      try {
        final locations = await geocoder.locationFromAddress(widget.originAddress);
        if (locations.isNotEmpty && mounted) {
          setState(() {
            _origin = MapPoint(
              locations.first.latitude,
              locations.first.longitude,
            );
          });
        }
      } catch (_) {}
    }
    if (_destination == null && widget.destinationAddress.trim().isNotEmpty) {
      try {
        final locations =
            await geocoder.locationFromAddress(widget.destinationAddress);
        if (locations.isNotEmpty && mounted) {
          setState(() {
            _destination = MapPoint(
              locations.first.latitude,
              locations.first.longitude,
            );
          });
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

class _CurrentLocationMarker extends StatelessWidget {
  const _CurrentLocationMarker();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          color: const Color(0xff1976d2),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 4)],
        ),
      ),
    );
  }
}

class _OriginMarker extends StatelessWidget {
  const _OriginMarker();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 15,
        height: 15,
        decoration: BoxDecoration(
          color: const Color(0xff1769aa),
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
      if ((place.subLocality ?? '').trim().isNotEmpty)
        place.subLocality!.trim(),
      if ((place.locality ?? '').trim().isNotEmpty) place.locality!.trim(),
    ];
    return parts.isEmpty ? null : parts.join(', ');
  } catch (_) {
    return null;
  }
}
