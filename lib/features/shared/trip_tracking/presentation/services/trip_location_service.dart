import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../../domain/entities/tracked_position.dart';

abstract class TripLocationSource {
  Stream<TrackedPosition> get positions;
  bool get isRunning;
  Future<void> start({required bool backgroundTracking});
  Future<void> stop();
  Future<void> dispose();
}

class TripLocationException implements Exception {
  final String message;
  const TripLocationException(this.message);
  @override
  String toString() => message;
}

class TripLocationService implements TripLocationSource {
  static const nativeUpdateInterval = Duration(milliseconds: 500);
  static const heartbeatInterval = Duration(seconds: 1);
  static const maxAccuracyMeters = 50.0;

  final _positions = StreamController<TrackedPosition>.broadcast();
  StreamSubscription<Position>? _nativeSubscription;
  Timer? _periodicTimer;
  Position? _latestNative;
  DateTime? _lastEmissionAt;
  bool _running = false;

  @override
  Stream<TrackedPosition> get positions => _positions.stream;

  @override
  bool get isRunning => _running;

  @override
  Future<void> start({required bool backgroundTracking}) async {
    if (_running) return;
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const TripLocationException('Ative a localização do aparelho.');
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw const TripLocationException(
        'Permissão de localização necessária para acompanhar a corrida.',
      );
    }

    _running = true;
    _nativeSubscription =
        Geolocator.getPositionStream(
          locationSettings: _settings(backgroundTracking),
        ).listen((position) {
          if (position.accuracy < 0 || position.accuracy > maxAccuracyMeters) {
            return;
          }
          _latestNative = position;
          _emitLatest(minimumSpacing: nativeUpdateInterval);
        });
    _periodicTimer = Timer.periodic(
      heartbeatInterval,
      (_) => _emitLatest(minimumSpacing: heartbeatInterval),
    );
  }

  LocationSettings _settings(bool backgroundTracking) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 0,
        intervalDuration: nativeUpdateInterval,
        foregroundNotificationConfig: backgroundTracking
            ? const ForegroundNotificationConfig(
                notificationTitle: 'Corrida em andamento',
                notificationText: 'Compartilhando a posição do veículo.',
                enableWakeLock: true,
              )
            : null,
      );
    }
    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      return AppleSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        activityType: ActivityType.automotiveNavigation,
        distanceFilter: 0,
        pauseLocationUpdatesAutomatically: false,
        showBackgroundLocationIndicator: backgroundTracking,
      );
    }
    return const LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 0,
    );
  }

  void _emitLatest({required Duration minimumSpacing}) {
    final position = _latestNative;
    if (!_running || position == null || _positions.isClosed) return;
    final now = DateTime.now().toUtc();
    final lastEmissionAt = _lastEmissionAt;
    if (lastEmissionAt != null &&
        now.difference(lastEmissionAt) < minimumSpacing) {
      return;
    }
    _lastEmissionAt = now;
    _positions.add(
      TrackedPosition(
        lat: position.latitude,
        lng: position.longitude,
        accuracy: position.accuracy,
        speed: position.speed < 0 ? 0 : position.speed,
        heading: position.heading < 0 ? 0 : position.heading,
        timestamp: now,
      ),
    );
  }

  @override
  Future<void> stop() async {
    _running = false;
    _periodicTimer?.cancel();
    _periodicTimer = null;
    await _nativeSubscription?.cancel();
    _nativeSubscription = null;
    _latestNative = null;
    _lastEmissionAt = null;
  }

  @override
  Future<void> dispose() async {
    await stop();
    await _positions.close();
  }
}

class SimulatedTripLocationService implements TripLocationSource {
  static const updateInterval = Duration(milliseconds: 750);
  final _positions = StreamController<TrackedPosition>.broadcast(sync: true);
  Timer? _timer;
  bool _running = false;
  bool playing = true;
  double speed = 12;
  double heading = 95;
  double _lat = -23.3045;
  double _lng = -51.1696;
  DateTime? _lastTimestamp;

  @override
  Stream<TrackedPosition> get positions => _positions.stream;
  @override
  bool get isRunning => _running;

  void configure({bool? playing, double? speed, double? heading}) {
    this.playing = playing ?? this.playing;
    this.speed = speed ?? this.speed;
    this.heading = heading ?? this.heading;
  }

  void deviate() {
    _lat += 0.01;
    _lng += 0.01;
    _emit();
  }

  void movePassengerAway() {
    _lat += 0.003;
    _lng += 0.003;
    _emit();
  }

  @override
  Future<void> start({required bool backgroundTracking}) async {
    if (_running) return;
    _running = true;
    _emit();
    _timer = Timer.periodic(updateInterval, (_) {
      if (!playing) return;
      final radians = heading * math.pi / 180;
      final meters = speed * updateInterval.inMilliseconds / 1000;
      _lat += (meters * math.cos(radians)) / 111320;
      _lng +=
          (meters * math.sin(radians)) /
          (111320 * math.cos(_lat * math.pi / 180).abs());
      _emit();
    });
  }

  void _emit() {
    if (!_running || _positions.isClosed) return;
    var timestamp = DateTime.now().toUtc();
    final previous = _lastTimestamp;
    if (previous != null && !timestamp.isAfter(previous)) {
      timestamp = previous.add(const Duration(microseconds: 1));
    }
    _lastTimestamp = timestamp;
    _positions.add(
      TrackedPosition(
        lat: _lat,
        lng: _lng,
        accuracy: 6,
        speed: speed,
        heading: heading,
        timestamp: timestamp,
      ),
    );
  }

  @override
  Future<void> stop() async {
    _running = false;
    _timer?.cancel();
    _timer = null;
  }

  @override
  Future<void> dispose() async {
    await stop();
    await _positions.close();
  }
}
