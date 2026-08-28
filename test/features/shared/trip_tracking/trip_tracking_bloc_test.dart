import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:frota_mobile/features/shared/trip_tracking/data/dtos/trip_bridge_message.dart';
import 'package:frota_mobile/features/shared/trip_tracking/domain/entities/canonical_route.dart';
import 'package:frota_mobile/features/shared/trip_tracking/domain/entities/route_waypoint.dart';
import 'package:frota_mobile/features/shared/trip_tracking/domain/entities/tracked_position.dart';
import 'package:frota_mobile/features/shared/trip_tracking/domain/entities/trip_tracking_snapshot.dart';
import 'package:frota_mobile/features/shared/trip_tracking/domain/entities/trip_waiting_state.dart';
import 'package:frota_mobile/features/shared/trip_tracking/domain/repositories/trip_tracking_repository.dart';
import 'package:frota_mobile/features/shared/trip_tracking/presentation/bloc/trip_tracking_bloc.dart';
import 'package:frota_mobile/features/shared/trip_tracking/presentation/services/passenger_distance_guard.dart';
import 'package:frota_mobile/features/shared/trip_tracking/presentation/services/trip_location_service.dart';

void main() {
  test('passageiro nunca solicita recálculo', () async {
    final repository = _FakeRepository();
    final bloc = _bloc(repository);
    final outbound = <TripBridgeMessage>[];
    final subscription = bloc.outboundMessages.listen(outbound.add);
    await bloc.start('123', TripRole.passenger);
    await bloc.handleWebMessage(_web(TripMessageType.rerouteRequested));
    await Future<void>.delayed(Duration.zero);
    expect(repository.rerouteCalls, 0);
    expect(outbound.last.type, TripMessageType.commandFailed);
    await subscription.cancel();
    await bloc.close();
  });

  test(
    'motorista solicita recálculo e substitui somente por versão maior',
    () async {
      final repository = _FakeRepository();
      final bloc = _bloc(repository);
      final outbound = <TripBridgeMessage>[];
      final subscription = bloc.outboundMessages.listen(outbound.add);
      await bloc.start('123', TripRole.driver);
      final command = _web(TripMessageType.rerouteRequested);
      await bloc.handleWebMessage(command);
      await Future<void>.delayed(Duration.zero);
      expect(repository.rerouteCalls, 1);
      expect(repository.lastCommandEventId, command.eventId);
      expect(bloc.state.snapshot!.route.version, 2);
      expect(
        outbound.map((item) => item.type),
        contains(TripMessageType.routeReplaced),
      );
      await subscription.cancel();
      await bloc.close();
    },
  );

  test('entra e sai do modo de espera', () async {
    final bloc = _bloc(_FakeRepository());
    await bloc.start('123', TripRole.driver);
    await bloc.handleWebMessage(_web(TripMessageType.waitingConfirmed));
    expect(bloc.state.snapshot!.waiting.active, isTrue);
    expect(bloc.state.snapshot!.waiting.startedAt, isNotNull);
    await bloc.handleWebMessage(_web(TripMessageType.waitingResumeRequested));
    expect(bloc.state.snapshot!.waiting.active, isFalse);
    await bloc.close();
  });

  test(
    'ignora posição atrasada e versão antiga recebidas do backend',
    () async {
      final repository = _FakeRepository();
      final bloc = _bloc(repository);
      await bloc.start('123', TripRole.passenger);
      final newerPosition = TrackedPosition(
        lat: -23.31,
        lng: -51.11,
        accuracy: 5,
        speed: 10,
        heading: 90,
        timestamp: DateTime.utc(2026, 8, 24, 15, 31),
      );
      repository.eventController.add(
        TripBridgeMessage.create(
          type: TripMessageType.vehicleLocation,
          tripId: '123',
          payload: newerPosition.toJson(),
        ),
      );
      repository.eventController.add(
        TripBridgeMessage.create(
          type: TripMessageType.routeReplaced,
          tripId: '123',
          payload: _route(2).toJson(),
        ),
      );
      await Future<void>.delayed(Duration.zero);

      repository.eventController.add(
        TripBridgeMessage.create(
          type: TripMessageType.vehicleLocation,
          tripId: '123',
          payload: _position().toJson(),
        ),
      );
      repository.eventController.add(
        TripBridgeMessage.create(
          type: TripMessageType.routeReplaced,
          tripId: '123',
          payload: _route(1).toJson(),
        ),
      );
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.snapshot!.vehiclePosition, newerPosition);
      expect(bloc.state.snapshot!.route.version, 2);
      await bloc.close();
    },
  );

  test('limpa subscriptions ao fechar', () async {
    final repository = _FakeRepository();
    final location = _FakeLocationSource();
    final bloc = _bloc(repository, location: location);
    await bloc.start('123', TripRole.driver);
    await bloc.close();
    expect(repository.disconnectCalls, 1);
    expect(location.disposed, isTrue);
  });

  test('preserva eventos recebidos enquanto carrega o snapshot', () async {
    final repository = _FakeRepository()..loadGate = Completer<void>();
    final bloc = _bloc(repository);
    final starting = bloc.start('123', TripRole.passenger);
    await repository.loadStarted.future;
    repository.eventController.add(
      TripBridgeMessage.create(
        type: TripMessageType.routeReplaced,
        tripId: '123',
        payload: _route(2).toJson(),
      ),
    );
    await Future<void>.delayed(Duration.zero);
    repository.loadGate!.complete();
    await starting;
    expect(bloc.state.snapshot!.route.version, 2);
    await bloc.close();
  });

  test(
    'envia GPS local imediatamente e reduz publicações no backend',
    () async {
      final repository = _FakeRepository();
      final location = _FakeLocationSource();
      final bloc = TripTrackingBloc(
        repository: repository,
        locationService: location,
        distanceGuard: PassengerDistanceGuard(
          thresholdMeters: 100,
          requiredConsecutiveReadings: 3,
        ),
        backendUpdateInterval: const Duration(milliseconds: 20),
      );
      final outbound = <TripBridgeMessage>[];
      final subscription = bloc.outboundMessages.listen(outbound.add);
      await bloc.start('123', TripRole.driver);
      location.emit(_positionAt(31));
      location.emit(_positionAt(32));
      location.emit(_positionAt(33));
      await Future<void>.delayed(const Duration(milliseconds: 35));

      expect(
        outbound.where((item) => item.type == TripMessageType.vehicleLocation),
        hasLength(3),
      );
      expect(repository.publishedVehiclePositions, hasLength(2));
      expect(repository.publishedVehiclePositions.last, _positionAt(33));
      await subscription.cancel();
      await bloc.close();
    },
  );
}

TripTrackingBloc _bloc(
  _FakeRepository repository, {
  _FakeLocationSource? location,
}) => TripTrackingBloc(
  repository: repository,
  locationService: location ?? _FakeLocationSource(),
  distanceGuard: PassengerDistanceGuard(
    thresholdMeters: 100,
    requiredConsecutiveReadings: 3,
  ),
);

TripBridgeMessage _web(String type) =>
    TripBridgeMessage.create(type: type, tripId: '123');

class _FakeLocationSource implements TripLocationSource {
  final _positions = StreamController<TrackedPosition>.broadcast();
  bool disposed = false;
  bool _running = false;
  @override
  bool get isRunning => _running;
  @override
  Stream<TrackedPosition> get positions => _positions.stream;
  void emit(TrackedPosition position) => _positions.add(position);
  @override
  Future<void> start({required bool backgroundTracking}) async {
    _running = true;
  }

  @override
  Future<void> stop() async {
    _running = false;
  }

  @override
  Future<void> dispose() async {
    disposed = true;
    await _positions.close();
  }
}

class _FakeRepository implements TripTrackingRepository {
  final eventController = StreamController<TripBridgeMessage>.broadcast();
  final connectionController = StreamController<bool>.broadcast();
  int rerouteCalls = 0;
  int disconnectCalls = 0;
  String? lastCommandEventId;
  final publishedVehiclePositions = <TrackedPosition>[];
  final loadStarted = Completer<void>();
  Completer<void>? loadGate;

  @override
  Stream<TripBridgeMessage> get events => eventController.stream;
  @override
  Stream<bool> get connectionChanges => connectionController.stream;
  @override
  Future<TripTrackingSnapshot> loadSnapshot(
    String tripId,
    TripRole role,
  ) async {
    if (!loadStarted.isCompleted) loadStarted.complete();
    await loadGate?.future;
    return _snapshot(role, 1);
  }

  @override
  Future<void> connect(String tripId, TripRole role) async =>
      connectionController.add(true);
  @override
  Future<void> disconnect() async {
    disconnectCalls++;
  }

  @override
  Future<CanonicalRoute> requestReroute(
    String tripId,
    TrackedPosition position,
    String commandEventId,
  ) async {
    rerouteCalls++;
    lastCommandEventId = commandEventId;
    return _route(2);
  }

  @override
  Future<TripWaitingState> confirmWaiting(
    String tripId,
    String commandEventId,
  ) async => TripWaitingState(active: true, startedAt: DateTime.now().toUtc());
  @override
  Future<TripWaitingState> resumeWaiting(
    String tripId,
    String commandEventId,
  ) async => const TripWaitingState.inactive();
  @override
  Future<void> finishTrip(String tripId, String commandEventId) async {}
  @override
  Future<void> flushOfflinePositions(String tripId) async {}
  @override
  Future<void> clearTrip(String tripId) async {}
  @override
  Future<void> publishPassengerPosition(
    String tripId,
    TrackedPosition position,
  ) async {}
  @override
  Future<void> publishVehiclePosition(
    String tripId,
    TrackedPosition position,
  ) async => publishedVehiclePositions.add(position);
}

TripTrackingSnapshot _snapshot(TripRole role, int version) =>
    TripTrackingSnapshot(
      tripId: '123',
      role: role,
      tripStatus: 'in_progress',
      waiting: const TripWaitingState.inactive(),
      route: _route(version),
      vehiclePosition: _position(),
    );

CanonicalRoute _route(int version) {
  const origin = RouteWaypoint(
    id: 'origin',
    sequence: 0,
    kind: RouteWaypointKind.origin,
    label: 'Origem',
    lat: -23.3,
    lng: -51.1,
  );
  const destination = RouteWaypoint(
    id: 'destination',
    sequence: 1,
    kind: RouteWaypointKind.destination,
    label: 'Destino',
    lat: -23.4,
    lng: -51.2,
  );
  return CanonicalRoute(
    routeId: 'route-$version',
    version: version,
    calculatedAt: DateTime.utc(2026, 8, 24),
    origin: origin,
    stops: const [],
    destination: destination,
    coordinates: [_position()],
    distanceMeters: 1000,
    durationSeconds: 100,
  );
}

TrackedPosition _position() => TrackedPosition(
  lat: -23.3,
  lng: -51.1,
  accuracy: 5,
  speed: 10,
  heading: 90,
  timestamp: DateTime.utc(2026, 8, 24, 15, 30),
);

TrackedPosition _positionAt(int minute) => TrackedPosition(
  lat: -23.3 + minute / 100000,
  lng: -51.1,
  accuracy: 5,
  speed: 10,
  heading: 90,
  timestamp: DateTime.utc(2026, 8, 24, 15, minute),
);
