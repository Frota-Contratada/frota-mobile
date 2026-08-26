import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/dtos/trip_bridge_message.dart';
import '../../domain/entities/canonical_route.dart';
import '../../domain/entities/tracked_position.dart';
import '../../domain/entities/trip_tracking_snapshot.dart';
import '../../domain/entities/trip_waiting_state.dart';
import '../../domain/repositories/trip_tracking_repository.dart';
import '../services/passenger_distance_guard.dart';
import '../services/trip_location_service.dart';

class TripTrackingState extends Equatable {
  final bool loading;
  final bool connected;
  final TripTrackingSnapshot? snapshot;
  final String? errorMessage;
  final bool passengerDistanceAlert;
  final bool finished;

  const TripTrackingState({
    this.loading = true,
    this.connected = false,
    this.snapshot,
    this.errorMessage,
    this.passengerDistanceAlert = false,
    this.finished = false,
  });

  TripTrackingState copyWith({
    bool? loading,
    bool? connected,
    TripTrackingSnapshot? snapshot,
    String? errorMessage,
    bool clearError = false,
    bool? passengerDistanceAlert,
    bool? finished,
  }) => TripTrackingState(
    loading: loading ?? this.loading,
    connected: connected ?? this.connected,
    snapshot: snapshot ?? this.snapshot,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    passengerDistanceAlert:
        passengerDistanceAlert ?? this.passengerDistanceAlert,
    finished: finished ?? this.finished,
  );

  @override
  List<Object?> get props => [
    loading,
    connected,
    snapshot,
    errorMessage,
    passengerDistanceAlert,
    finished,
  ];
}

class TripTrackingBloc extends Cubit<TripTrackingState> {
  final TripTrackingRepository repository;
  final TripLocationSource locationService;
  final PassengerDistanceGuard distanceGuard;
  final Duration backendUpdateInterval;
  final _outbound = StreamController<TripBridgeMessage>.broadcast();
  StreamSubscription<TripBridgeMessage>? _eventSubscription;
  StreamSubscription<bool>? _connectionSubscription;
  StreamSubscription<TrackedPosition>? _positionSubscription;
  String? _tripId;
  TripRole? _role;
  bool _closedByFinish = false;
  final List<TripBridgeMessage> _pendingBackendEvents = [];
  Future<void>? _snapshotLoadInFlight;
  bool _synchronizingSnapshot = false;
  Timer? _backendPositionTimer;
  TrackedPosition? _pendingBackendPosition;
  Future<void> _backendPublishQueue = Future<void>.value();

  TripTrackingBloc({
    required this.repository,
    required this.locationService,
    required this.distanceGuard,
    this.backendUpdateInterval = const Duration(seconds: 4),
  }) : super(const TripTrackingState());

  Stream<TripBridgeMessage> get outboundMessages => _outbound.stream;
  TripRole? get role => _role;
  bool get hasSimulator => locationService is SimulatedTripLocationService;
  SimulatedTripLocationService? get _simulator =>
      locationService is SimulatedTripLocationService
      ? locationService as SimulatedTripLocationService
      : null;
  bool get simulationPlaying => _simulator?.playing ?? false;
  double get simulationSpeed => _simulator?.speed ?? 0;
  double get simulationHeading => _simulator?.heading ?? 0;

  Future<void> start(String tripId, TripRole role) async {
    _tripId = tripId;
    _role = role;
    _pendingBackendEvents.clear();
    _pendingBackendPosition = null;
    emit(const TripTrackingState(loading: true));
    try {
      _eventSubscription = repository.events.listen(_handleBackendEvent);
      _connectionSubscription = repository.connectionChanges.listen((
        connected,
      ) {
        emit(state.copyWith(connected: connected));
        _send(TripMessageType.connectionChanged, {'connected': connected});
        if (connected) {
          unawaited(repository.flushOfflinePositions(tripId));
          if (state.snapshot != null && !_synchronizingSnapshot) {
            unawaited(_synchronizeSnapshot());
          }
        }
      });
      try {
        await repository.connect(tripId, role);
      } on Object {
        // O snapshot ainda é útil offline; uma reconexão posterior o reconciliará.
      }
      await _synchronizeSnapshot();

      _positionSubscription = locationService.positions.listen(_handlePosition);
      try {
        await locationService.start(
          backgroundTracking: role == TripRole.driver,
        );
      } on TripLocationException catch (error) {
        if (role == TripRole.driver) {
          emit(state.copyWith(errorMessage: error.message));
        }
      }
    } on Object {
      emit(
        state.copyWith(
          loading: false,
          errorMessage: 'Não foi possível carregar os dados da corrida.',
        ),
      );
    }
  }

  Future<void> _synchronizeSnapshot() {
    final active = _snapshotLoadInFlight;
    if (active != null) return active;
    final future = _loadAndReconcileSnapshot();
    _snapshotLoadInFlight = future;
    return future.whenComplete(() {
      if (identical(_snapshotLoadInFlight, future)) {
        _snapshotLoadInFlight = null;
      }
    });
  }

  Future<void> _loadAndReconcileSnapshot() async {
    final tripId = _tripId;
    final role = _role;
    if (tripId == null || role == null) return;
    _synchronizingSnapshot = true;
    try {
      final loaded = await repository.loadSnapshot(tripId, role);
      if (isClosed || tripId != _tripId) return;
      final current = state.snapshot;
      final snapshot = current == null
          ? loaded
          : _mergeSnapshots(current, loaded);
      emit(
        state.copyWith(loading: false, snapshot: snapshot, clearError: true),
      );
      final pending = List<TripBridgeMessage>.of(_pendingBackendEvents);
      _pendingBackendEvents.clear();
      _synchronizingSnapshot = false;
      for (final message in pending) {
        _applyBackendEvent(message);
      }
      final reconciled = state.snapshot;
      if (reconciled != null) {
        _send(TripMessageType.bootstrap, reconciled.toBootstrapPayload());
      }
    } finally {
      _synchronizingSnapshot = false;
    }
  }

  TripTrackingSnapshot _mergeSnapshots(
    TripTrackingSnapshot current,
    TripTrackingSnapshot loaded,
  ) => loaded.copyWith(
    route: current.route.isNewerThan(loaded.route)
        ? current.route
        : loaded.route,
    vehiclePosition:
        current.vehiclePosition?.isNewerThan(loaded.vehiclePosition) == true
        ? current.vehiclePosition
        : loaded.vehiclePosition,
    passengerPosition:
        current.passengerPosition?.isNewerThan(loaded.passengerPosition) == true
        ? current.passengerPosition
        : loaded.passengerPosition,
  );

  Future<void> _handlePosition(TrackedPosition position) async {
    final tripId = _tripId;
    final role = _role;
    final snapshot = state.snapshot;
    if (tripId == null || role == null || snapshot == null) return;

    if (role == TripRole.driver) {
      if (!position.isNewerThan(snapshot.vehiclePosition)) return;
      final updated = snapshot.copyWith(
        vehiclePosition: position,
        updatedAt: DateTime.now().toUtc(),
      );
      emit(state.copyWith(snapshot: updated));
      _send(TripMessageType.vehicleLocation, position.toJson());
      _queueBackendPosition(position);
      return;
    }

    if (!position.isNewerThan(snapshot.passengerPosition)) return;
    final updated = snapshot.copyWith(passengerPosition: position);
    var showAlert = false;
    final vehicle = snapshot.vehiclePosition;
    if (vehicle != null) {
      showAlert = distanceGuard.register(passenger: position, vehicle: vehicle);
    }
    emit(state.copyWith(snapshot: updated, passengerDistanceAlert: showAlert));
    _send(TripMessageType.passengerLocation, position.toJson());
    _queueBackendPosition(position);
  }

  void _handleBackendEvent(TripBridgeMessage message) {
    if (_synchronizingSnapshot || state.snapshot == null) {
      _pendingBackendEvents.add(message);
      return;
    }
    _applyBackendEvent(message);
  }

  void _applyBackendEvent(TripBridgeMessage message) {
    final snapshot = state.snapshot;
    if (snapshot == null) return;
    try {
      if (message.type == TripMessageType.vehicleLocation) {
        final position = TrackedPosition.fromJson(message.payload);
        if (!position.isNewerThan(snapshot.vehiclePosition)) return;
        emit(
          state.copyWith(
            snapshot: snapshot.copyWith(vehiclePosition: position),
          ),
        );
      } else if (message.type == TripMessageType.routeReplaced) {
        final route = CanonicalRoute.fromJson(message.payload);
        if (!route.isNewerThan(snapshot.route)) return;
        emit(state.copyWith(snapshot: snapshot.copyWith(route: route)));
      } else if (message.type == TripMessageType.waitingChanged) {
        emit(
          state.copyWith(
            snapshot: snapshot.copyWith(
              waiting: TripWaitingState.fromJson(message.payload),
            ),
          ),
        );
      } else if (message.type == TripMessageType.statusChanged) {
        emit(
          state.copyWith(
            snapshot: snapshot.copyWith(
              tripStatus:
                  message.payload['tripStatus'] as String? ??
                  snapshot.tripStatus,
            ),
          ),
        );
      }
      _outbound.add(message);
    } on FormatException {
      return;
    } on TypeError {
      return;
    }
  }

  void _queueBackendPosition(TrackedPosition position) {
    _pendingBackendPosition = position;
    if (_backendPositionTimer != null) return;
    unawaited(_flushBackendPosition());
    _backendPositionTimer = Timer.periodic(
      backendUpdateInterval,
      (_) => unawaited(_flushBackendPosition()),
    );
  }

  Future<void> _flushBackendPosition() {
    _backendPublishQueue = _backendPublishQueue.then((_) async {
      final tripId = _tripId;
      final role = _role;
      final position = _pendingBackendPosition;
      if (tripId == null || role == null || position == null) return;
      _pendingBackendPosition = null;
      if (role == TripRole.driver) {
        await repository.publishVehiclePosition(tripId, position);
      } else {
        await repository.publishPassengerPosition(tripId, position);
      }
    });
    return _backendPublishQueue;
  }

  Future<void> handleWebMessage(TripBridgeMessage message) async {
    final tripId = _tripId;
    final snapshot = state.snapshot;
    if (tripId == null || snapshot == null) return;

    try {
      switch (message.type) {
        case TripMessageType.webReady:
        case TripMessageType.webLog:
          return;
        case TripMessageType.rerouteRequested:
          if (_role != TripRole.driver || snapshot.vehiclePosition == null) {
            throw StateError('Recálculo permitido somente ao motorista.');
          }
          final route = await repository.requestReroute(
            tripId,
            snapshot.vehiclePosition!,
            message.eventId,
          );
          if (route.isNewerThan(state.snapshot?.route)) {
            emit(
              state.copyWith(snapshot: state.snapshot!.copyWith(route: route)),
            );
            _send(TripMessageType.routeReplaced, route.toJson());
          }
          _commandSucceeded(message);
          return;
        case TripMessageType.waitingConfirmed:
          _requireDriver();
          final waiting = await repository.confirmWaiting(
            tripId,
            message.eventId,
          );
          emit(
            state.copyWith(
              snapshot: state.snapshot!.copyWith(waiting: waiting),
            ),
          );
          _send(TripMessageType.waitingChanged, waiting.toJson());
          _commandSucceeded(message);
          return;
        case TripMessageType.waitingResumeRequested:
          _requireDriver();
          final waiting = await repository.resumeWaiting(
            tripId,
            message.eventId,
          );
          emit(
            state.copyWith(
              snapshot: state.snapshot!.copyWith(waiting: waiting),
            ),
          );
          _send(TripMessageType.waitingChanged, waiting.toJson());
          _commandSucceeded(message);
          return;
        case TripMessageType.finishRequested:
          _requireDriver();
          await repository.finishTrip(tripId, message.eventId);
          _send(TripMessageType.statusChanged, {'tripStatus': 'finished'});
          _commandSucceeded(message);
          _closedByFinish = true;
          await _stopTracking(clearBuffer: true);
          emit(state.copyWith(finished: true));
          return;
      }
    } on Object catch (error) {
      _send(TripMessageType.commandFailed, {
        'commandEventId': message.eventId,
        'commandType': message.type,
        'reason': error is StateError
            ? error.message
            : 'Não foi possível executar o comando.',
      });
    }
  }

  void _requireDriver() {
    if (_role != TripRole.driver) {
      throw StateError('Comando permitido somente ao motorista.');
    }
  }

  void _commandSucceeded(TripBridgeMessage command) {
    _send(TripMessageType.commandSucceeded, {
      'commandEventId': command.eventId,
      'commandType': command.type,
    });
  }

  void _send(String type, Map<String, dynamic> payload) {
    final tripId = _tripId;
    if (tripId == null || _outbound.isClosed) return;
    _outbound.add(
      TripBridgeMessage.create(type: type, tripId: tripId, payload: payload),
    );
  }

  void dismissPassengerAlert() {
    distanceGuard.reset();
    emit(state.copyWith(passengerDistanceAlert: false));
  }

  void configureSimulation({bool? playing, double? speed, double? heading}) {
    _simulator?.configure(playing: playing, speed: speed, heading: heading);
  }

  void simulateDeviation() => _simulator?.deviate();

  void simulatePassengerAway() {
    final simulator = _simulator;
    if (simulator == null) return;
    for (
      var index = 0;
      index < distanceGuard.requiredConsecutiveReadings;
      index++
    ) {
      simulator.movePassengerAway();
    }
  }

  Future<void> simulateRerouteRequest() => handleWebMessage(
    TripBridgeMessage.create(
      type: TripMessageType.rerouteRequested,
      tripId: _tripId ?? '',
    ),
  );

  Future<void> simulateWaitingToggle() => handleWebMessage(
    TripBridgeMessage.create(
      type: state.snapshot?.waiting.active == true
          ? TripMessageType.waitingResumeRequested
          : TripMessageType.waitingConfirmed,
      tripId: _tripId ?? '',
    ),
  );

  Future<void> simulateConnection(bool connected) async {
    final tripId = _tripId;
    final role = _role;
    if (tripId == null || role == null) return;
    if (connected) {
      await repository.connect(tripId, role);
    } else {
      await repository.disconnect();
    }
    emit(state.copyWith(connected: connected));
    _send(TripMessageType.connectionChanged, {'connected': connected});
  }

  Future<void> onAppPaused() async {
    if (_role == TripRole.passenger) await locationService.stop();
  }

  Future<void> onAppResumed() async {
    final role = _role;
    if (role == null || locationService.isRunning || state.finished) return;
    try {
      await locationService.start(backgroundTracking: role == TripRole.driver);
      emit(state.copyWith(clearError: true));
    } on TripLocationException catch (error) {
      if (role == TripRole.driver) {
        emit(state.copyWith(errorMessage: error.message));
      }
    }
  }

  Future<void> retry() async {
    final tripId = _tripId;
    final role = _role;
    if (tripId == null || role == null) return;
    await _stopTracking(clearBuffer: false);
    await start(tripId, role);
  }

  Future<void> _stopTracking({required bool clearBuffer}) async {
    await _positionSubscription?.cancel();
    _positionSubscription = null;
    _backendPositionTimer?.cancel();
    _backendPositionTimer = null;
    await _flushBackendPosition();
    await locationService.stop();
    await _eventSubscription?.cancel();
    _eventSubscription = null;
    await _connectionSubscription?.cancel();
    _connectionSubscription = null;
    await repository.disconnect();
    _pendingBackendEvents.clear();
    if (clearBuffer && _tripId != null) {
      await repository.clearTrip(_tripId!);
    }
  }

  @override
  Future<void> close() async {
    await _stopTracking(clearBuffer: _closedByFinish);
    await locationService.dispose();
    await _outbound.close();
    return super.close();
  }
}
