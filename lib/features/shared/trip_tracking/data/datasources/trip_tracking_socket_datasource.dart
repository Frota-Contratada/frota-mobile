import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../../../auth/data/datasources/auth_local_datasource.dart';
import '../../data/dtos/trip_bridge_message.dart';
import '../../domain/entities/tracked_position.dart';
import '../../domain/entities/trip_tracking_snapshot.dart';

abstract class TripTrackingSocketDatasource {
  Stream<TripBridgeMessage> get events;
  Stream<bool> get connectionChanges;
  bool get connected;

  Future<void> connect(String tripId, TripRole role);
  void sendVehiclePosition(String tripId, TrackedPosition position);
  void sendPassengerPosition(String tripId, TrackedPosition position);
  Future<void> disconnect();
}

class TripJoinHandshake {
  final String tripId;
  final _firstConfirmation = Completer<void>();
  bool _joined = false;

  TripJoinHandshake(this.tripId);

  bool get joined => _joined;
  Future<void> get firstConfirmation => _firstConfirmation.future;

  void reset() => _joined = false;

  bool confirmEvent(Object? data) {
    if (data is! Map || data['tripId'] != tripId) return false;
    return _confirm();
  }

  bool confirmAcknowledgement(Object? data) {
    if (data == false) return false;
    if (data is Map) {
      if (data['success'] == false ||
          data['joined'] == false ||
          data['error'] != null ||
          (data['tripId'] != null && data['tripId'] != tripId)) {
        return false;
      }
    }
    return _confirm();
  }

  bool _confirm() {
    if (_joined) return false;
    _joined = true;
    if (!_firstConfirmation.isCompleted) _firstConfirmation.complete();
    return true;
  }
}

class TripTrackingSocketDatasourceImpl implements TripTrackingSocketDatasource {
  final String socketUrl;
  final AuthLocalDatasource authLocalDatasource;
  final _events = StreamController<TripBridgeMessage>.broadcast();
  final _connections = StreamController<bool>.broadcast();
  io.Socket? _socket;
  String? _tripId;
  bool _joined = false;

  TripTrackingSocketDatasourceImpl({
    required this.socketUrl,
    required this.authLocalDatasource,
  });

  @override
  Stream<TripBridgeMessage> get events => _events.stream;

  @override
  Stream<bool> get connectionChanges => _connections.stream;

  @override
  bool get connected => (_socket?.connected ?? false) && _joined;

  @override
  Future<void> connect(String tripId, TripRole role) async {
    await disconnect();
    _tripId = tripId;
    final token = await authLocalDatasource.getAuthToken();
    final headers = <String, String>{};
    if (token != null && token.accessToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer ${token.accessToken}';
    }

    final socket = io.io(
      socketUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setExtraHeaders(headers)
          .enableForceNew()
          .disableAutoConnect()
          .enableReconnection()
          .setReconnectionDelay(1000)
          .setReconnectionDelayMax(15000)
          .build(),
    );
    _socket = socket;
    final handshake = TripJoinHandshake(tripId);

    void markDisconnected() {
      handshake.reset();
      _joined = false;
      _connections.add(false);
    }

    void markJoined() {
      _joined = true;
      _connections.add(true);
    }

    socket.onConnect((_) {
      handshake.reset();
      _joined = false;
      socket.emitWithAck(
        'trip.join',
        {'tripId': tripId, 'role': role.name},
        ack: (data) {
          if (handshake.confirmAcknowledgement(data)) markJoined();
        },
      );
    });
    socket.on('trip.joined', (data) {
      if (handshake.confirmEvent(data)) markJoined();
    });
    socket.onDisconnect((_) => markDisconnected());
    socket.onConnectError((_) => markDisconnected());
    socket.onError((_) => markDisconnected());
    socket.on('trip.event', _handleEvent);
    socket.connect();
    await handshake.firstConfirmation.timeout(const Duration(seconds: 3));
  }

  void _handleEvent(Object? data) {
    final tripId = _tripId;
    if (tripId == null || data is! Map) return;
    try {
      final message = TripBridgeMessage.fromJson(
        Map<String, dynamic>.from(data),
        expectedTripId: tripId,
        allowedTypes: TripMessageType.fromFlutter,
      );
      _events.add(message);
    } on FormatException {
      // Eventos externos inválidos são descartados sem registrar o conteúdo.
    }
  }

  @override
  void sendVehiclePosition(String tripId, TrackedPosition position) {
    if (!connected || tripId != _tripId) return;
    _socket?.emit('vehicle.location', {
      'tripId': tripId,
      'payload': position.toJson(),
    });
  }

  @override
  void sendPassengerPosition(String tripId, TrackedPosition position) {
    if (!connected || tripId != _tripId) return;
    _socket?.emit('passenger.location', {
      'tripId': tripId,
      'payload': position.toJson(),
    });
  }

  @override
  Future<void> disconnect() async {
    final socket = _socket;
    _socket = null;
    _tripId = null;
    _joined = false;
    if (socket == null) return;
    socket.clearListeners();
    socket.disconnect();
    socket.dispose();
    _connections.add(false);
  }
}

class NoopTripTrackingSocketDatasource implements TripTrackingSocketDatasource {
  final _events = StreamController<TripBridgeMessage>.broadcast();
  final _connections = StreamController<bool>.broadcast();
  bool _connected = false;

  @override
  bool get connected => _connected;
  @override
  Stream<TripBridgeMessage> get events => _events.stream;
  @override
  Stream<bool> get connectionChanges => _connections.stream;

  @override
  Future<void> connect(String tripId, TripRole role) async {
    _connected = true;
    _connections.add(true);
  }

  @override
  Future<void> disconnect() async {
    _connected = false;
    _connections.add(false);
  }

  @override
  void sendPassengerPosition(String tripId, TrackedPosition position) {}
  @override
  void sendVehiclePosition(String tripId, TrackedPosition position) {}
}
