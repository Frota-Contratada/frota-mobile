import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frota_mobile/features/shared/trip_tracking/data/datasources/trip_position_buffer.dart';
import 'package:frota_mobile/features/shared/trip_tracking/data/datasources/trip_tracking_remote_datasource.dart';
import 'package:frota_mobile/features/shared/trip_tracking/data/datasources/trip_tracking_socket_datasource.dart';
import 'package:frota_mobile/features/shared/trip_tracking/data/dtos/trip_bridge_message.dart';
import 'package:frota_mobile/features/shared/trip_tracking/data/repositories/trip_tracking_repository_impl.dart';
import 'package:frota_mobile/features/shared/trip_tracking/domain/entities/canonical_route.dart';
import 'package:frota_mobile/features/shared/trip_tracking/domain/entities/tracked_position.dart';
import 'package:frota_mobile/features/shared/trip_tracking/domain/entities/trip_tracking_snapshot.dart';
import 'package:frota_mobile/features/shared/trip_tracking/domain/entities/trip_waiting_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('reconexão envia a fila offline em lote e a limpa', () async {
    SharedPreferences.setMockInitialValues({});
    final socket = _FakeSocket();
    final remote = _FakeRemote();
    final buffer = TripPositionBuffer(await SharedPreferences.getInstance());
    final repository = TripTrackingRepositoryImpl(
      remoteDatasource: remote,
      socketDatasource: socket,
      positionBuffer: buffer,
    );
    final position = TrackedPosition(
      lat: -23.3,
      lng: -51.1,
      accuracy: 5,
      speed: 0,
      heading: 0,
      timestamp: DateTime.utc(2026, 8, 24),
    );

    await repository.publishVehiclePosition('123', position);
    expect(await buffer.read('123'), hasLength(1));

    socket.isConnected = true;
    await repository.flushOfflinePositions('123');
    expect(remote.sent, [position]);
    expect(await buffer.read('123'), isEmpty);
  });
}

class _FakeSocket implements TripTrackingSocketDatasource {
  bool isConnected = false;
  final eventController = StreamController<TripBridgeMessage>.broadcast();
  final connectionController = StreamController<bool>.broadcast();
  @override
  bool get connected => isConnected;
  @override
  Stream<bool> get connectionChanges => connectionController.stream;
  @override
  Stream<TripBridgeMessage> get events => eventController.stream;
  @override
  Future<void> connect(String tripId, TripRole role) async {
    isConnected = true;
  }

  @override
  Future<void> disconnect() async {
    isConnected = false;
  }

  @override
  void sendPassengerPosition(String tripId, TrackedPosition position) {}
  @override
  void sendVehiclePosition(String tripId, TrackedPosition position) {}
}

class _FakeRemote implements TripTrackingRemoteDatasource {
  final sent = <TrackedPosition>[];
  @override
  Future<void> sendPositions(
    String tripId,
    List<TrackedPosition> positions,
  ) async => sent.addAll(positions);
  @override
  Future<void> sendPassengerPosition(
    String tripId,
    TrackedPosition position,
  ) async {}
  @override
  Future<TripTrackingSnapshot> loadSnapshot(String tripId, TripRole role) =>
      throw UnimplementedError();
  @override
  Future<CanonicalRoute> requestReroute(
    String tripId,
    TrackedPosition position,
    String commandEventId,
  ) => throw UnimplementedError();
  @override
  Future<TripWaitingState> confirmWaiting(
    String tripId,
    String commandEventId,
  ) => throw UnimplementedError();
  @override
  Future<TripWaitingState> resumeWaiting(
    String tripId,
    String commandEventId,
  ) => throw UnimplementedError();
  @override
  Future<void> finishTrip(String tripId, String commandEventId) async {}
}
