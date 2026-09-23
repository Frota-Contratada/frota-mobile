import '../../domain/entities/canonical_route.dart';
import '../../domain/entities/navigation_instruction.dart';
import '../../domain/entities/route_waypoint.dart';
import '../../domain/entities/tracked_position.dart';
import '../../domain/entities/trip_tracking_snapshot.dart';
import '../../domain/entities/trip_waiting_state.dart';
import 'trip_tracking_remote_datasource.dart';

class TripTrackingMockDatasource implements TripTrackingRemoteDatasource {
  final Map<String, TripTrackingSnapshot> _snapshots = {};
  final Map<String, Object> _commandResults = {};

  String _commandKey(String tripId, String eventId) => '$tripId:$eventId';

  @override
  Future<TripTrackingSnapshot> loadSnapshot(
    String tripId,
    TripRole role,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final existing = _snapshots[tripId];
    if (existing != null) {
      return TripTrackingSnapshot(
        tripId: existing.tripId,
        role: role,
        tripStatus: existing.tripStatus,
        waiting: existing.waiting,
        route: existing.route,
        vehiclePosition: existing.vehiclePosition,
        driver: existing.driver,
        vehicle: existing.vehicle,
        startedAt: existing.startedAt,
        updatedAt: existing.updatedAt,
      );
    }
    final snapshot = _buildSnapshot(tripId, role);
    _snapshots[tripId] = snapshot;
    return snapshot;
  }

  @override
  Future<void> sendPositions(
    String tripId,
    List<TrackedPosition> positions,
  ) async {
    if (positions.isEmpty) return;
    final current = _snapshots[tripId];
    if (current != null &&
        positions.last.isNewerThan(current.vehiclePosition)) {
      _snapshots[tripId] = current.copyWith(vehiclePosition: positions.last);
    }
  }

  @override
  Future<void> sendPassengerPosition(
    String tripId,
    TrackedPosition position,
  ) async {
    final current = _snapshots[tripId];
    if (current != null && position.isNewerThan(current.passengerPosition)) {
      _snapshots[tripId] = current.copyWith(passengerPosition: position);
    }
  }

  @override
  Future<CanonicalRoute> requestReroute(
    String tripId,
    TrackedPosition position,
    String commandEventId,
  ) async {
    final key = _commandKey(tripId, commandEventId);
    final previous = _commandResults[key];
    if (previous is CanonicalRoute) return previous;
    final current =
        _snapshots[tripId] ?? _buildSnapshot(tripId, TripRole.driver);
    final route = CanonicalRoute(
      routeId: '${current.route.routeId}-v${current.route.version + 1}',
      version: current.route.version + 1,
      calculatedAt: DateTime.now().toUtc(),
      origin: current.route.origin,
      stops: current.route.stops,
      destination: current.route.destination,
      coordinates: [position, ...current.route.coordinates.skip(1)],
      distanceMeters: current.route.distanceMeters,
      durationSeconds: current.route.durationSeconds,
      trafficDelaySeconds: current.route.trafficDelaySeconds,
      trafficSections: current.route.trafficSections,
      instructions: current.route.instructions,
    );
    _snapshots[tripId] = current.copyWith(route: route);
    _commandResults[key] = route;
    return route;
  }

  @override
  Future<TripWaitingState> confirmWaiting(
    String tripId,
    String commandEventId,
  ) async {
    final key = _commandKey(tripId, commandEventId);
    final previous = _commandResults[key];
    if (previous is TripWaitingState) return previous;
    final waiting = TripWaitingState(
      active: true,
      startedAt: DateTime.now().toUtc(),
    );
    final current = _snapshots[tripId];
    if (current != null) {
      _snapshots[tripId] = current.copyWith(waiting: waiting);
    }
    _commandResults[key] = waiting;
    return waiting;
  }

  @override
  Future<TripWaitingState> resumeWaiting(
    String tripId,
    String commandEventId,
  ) async {
    final key = _commandKey(tripId, commandEventId);
    final previous = _commandResults[key];
    if (previous is TripWaitingState) return previous;
    const waiting = TripWaitingState.inactive();
    final current = _snapshots[tripId];
    if (current != null) {
      _snapshots[tripId] = current.copyWith(waiting: waiting);
    }
    _commandResults[key] = waiting;
    return waiting;
  }

  @override
  Future<void> finishTrip(String tripId, String commandEventId) async {
    final key = _commandKey(tripId, commandEventId);
    if (_commandResults.containsKey(key)) return;
    final current = _snapshots[tripId];
    if (current != null) {
      _snapshots[tripId] = current.copyWith(tripStatus: 'finished');
    }
    _commandResults[key] = true;
  }

  TripTrackingSnapshot _buildSnapshot(String tripId, TripRole role) {
    final now = DateTime.now().toUtc();
    final origin = const RouteWaypoint(
      id: 'origin',
      sequence: 0,
      kind: RouteWaypointKind.origin,
      label: 'Origem da corrida',
      lat: -23.3045,
      lng: -51.1696,
    );
    final destination = const RouteWaypoint(
      id: 'destination',
      sequence: 1,
      kind: RouteWaypointKind.destination,
      label: 'Destino da corrida',
      lat: -23.4000,
      lng: -51.2000,
    );
    final start = TrackedPosition(
      lat: origin.lat,
      lng: origin.lng,
      accuracy: 8,
      speed: 0,
      heading: 95,
      timestamp: now,
    );
    return TripTrackingSnapshot(
      tripId: tripId,
      role: role,
      tripStatus: 'in_progress',
      waiting: const TripWaitingState.inactive(),
      route: CanonicalRoute(
        routeId: 'route-$tripId-v1',
        version: 1,
        calculatedAt: now,
        origin: origin,
        stops: const [],
        destination: destination,
        coordinates: [
          start,
          TrackedPosition(
            lat: -23.34,
            lng: -51.18,
            accuracy: 0,
            speed: 0,
            heading: 0,
            timestamp: now,
          ),
          TrackedPosition(
            lat: destination.lat,
            lng: destination.lng,
            accuracy: 0,
            speed: 0,
            heading: 0,
            timestamp: now,
          ),
        ],
        distanceMeters: 15000,
        durationSeconds: 1800,
        trafficDelaySeconds: 420,
        instructions: const [
          NavigationInstruction(
            id: 'instruction-1',
            instruction: 'Siga em frente até o destino',
            streetName: 'Avenida Principal',
            distanceMeters: 15000,
            durationSeconds: 1800,
            type: 'arrive',
            modifier: 'straight',
            icon: 'arrow-up',
            location: NavigationInstructionLocation(lat: -23.4, lng: -51.2),
            coordinateIndex: 2,
          ),
        ],
      ),
      vehiclePosition: start,
      driver: const TripParticipant(
        id: 'mock-driver',
        displayName: 'Motorista',
      ),
      vehicle: const TrackedVehicle(id: 'mock-vehicle', plate: 'ABC1D23'),
      startedAt: now,
      updatedAt: now,
    );
  }
}
