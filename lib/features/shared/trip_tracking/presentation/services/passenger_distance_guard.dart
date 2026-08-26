import 'dart:math' as math;
import '../../domain/entities/tracked_position.dart';

class PassengerDistanceGuard {
  final double thresholdMeters;
  final int requiredConsecutiveReadings;
  int _readingsOutside = 0;

  PassengerDistanceGuard({
    required this.thresholdMeters,
    required this.requiredConsecutiveReadings,
  });

  bool register({
    required TrackedPosition passenger,
    required TrackedPosition vehicle,
  }) {
    final outside = _distanceMeters(passenger, vehicle) > thresholdMeters;
    _readingsOutside = outside ? _readingsOutside + 1 : 0;
    return _readingsOutside >= requiredConsecutiveReadings;
  }

  void reset() => _readingsOutside = 0;
}

double _distanceMeters(TrackedPosition a, TrackedPosition b) {
  const radius = 6371000.0;
  final lat1 = a.lat * math.pi / 180;
  final lat2 = b.lat * math.pi / 180;
  final dLat = (b.lat - a.lat) * math.pi / 180;
  final dLng = (b.lng - a.lng) * math.pi / 180;
  final h =
      math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(lat1) * math.cos(lat2) * math.sin(dLng / 2) * math.sin(dLng / 2);
  return radius * 2 * math.atan2(math.sqrt(h), math.sqrt(1 - h));
}
