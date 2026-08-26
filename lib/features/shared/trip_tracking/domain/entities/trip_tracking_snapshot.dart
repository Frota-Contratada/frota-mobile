import 'package:equatable/equatable.dart';
import 'canonical_route.dart';
import 'tracked_position.dart';
import 'trip_waiting_state.dart';

enum TripRole { driver, passenger }

class TripParticipant extends Equatable {
  final String id;
  final String displayName;

  const TripParticipant({required this.id, required this.displayName});

  factory TripParticipant.fromJson(Map<String, dynamic> json) =>
      TripParticipant(
        id: json['id']?.toString() ?? '',
        displayName: json['displayName'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {'id': id, 'displayName': displayName};

  @override
  List<Object?> get props => [id, displayName];
}

class TrackedVehicle extends Equatable {
  final String id;
  final String plate;
  final String? description;

  const TrackedVehicle({
    required this.id,
    required this.plate,
    this.description,
  });

  factory TrackedVehicle.fromJson(Map<String, dynamic> json) => TrackedVehicle(
    id: json['id']?.toString() ?? '',
    plate: json['plate'] as String? ?? '',
    description: json['description'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'plate': plate,
    if (description != null) 'description': description,
  };

  @override
  List<Object?> get props => [id, plate, description];
}

class TripTrackingSnapshot extends Equatable {
  final String tripId;
  final TripRole role;
  final String tripStatus;
  final TripWaitingState waiting;
  final CanonicalRoute route;
  final TrackedPosition? vehiclePosition;
  final TrackedPosition? passengerPosition;
  final TripParticipant? driver;
  final TrackedVehicle? vehicle;
  final DateTime? startedAt;
  final DateTime? updatedAt;

  const TripTrackingSnapshot({
    required this.tripId,
    required this.role,
    required this.tripStatus,
    required this.waiting,
    required this.route,
    this.vehiclePosition,
    this.passengerPosition,
    this.driver,
    this.vehicle,
    this.startedAt,
    this.updatedAt,
  });

  factory TripTrackingSnapshot.fromJson(
    Map<String, dynamic> json, {
    required String tripId,
    required TripRole role,
  }) => TripTrackingSnapshot(
    tripId: tripId,
    role: role,
    tripStatus: json['tripStatus'] as String? ?? 'in_progress',
    waiting: TripWaitingState.fromJson(
      (json['waiting'] as Map<String, dynamic>?) ?? const {'active': false},
    ),
    route: CanonicalRoute.fromJson(json['route'] as Map<String, dynamic>),
    vehiclePosition: json['vehiclePosition'] is Map<String, dynamic>
        ? TrackedPosition.fromJson(
            json['vehiclePosition'] as Map<String, dynamic>,
          )
        : null,
    passengerPosition: json['passengerPosition'] is Map<String, dynamic>
        ? TrackedPosition.fromJson(
            json['passengerPosition'] as Map<String, dynamic>,
          )
        : null,
    driver: json['driver'] is Map<String, dynamic>
        ? TripParticipant.fromJson(json['driver'] as Map<String, dynamic>)
        : null,
    vehicle: json['vehicle'] is Map<String, dynamic>
        ? TrackedVehicle.fromJson(json['vehicle'] as Map<String, dynamic>)
        : null,
    startedAt: _date(json['startedAt']),
    updatedAt: _date(json['updatedAt']),
  );

  Map<String, dynamic> toBootstrapPayload() => {
    'role': role.name,
    'tripStatus': tripStatus,
    'waiting': waiting.toJson(),
    'route': route.toJson(),
    if (vehiclePosition != null) 'vehiclePosition': vehiclePosition!.toJson(),
    if (passengerPosition != null)
      'passengerPosition': passengerPosition!.toJson(),
    if (driver != null) 'driver': driver!.toJson(),
    if (vehicle != null) 'vehicle': vehicle!.toJson(),
    if (startedAt != null) 'startedAt': startedAt!.toUtc().toIso8601String(),
    if (updatedAt != null) 'updatedAt': updatedAt!.toUtc().toIso8601String(),
  };

  TripTrackingSnapshot copyWith({
    String? tripStatus,
    TripWaitingState? waiting,
    CanonicalRoute? route,
    TrackedPosition? vehiclePosition,
    TrackedPosition? passengerPosition,
    DateTime? updatedAt,
  }) => TripTrackingSnapshot(
    tripId: tripId,
    role: role,
    tripStatus: tripStatus ?? this.tripStatus,
    waiting: waiting ?? this.waiting,
    route: route ?? this.route,
    vehiclePosition: vehiclePosition ?? this.vehiclePosition,
    passengerPosition: passengerPosition ?? this.passengerPosition,
    driver: driver,
    vehicle: vehicle,
    startedAt: startedAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  @override
  List<Object?> get props => [
    tripId,
    role,
    tripStatus,
    waiting,
    route,
    vehiclePosition,
    passengerPosition,
    driver,
    vehicle,
    startedAt,
    updatedAt,
  ];
}

DateTime? _date(Object? value) =>
    value is String ? DateTime.tryParse(value)?.toUtc() : null;
