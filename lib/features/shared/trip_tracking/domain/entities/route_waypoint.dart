import 'package:equatable/equatable.dart';

enum RouteWaypointKind { origin, stop, destination }

class RouteWaypoint extends Equatable {
  final String id;
  final int sequence;
  final RouteWaypointKind kind;
  final String label;
  final double lat;
  final double lng;

  const RouteWaypoint({
    required this.id,
    required this.sequence,
    required this.kind,
    required this.label,
    required this.lat,
    required this.lng,
  });

  factory RouteWaypoint.fromJson(Map<String, dynamic> json) => RouteWaypoint(
    id: json['id'] as String,
    sequence: (json['sequence'] as num).toInt(),
    kind: RouteWaypointKind.values.byName(json['kind'] as String),
    label: json['label'] as String? ?? '',
    lat: (json['lat'] as num).toDouble(),
    lng: (json['lng'] as num).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'sequence': sequence,
    'kind': kind.name,
    'label': label,
    'lat': lat,
    'lng': lng,
  };

  @override
  List<Object?> get props => [id, sequence, kind, label, lat, lng];
}
