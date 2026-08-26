import '../../data/dtos/trip_bridge_message.dart';
import '../../domain/entities/canonical_route.dart';
import '../../domain/entities/tracked_position.dart';
import '../../domain/entities/trip_tracking_snapshot.dart';
import '../../domain/entities/trip_waiting_state.dart';
import '../../domain/repositories/trip_tracking_repository.dart';
import '../datasources/trip_position_buffer.dart';
import '../datasources/trip_tracking_remote_datasource.dart';
import '../datasources/trip_tracking_socket_datasource.dart';

class TripTrackingRepositoryImpl implements TripTrackingRepository {
  final TripTrackingRemoteDatasource remoteDatasource;
  final TripTrackingSocketDatasource socketDatasource;
  final TripPositionBuffer positionBuffer;
  TrackedPosition? _lastVehiclePosition;

  TripTrackingRepositoryImpl({
    required this.remoteDatasource,
    required this.socketDatasource,
    required this.positionBuffer,
  });

  @override
  Stream<TripBridgeMessage> get events => socketDatasource.events;
  @override
  Stream<bool> get connectionChanges => socketDatasource.connectionChanges;

  @override
  Future<TripTrackingSnapshot> loadSnapshot(String tripId, TripRole role) =>
      remoteDatasource.loadSnapshot(tripId, role);

  @override
  Future<void> connect(String tripId, TripRole role) async {
    await socketDatasource.connect(tripId, role);
  }

  @override
  Future<void> disconnect() => socketDatasource.disconnect();

  @override
  Future<void> publishVehiclePosition(
    String tripId,
    TrackedPosition position,
  ) async {
    if (!position.isNewerThan(_lastVehiclePosition)) return;
    _lastVehiclePosition = position;
    if (!socketDatasource.connected) {
      await positionBuffer.add(tripId, position);
      return;
    }
    socketDatasource.sendVehiclePosition(tripId, position);
    try {
      await remoteDatasource.sendPositions(tripId, [position]);
    } on Object {
      await positionBuffer.add(tripId, position);
    }
  }

  @override
  Future<void> publishPassengerPosition(
    String tripId,
    TrackedPosition position,
  ) async {
    socketDatasource.sendPassengerPosition(tripId, position);
    try {
      await remoteDatasource.sendPassengerPosition(tripId, position);
    } on Object {
      // A posição do passageiro é auxiliar e não integra a fila do veículo.
    }
  }

  @override
  Future<void> flushOfflinePositions(String tripId) async {
    if (!socketDatasource.connected) return;
    final pending = await positionBuffer.read(tripId);
    if (pending.isEmpty) return;
    try {
      await remoteDatasource.sendPositions(tripId, pending);
      await positionBuffer.clear(tripId);
    } on Object {
      // Mantém a fila intacta para a próxima reconexão.
    }
  }

  @override
  Future<CanonicalRoute> requestReroute(
    String tripId,
    TrackedPosition position,
    String commandEventId,
  ) => remoteDatasource.requestReroute(tripId, position, commandEventId);

  @override
  Future<TripWaitingState> confirmWaiting(
    String tripId,
    String commandEventId,
  ) => remoteDatasource.confirmWaiting(tripId, commandEventId);

  @override
  Future<TripWaitingState> resumeWaiting(
    String tripId,
    String commandEventId,
  ) => remoteDatasource.resumeWaiting(tripId, commandEventId);

  @override
  Future<void> finishTrip(String tripId, String commandEventId) =>
      remoteDatasource.finishTrip(tripId, commandEventId);

  @override
  Future<void> clearTrip(String tripId) async {
    _lastVehiclePosition = null;
    await positionBuffer.clear(tripId);
  }
}
