import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import '../maps/map_point.dart';

const _defaultMapCenter = MapPoint(-23.3045, -51.1696);
const _mapStyleAsset = 'assets/maps/frota_uber_style.json';
const _routePadding = 56.0;

/// Mapa vetorial compartilhado do aplicativo.
///
/// O estilo local controla a aparência do mapa e usa dados vetoriais do
/// OpenFreeMap. A geometria de [routePoints] pode ser preenchida por um motor
/// de rotas no futuro; enquanto ela não existir, origem e destino formam uma
/// linha visual de fallback.
class AppMapWidget extends StatefulWidget {
  final MapPoint? origin;
  final MapPoint? destination;
  final List<MapPoint>? routePoints;
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
    this.routePoints,
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
  MapLibreMapController? _controller;
  StreamSubscription<Position>? _positionSubscription;
  MapPoint? _currentLocation;
  String? _locationMessage;
  bool _loadingLocation = true;
  bool _styleReady = false;
  bool _centeredOnCurrentLocation = false;

  bool get _hasRoute => _routeMapPoints.length >= 2;

  List<MapPoint> get _routeMapPoints {
    final providedRoute = widget.routePoints;
    if (providedRoute != null && providedRoute.length >= 2) {
      return providedRoute;
    }
    return [
      if (widget.origin != null) widget.origin!,
      if (widget.destination != null) widget.destination!,
    ];
  }

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
    final mapContentChanged =
        oldWidget.origin != widget.origin ||
        oldWidget.destination != widget.destination ||
        oldWidget.routePoints != widget.routePoints;
    if (mapContentChanged && _styleReady) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) unawaited(_refreshMap());
      });
    }
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
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

    if (_styleReady) unawaited(_renderAnnotations());

    if (wasFirstLocation &&
        widget.centerOnCurrentLocation &&
        !_hasRoute &&
        widget.initialCenter == null) {
      unawaited(_moveToCurrentLocation());
    }
  }

  void _selectCurrentLocation() {
    final current = _currentLocation;
    if (current == null) {
      _startLocationTracking();
      return;
    }
    unawaited(_moveToCurrentLocation());
    widget.onTap?.call(current);
    widget.onCurrentLocation?.call();
  }

  Future<void> _moveToCurrentLocation() async {
    final current = _currentLocation;
    final controller = _controller;
    if (current == null || controller == null || !_styleReady) return;

    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: _toLatLng(current),
          zoom: 16,
          bearing: 0,
          tilt: 0,
        ),
      ),
    );
    _centeredOnCurrentLocation = true;
  }

  Future<void> _onMapCreated(MapLibreMapController controller) async {
    _controller = controller;
  }

  Future<void> _onStyleLoaded() async {
    _styleReady = true;
    await _refreshMap();
  }

  Future<void> _refreshMap() async {
    if (!_styleReady || _controller == null) return;
    await _renderAnnotations();
    if (_hasRoute) {
      await _fitRoute();
    } else if (_currentLocation != null &&
        widget.centerOnCurrentLocation &&
        widget.initialCenter == null &&
        !_centeredOnCurrentLocation) {
      await _moveToCurrentLocation();
    }
  }

  Future<void> _renderAnnotations() async {
    final controller = _controller;
    if (controller == null || !_styleReady) return;

    await controller.clearLines();
    await controller.clearCircles();

    final route = _routeMapPoints.map(_toLatLng).toList();
    if (route.length >= 2) {
      await controller.addLine(
        LineOptions(
          geometry: route,
          lineColor: '#FFFFFF',
          lineWidth: 12,
          lineOpacity: 0.98,
          lineJoin: 'round',
        ),
      );
      await controller.addLine(
        LineOptions(
          geometry: route,
          lineColor: '#087AF0',
          lineWidth: 7,
          lineOpacity: 1,
          lineJoin: 'round',
        ),
      );
    }

    if (widget.showCurrentLocationMarker && _currentLocation != null) {
      await controller.addCircle(
        CircleOptions(
          geometry: _toLatLng(_currentLocation!),
          circleRadius: 14,
          circleColor: '#087AF0',
          circleOpacity: 0.16,
          circleStrokeWidth: 0,
        ),
      );
      await controller.addCircle(
        CircleOptions(
          geometry: _toLatLng(_currentLocation!),
          circleRadius: 8,
          circleColor: '#087AF0',
          circleStrokeColor: '#FFFFFF',
          circleStrokeWidth: 3,
          circleStrokeOpacity: 1,
        ),
      );
    }

    if (widget.origin != null) {
      await controller.addCircle(
        CircleOptions(
          geometry: _toLatLng(widget.origin!),
          circleRadius: 7,
          circleColor: '#172B4D',
          circleStrokeColor: '#FFFFFF',
          circleStrokeWidth: 3,
          circleStrokeOpacity: 1,
        ),
      );
    }

    if (widget.destination != null) {
      await controller.addCircle(
        CircleOptions(
          geometry: _toLatLng(widget.destination!),
          circleRadius: 9,
          circleColor: '#F15B5A',
          circleStrokeColor: '#FFFFFF',
          circleStrokeWidth: 3,
          circleStrokeOpacity: 1,
        ),
      );
    }
  }

  Future<void> _fitRoute() async {
    final controller = _controller;
    final points = _routeMapPoints;
    if (controller == null || points.length < 2 || !_styleReady) return;

    final latitudes = points.map((point) => point.latitude).toList();
    final longitudes = points.map((point) => point.longitude).toList();
    final south = latitudes.reduce((a, b) => a < b ? a : b);
    final north = latitudes.reduce((a, b) => a > b ? a : b);
    final west = longitudes.reduce((a, b) => a < b ? a : b);
    final east = longitudes.reduce((a, b) => a > b ? a : b);

    if ((north - south).abs() < 0.0001 && (east - west).abs() < 0.0001) {
      await controller.animateCamera(
        CameraUpdate.newLatLngZoom(_toLatLng(points.first), 16),
      );
      return;
    }

    await controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(south, west),
          northeast: LatLng(north, east),
        ),
        left: _routePadding,
        top: _routePadding,
        right: _routePadding,
        bottom: _routePadding + 20,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        MapLibreMap(
          styleString: _mapStyleAsset,
          initialCameraPosition: CameraPosition(
            target: _toLatLng(_center),
            zoom: _hasRoute ? 12 : 13,
          ),
          onMapCreated: _onMapCreated,
          onStyleLoadedCallback: _onStyleLoaded,
          onMapClick: widget.onTap == null
              ? null
              : (_, point) =>
                    widget.onTap!(MapPoint(point.latitude, point.longitude)),
          compassEnabled: false,
          logoEnabled: false,
          scaleControlEnabled: false,
          myLocationEnabled: false,
          dragEnabled: widget.interactive,
          scrollGesturesEnabled: widget.interactive,
          zoomGesturesEnabled: widget.interactive,
          rotateGesturesEnabled: widget.interactive,
          tiltGesturesEnabled: widget.interactive,
          doubleClickZoomEnabled: widget.interactive,
          foregroundLoadColor: Colors.transparent,
          annotationOrder: const [
            AnnotationType.line,
            AnnotationType.circle,
            AnnotationType.symbol,
            AnnotationType.fill,
          ],
        ),
        if (widget.showAttribution)
          const Positioned(left: 8, bottom: 7, child: _MapAttributionChip()),
        if (widget.showCurrentLocation)
          Positioned(
            right: 12,
            bottom: widget.showAttribution ? 34 : 12,
            child: Material(
              color: Colors.white,
              elevation: 4,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: _selectCurrentLocation,
                child: const Padding(
                  padding: EdgeInsets.all(11),
                  child: Icon(
                    Icons.my_location_rounded,
                    size: 20,
                    color: Color(0xff172B4D),
                  ),
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
            right: 58,
            child: _MapStatusChip(label: _locationMessage!),
          ),
      ],
    );
  }

  static LatLng _toLatLng(MapPoint point) =>
      LatLng(point.latitude, point.longitude);
}

class MapRoutePreview extends StatefulWidget {
  final String originAddress;
  final String destinationAddress;
  final MapPoint? origin;
  final MapPoint? destination;
  final List<MapPoint>? routePoints;
  final bool showCurrentLocation;

  const MapRoutePreview({
    super.key,
    required this.originAddress,
    required this.destinationAddress,
    this.origin,
    this.destination,
    this.routePoints,
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
        final locations = await geocoder.locationFromAddress(
          widget.originAddress,
        );
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
        final locations = await geocoder.locationFromAddress(
          widget.destinationAddress,
        );
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
      routePoints: widget.routePoints,
      showCurrentLocation: widget.showCurrentLocation,
      interactive: false,
    );
  }
}

class _MapAttributionChip extends StatelessWidget {
  const _MapAttributionChip();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(5),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 3)],
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        child: Text(
          '© OpenFreeMap · © OpenStreetMap',
          style: TextStyle(fontSize: 9, color: Color(0xff69727D)),
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
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(9),
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
