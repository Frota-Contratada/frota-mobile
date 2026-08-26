import 'package:equatable/equatable.dart';
import 'navigation_instruction.dart';
import 'route_waypoint.dart';
import 'tracked_position.dart';

class TrafficSection extends Equatable {
  final int startIndex;
  final int endIndex;
  final int delaySeconds;
  final String category;

  const TrafficSection({
    required this.startIndex,
    required this.endIndex,
    required this.delaySeconds,
    required this.category,
  });

  factory TrafficSection.fromJson(Map<String, dynamic> json) => TrafficSection(
    startIndex: (json['startIndex'] as num?)?.toInt() ?? 0,
    endIndex: (json['endIndex'] as num?)?.toInt() ?? 0,
    delaySeconds: (json['delaySeconds'] as num?)?.toInt() ?? 0,
    category: json['category'] as String? ?? 'unknown',
  );

  Map<String, dynamic> toJson() => {
    'startIndex': startIndex,
    'endIndex': endIndex,
    'delaySeconds': delaySeconds,
    'category': category,
  };

  @override
  List<Object?> get props => [startIndex, endIndex, delaySeconds, category];
}

class CanonicalRoute extends Equatable {
  final String routeId;
  final int version;
  final DateTime calculatedAt;
  final RouteWaypoint origin;
  final List<RouteWaypoint> stops;
  final RouteWaypoint destination;
  final List<TrackedPosition> coordinates;
  final int distanceMeters;
  final int durationSeconds;
  final int trafficDelaySeconds;
  final List<TrafficSection> trafficSections;
  final List<NavigationInstruction> instructions;

  const CanonicalRoute({
    required this.routeId,
    required this.version,
    required this.calculatedAt,
    required this.origin,
    required this.stops,
    required this.destination,
    required this.coordinates,
    required this.distanceMeters,
    required this.durationSeconds,
    this.trafficDelaySeconds = 0,
    this.trafficSections = const [],
    this.instructions = const [],
  });

  factory CanonicalRoute.fromJson(Map<String, dynamic> json) => CanonicalRoute(
    routeId: json['routeId'] as String,
    version: (json['version'] as num).toInt(),
    calculatedAt: DateTime.parse(json['calculatedAt'] as String).toUtc(),
    origin: RouteWaypoint.fromJson(json['origin'] as Map<String, dynamic>),
    stops:
        ((json['stops'] as List?) ?? const [])
            .map((item) => RouteWaypoint.fromJson(item as Map<String, dynamic>))
            .toList()
          ..sort((a, b) => a.sequence.compareTo(b.sequence)),
    destination: RouteWaypoint.fromJson(
      json['destination'] as Map<String, dynamic>,
    ),
    coordinates: ((json['coordinates'] as List?) ?? const []).map((item) {
      final point = item as Map<String, dynamic>;
      return TrackedPosition(
        lat: (point['lat'] as num).toDouble(),
        lng: (point['lng'] as num).toDouble(),
        accuracy: 0,
        speed: 0,
        heading: 0,
        timestamp: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      );
    }).toList(),
    distanceMeters: (json['distanceMeters'] as num?)?.toInt() ?? 0,
    durationSeconds: (json['durationSeconds'] as num?)?.toInt() ?? 0,
    trafficDelaySeconds: (json['trafficDelaySeconds'] as num?)?.toInt() ?? 0,
    trafficSections: ((json['trafficSections'] as List?) ?? const [])
        .map((item) => TrafficSection.fromJson(item as Map<String, dynamic>))
        .toList(),
    instructions: ((json['instructions'] as List?) ?? const [])
        .map(
          (item) =>
              NavigationInstruction.fromJson(item as Map<String, dynamic>),
        )
        .toList(),
  );

  bool isNewerThan(CanonicalRoute? other) =>
      other == null || version > other.version;

  Map<String, dynamic> toJson() => {
    'routeId': routeId,
    'version': version,
    'calculatedAt': calculatedAt.toUtc().toIso8601String(),
    'origin': origin.toJson(),
    'stops': stops.map((item) => item.toJson()).toList(),
    'destination': destination.toJson(),
    'coordinates': coordinates
        .map((item) => {'lat': item.lat, 'lng': item.lng})
        .toList(),
    'distanceMeters': distanceMeters,
    'durationSeconds': durationSeconds,
    'trafficDelaySeconds': trafficDelaySeconds,
    'trafficSections': trafficSections.map((item) => item.toJson()).toList(),
    'instructions': instructions.map((item) => item.toJson()).toList(),
  };

  @override
  List<Object?> get props => [
    routeId,
    version,
    calculatedAt,
    origin,
    stops,
    destination,
    coordinates,
    distanceMeters,
    durationSeconds,
    trafficDelaySeconds,
    trafficSections,
    instructions,
  ];
}
