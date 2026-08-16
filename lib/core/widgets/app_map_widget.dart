import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import '../maps/map_point.dart';
import '../maps/map_route.dart';
import '../maps/routing_service.dart';

const _defaultMapCenter = MapPoint(-23.3045, -51.1696);
const _mapStyleAsset = 'assets/maps/frota_uber_style.json';
const _routePadding = 56.0;

class AppMapWidget extends StatefulWidget {
  final MapPoint? origin;
  final MapPoint? destination;
  final List<MapPoint>? viaPoints;
  final List<MapPoint>? routePoints;
  final MapPoint? initialCenter;
  final ValueChanged<MapPoint>? onTap;
  final VoidCallback? onCurrentLocation;

  /// Informa a distância e a duração do trajeto sempre que ele é recalculado.
  final ValueChanged<MapRoute>? onRouteResolved;
  final bool showCurrentLocation;
  final bool showCurrentLocationMarker;
  final bool centerOnCurrentLocation;
  final bool interactive;
  final bool showAttribution;

  /// Quando `false`, mantém o traçado em linha reta entre os pontos.
  final bool followRoads;

  /// Permite injetar outro serviço de roteirização, útil em testes.
  final RoutingService? routingService;

  const AppMapWidget({
    super.key,
    this.origin,
    this.destination,
    this.viaPoints,
    this.routePoints,
    this.initialCenter,
    this.onTap,
    this.onCurrentLocation,
    this.onRouteResolved,
    this.showCurrentLocation = true,
    this.showCurrentLocationMarker = true,
    this.centerOnCurrentLocation = true,
    this.interactive = true,
    this.showAttribution = true,
    this.followRoads = true,
    this.routingService,
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

  // Impede que múltiplas renderizações do mapa aconteçam simultaneamente.
  bool _renderingAnnotations = false;
  bool _renderRequested = false;

  // Identifica a última requisição de rota, para descartar respostas antigas
  // quando o usuário troca os pontos antes de a anterior terminar.
  int _routeRequestId = 0;

  List<MapPoint>? _resolvedRoutePoints;
  bool _loadingRoute = false;

  RoutingService get _routingService =>
      widget.routingService ?? mapRoutingService;

  bool get _hasRoute => _routeMapPoints.length >= 2;

  /// Pontos escolhidos pelo usuário, na ordem em que devem ser percorridos.
  List<MapPoint> get _waypoints => _waypointsOf(widget);

  static List<MapPoint> _waypointsOf(AppMapWidget widget) => List.unmodifiable([
    if (widget.origin != null) widget.origin!,
    ...?widget.viaPoints,
    if (widget.destination != null) widget.destination!,
  ]);

  /// Assinatura dos pontos, para detectar mudança real de trajeto sem depender
  /// da identidade das listas recriadas em cada build.
  static String _assinaturaDe(List<MapPoint> pontos) =>
      pontos.map((ponto) => '${ponto.latitude},${ponto.longitude}').join(';');

  /// Geometria desenhada no mapa.
  ///
  /// A rota informada por quem usa o widget tem prioridade. Sem ela, vale o
  /// caminho por vias reais devolvido pelo serviço de roteirização e, se ele
  /// não estiver disponível, os próprios pontos ligados em linha reta.
  List<MapPoint> get _routeMapPoints {
    final providedRoute = widget.routePoints;

    if (providedRoute != null && providedRoute.length >= 2) {
      return List.unmodifiable(providedRoute);
    }

    final resolved = _resolvedRoutePoints;

    if (resolved != null && resolved.length >= 2) {
      return List.unmodifiable(resolved);
    }

    return _waypoints;
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
      unawaited(_startLocationTracking());
    } else {
      _loadingLocation = false;
    }

    unawaited(_resolveRoute());
  }

  @override
  void didUpdateWidget(covariant AppMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    final mapContentChanged =
        oldWidget.origin != widget.origin ||
        oldWidget.destination != widget.destination ||
        oldWidget.viaPoints != widget.viaPoints ||
        oldWidget.routePoints != widget.routePoints ||
        oldWidget.showCurrentLocationMarker != widget.showCurrentLocationMarker;

    final locationVisibilityChanged =
        oldWidget.showCurrentLocation != widget.showCurrentLocation;

    final centerBehaviorChanged =
        oldWidget.centerOnCurrentLocation != widget.centerOnCurrentLocation ||
        oldWidget.initialCenter != widget.initialCenter;

    if (locationVisibilityChanged) {
      if (widget.showCurrentLocation) {
        _loadingLocation = true;
        _locationMessage = null;
        unawaited(_startLocationTracking());
      } else {
        _loadingLocation = false;
        _locationMessage = null;
        unawaited(_stopLocationTracking());
      }
    }

    if (widget.initialCenter != oldWidget.initialCenter) {
      _centeredOnCurrentLocation = false;
    }

    if (centerBehaviorChanged &&
        widget.centerOnCurrentLocation &&
        widget.initialCenter == null &&
        _currentLocation != null &&
        !_hasRoute &&
        _styleReady) {
      unawaited(_moveToCurrentLocation());
    }

    final trajetoChanged =
        _assinaturaDe(_waypointsOf(oldWidget)) != _assinaturaDe(_waypoints) ||
        oldWidget.followRoads != widget.followRoads ||
        oldWidget.routePoints != widget.routePoints;

    if (trajetoChanged) {
      unawaited(_resolveRoute());
    }

    if (mapContentChanged && _styleReady) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          unawaited(_refreshMap());
        }
      });
    }
  }

  // Busca o caminho mais rápido entre os pontos selecionados.
  
  // Enquanto a resposta não chega — ou se ela falhar — o mapa continua
  // mostrando os pontos ligados em linha reta, então o usuário nunca fica
  // sem referência visual do trajeto.
  Future<void> _resolveRoute() async {
    final rotaInformada = widget.routePoints;

    if (rotaInformada != null && rotaInformada.length >= 2) {
      return;
    }

    final pontos = _waypoints;

    // O estado anterior ao await é atribuído direto: este método é chamado de
    // initState e de didUpdateWidget, onde um build já vem a seguir e chamar
    // setState seria inválido.
    if (!widget.followRoads || pontos.length < 2) {
      _resolvedRoutePoints = null;
      _loadingRoute = false;

      return;
    }

    final requestId = ++_routeRequestId;

    _loadingRoute = true;

    final rota = await _routingService.buscarRota(pontos);

    if (!mounted || requestId != _routeRequestId) return;

    setState(() {
      _loadingRoute = false;
      _resolvedRoutePoints = rota?.points;
    });

    if (rota != null) {
      widget.onRouteResolved?.call(rota);
    }

    if (_styleReady) {
      await _refreshMap();
    }
  }

  @override
  void dispose() {
    unawaited(_stopLocationTracking());
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

      if (!mounted || !widget.showCurrentLocation) return;

      _updateCurrentLocation(position);

      if (!mounted || !widget.showCurrentLocation) return;

      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      ).listen(_updateCurrentLocation);
    } catch (error, stackTrace) {
      debugPrint('Erro ao obter localização: $error');
      debugPrintStack(stackTrace: stackTrace);

      _setLocationMessage('Não foi possível obter a localização atual.');
    }
  }

  Future<void> _stopLocationTracking() async {
    final subscription = _positionSubscription;

    _positionSubscription = null;

    if (subscription != null) {
      await subscription.cancel();
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
    if (!mounted || !widget.showCurrentLocation) return;

    final wasFirstLocation = _currentLocation == null;

    setState(() {
      _currentLocation = MapPoint(position.latitude, position.longitude);
      _loadingLocation = false;
      _locationMessage = null;
    });

    if (_styleReady && widget.showCurrentLocationMarker) {
      unawaited(_updateLocationAnnotation());
    }

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
      unawaited(_startLocationTracking());
      return;
    }

    unawaited(_moveToCurrentLocation());

    widget.onTap?.call(current);
    widget.onCurrentLocation?.call();
  }

  Future<void> _moveToCurrentLocation() async {
    final current = _currentLocation;
    final controller = _controller;

    if (current == null || controller == null || !_styleReady) {
      return;
    }

    try {
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

      if (!mounted) return;

      _centeredOnCurrentLocation = true;
    } catch (error, stackTrace) {
      debugPrint('Erro ao centralizar localização: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
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
      _centeredOnCurrentLocation = false;
      await _fitRoute();
    } else if (_currentLocation != null &&
        widget.centerOnCurrentLocation &&
        widget.initialCenter == null &&
        !_centeredOnCurrentLocation) {
      await _moveToCurrentLocation();
    }
  }

  /// Solicita uma nova renderização.
  ///
  /// Se uma renderização já estiver acontecendo, apenas marca que outra
  /// renderização será necessária ao final da atual.
  Future<void> _renderAnnotations() async {
    if (!_styleReady || _controller == null) return;

    if (_renderingAnnotations) {
      _renderRequested = true;
      return;
    }

    _renderingAnnotations = true;

    try {
      do {
        _renderRequested = false;

        final controller = _controller;

        if (controller == null || !_styleReady) {
          return;
        }

        await controller.clearLines();
        await controller.clearCircles();

        if (!_styleReady || !mounted) return;

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
          await _addCurrentLocationCircles(controller, _currentLocation!);
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

        for (final viaPoint in widget.viaPoints ?? const <MapPoint>[]) {
          await controller.addCircle(
            CircleOptions(
              geometry: _toLatLng(viaPoint),
              circleRadius: 7,
              circleColor: '#F0A43C',
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
      } while (_renderRequested && mounted);
    } catch (error, stackTrace) {
      debugPrint('Erro ao renderizar annotations: $error');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      _renderingAnnotations = false;
    }
  }

  Future<void> _updateLocationAnnotation() async {
    if (!_styleReady || _controller == null) return;

    // A API de annotations do MapLibre não fornece aqui uma referência
    // persistente ao círculo existente. Portanto, a atualização da posição
    // ainda exige uma renderização dos círculos.
    //
    // O controle de concorrência de _renderAnnotations impede que múltiplas
    // operações de clear/add aconteçam simultaneamente.
    await _renderAnnotations();
  }

  Future<void> _addCurrentLocationCircles(
    MapLibreMapController controller,
    MapPoint location,
  ) async {
    await controller.addCircle(
      CircleOptions(
        geometry: _toLatLng(location),
        circleRadius: 14,
        circleColor: '#087AF0',
        circleOpacity: 0.16,
        circleStrokeWidth: 0,
      ),
    );

    await controller.addCircle(
      CircleOptions(
        geometry: _toLatLng(location),
        circleRadius: 8,
        circleColor: '#087AF0',
        circleStrokeColor: '#FFFFFF',
        circleStrokeWidth: 3,
        circleStrokeOpacity: 1,
      ),
    );
  }

  Future<void> _fitRoute() async {
    final controller = _controller;
    final points = _routeMapPoints;

    if (controller == null || points.length < 2 || !_styleReady) {
      return;
    }

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
              : (_, point) {
                  widget.onTap!(MapPoint(point.latitude, point.longitude));
                },
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
        if (_loadingRoute && !_loadingLocation && _locationMessage == null)
          const Positioned(
            top: 10,
            left: 10,
            child: _MapStatusChip(label: 'Calculando a melhor rota...'),
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
  final List<MapPoint>? viaPoints;
  final List<MapPoint>? routePoints;
  final bool showCurrentLocation;

  const MapRoutePreview({
    super.key,
    required this.originAddress,
    required this.destinationAddress,
    this.origin,
    this.destination,
    this.viaPoints,
    this.routePoints,
    this.showCurrentLocation = false,
  });

  @override
  State<MapRoutePreview> createState() => _MapRoutePreviewState();
}

class _MapRoutePreviewState extends State<MapRoutePreview> {
  MapPoint? _origin;
  MapPoint? _destination;

  int _geocodingRequestId = 0;

  @override
  void initState() {
    super.initState();

    _origin = widget.origin;
    _destination = widget.destination;

    unawaited(_resolveAddresses());
  }

  @override
  void didUpdateWidget(covariant MapRoutePreview oldWidget) {
    super.didUpdateWidget(oldWidget);

    final addressesChanged =
        oldWidget.originAddress != widget.originAddress ||
        oldWidget.destinationAddress != widget.destinationAddress;

    final pointsChanged =
        oldWidget.origin != widget.origin ||
        oldWidget.destination != widget.destination;

    if (addressesChanged || pointsChanged) {
      _origin = widget.origin;
      _destination = widget.destination;

      unawaited(_resolveAddresses());
    }
  }

  Future<void> _resolveAddresses() async {
    final requestId = ++_geocodingRequestId;

    final geocoder = Geocoding();

    var resolvedOrigin = widget.origin;
    var resolvedDestination = widget.destination;

    if (resolvedOrigin == null && widget.originAddress.trim().isNotEmpty) {
      try {
        final locations = await geocoder.locationFromAddress(
          widget.originAddress.trim(),
        );

        if (locations.isNotEmpty) {
          resolvedOrigin = MapPoint(
            locations.first.latitude,
            locations.first.longitude,
          );
        }
      } catch (error, stackTrace) {
        debugPrint(
          'Erro ao geocodificar origem "${widget.originAddress}": $error',
        );
        debugPrintStack(stackTrace: stackTrace);
      }
    }

    if (!mounted || requestId != _geocodingRequestId) {
      return;
    }

    if (resolvedDestination == null &&
        widget.destinationAddress.trim().isNotEmpty) {
      try {
        final locations = await geocoder.locationFromAddress(
          widget.destinationAddress.trim(),
        );

        if (locations.isNotEmpty) {
          resolvedDestination = MapPoint(
            locations.first.latitude,
            locations.first.longitude,
          );
        }
      } catch (error, stackTrace) {
        debugPrint(
          'Erro ao geocodificar destino '
          '"${widget.destinationAddress}": $error',
        );
        debugPrintStack(stackTrace: stackTrace);
      }
    }

    if (!mounted || requestId != _geocodingRequestId) {
      return;
    }

    setState(() {
      _origin = resolvedOrigin;
      _destination = resolvedDestination;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppMapWidget(
      origin: _origin,
      destination: _destination,
      viaPoints: widget.viaPoints,
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
  } catch (error, stackTrace) {
    debugPrint(
      'Erro ao fazer reverse geocoding '
      '(${point.latitude}, ${point.longitude}): $error',
    );
    debugPrintStack(stackTrace: stackTrace);

    return null;
  }
}
