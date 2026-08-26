import 'package:equatable/equatable.dart';

class NavigationInstructionLocation extends Equatable {
  final double lat;
  final double lng;

  const NavigationInstructionLocation({required this.lat, required this.lng});

  factory NavigationInstructionLocation.fromJson(Map<String, dynamic> json) =>
      NavigationInstructionLocation(
        lat: (json['lat'] as num).toDouble(),
        lng: (json['lng'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {'lat': lat, 'lng': lng};

  @override
  List<Object?> get props => [lat, lng];
}

class NavigationInstruction extends Equatable {
  final String id;
  final String instruction;
  final String streetName;
  final int distanceMeters;
  final int durationSeconds;
  final String type;
  final String? modifier;
  final String? icon;
  final NavigationInstructionLocation location;
  final int coordinateIndex;

  const NavigationInstruction({
    required this.id,
    required this.instruction,
    required this.streetName,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.type,
    this.modifier,
    this.icon,
    required this.location,
    required this.coordinateIndex,
  });

  factory NavigationInstruction.fromJson(Map<String, dynamic> json) =>
      NavigationInstruction(
        id: json['id'] as String,
        instruction: json['instruction'] as String,
        streetName: json['streetName'] as String? ?? '',
        distanceMeters: (json['distanceMeters'] as num?)?.toInt() ?? 0,
        durationSeconds: (json['durationSeconds'] as num?)?.toInt() ?? 0,
        type: json['type'] as String,
        modifier: json['modifier'] as String?,
        icon: json['icon'] as String?,
        location: NavigationInstructionLocation.fromJson(
          json['location'] as Map<String, dynamic>,
        ),
        coordinateIndex: (json['coordinateIndex'] as num).toInt(),
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'instruction': instruction,
    'streetName': streetName,
    'distanceMeters': distanceMeters,
    'durationSeconds': durationSeconds,
    'type': type,
    'modifier': modifier,
    'icon': icon,
    'location': location.toJson(),
    'coordinateIndex': coordinateIndex,
  };

  @override
  List<Object?> get props => [
    id,
    instruction,
    streetName,
    distanceMeters,
    durationSeconds,
    type,
    modifier,
    icon,
    location,
    coordinateIndex,
  ];
}
