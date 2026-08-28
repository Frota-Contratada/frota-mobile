import 'package:equatable/equatable.dart';

class TrackedPosition extends Equatable {
  final double lat;
  final double lng;
  final double accuracy;
  final double speed;
  final double heading;
  final DateTime timestamp;

  const TrackedPosition({
    required this.lat,
    required this.lng,
    required this.accuracy,
    required this.speed,
    required this.heading,
    required this.timestamp,
  });

  factory TrackedPosition.fromJson(Map<String, dynamic> json) =>
      TrackedPosition(
        lat: (json['lat'] as num).toDouble(),
        lng: (json['lng'] as num).toDouble(),
        accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0,
        speed: (json['speed'] as num?)?.toDouble() ?? 0,
        heading: (json['heading'] as num?)?.toDouble() ?? 0,
        timestamp: DateTime.parse(json['timestamp'] as String).toUtc(),
      );

  Map<String, dynamic> toJson() => {
    'lat': lat,
    'lng': lng,
    'accuracy': accuracy,
    'speed': speed,
    'heading': heading,
    'timestamp': timestamp.toUtc().toIso8601String(),
  };

  bool isNewerThan(TrackedPosition? other) =>
      other == null || timestamp.isAfter(other.timestamp);

  @override
  List<Object?> get props => [lat, lng, accuracy, speed, heading, timestamp];
}
