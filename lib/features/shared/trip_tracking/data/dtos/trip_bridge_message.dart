import 'dart:convert';
import 'dart:math';

class TripMessageType {
  static const bootstrap = 'trip.bootstrap';
  static const vehicleLocation = 'vehicle.location';
  static const passengerLocation = 'passenger.location';
  static const routeReplaced = 'route.replaced';
  static const statusChanged = 'trip.statusChanged';
  static const waitingChanged = 'waiting.changed';
  static const connectionChanged = 'connection.changed';
  static const commandSucceeded = 'command.succeeded';
  static const commandFailed = 'command.failed';

  static const webReady = 'web.ready';
  static const rerouteRequested = 'route.rerouteRequested';
  static const waitingConfirmed = 'waiting.confirmed';
  static const waitingResumeRequested = 'waiting.resumeRequested';
  static const finishRequested = 'trip.finishRequested';
  static const externalNavigationRequested = 'external.navigationRequested';
  static const webLog = 'web.log';

  static const fromFlutter = {
    bootstrap,
    vehicleLocation,
    passengerLocation,
    routeReplaced,
    statusChanged,
    waitingChanged,
    connectionChanged,
    commandSucceeded,
    commandFailed,
  };

  static const fromWeb = {
    webReady,
    rerouteRequested,
    waitingConfirmed,
    waitingResumeRequested,
    finishRequested,
    externalNavigationRequested,
    webLog,
  };
}

class TripBridgeMessage {
  static const currentSchemaVersion = 1;

  final int schemaVersion;
  final String type;
  final String eventId;
  final String tripId;
  final DateTime sentAt;
  final Map<String, dynamic> payload;

  const TripBridgeMessage({
    required this.schemaVersion,
    required this.type,
    required this.eventId,
    required this.tripId,
    required this.sentAt,
    required this.payload,
  });

  factory TripBridgeMessage.create({
    required String type,
    required String tripId,
    Map<String, dynamic> payload = const {},
  }) => TripBridgeMessage(
    schemaVersion: currentSchemaVersion,
    type: type,
    eventId: _uuidV4(),
    tripId: tripId,
    sentAt: DateTime.now().toUtc(),
    payload: payload,
  );

  factory TripBridgeMessage.fromJson(
    Map<String, dynamic> json, {
    required String expectedTripId,
    Set<String>? allowedTypes,
  }) {
    final schemaVersion = json['schemaVersion'];
    if (schemaVersion != currentSchemaVersion) {
      throw const FormatException('Versão do protocolo não suportada.');
    }

    final type = json['type'];
    if (type is! String ||
        type.isEmpty ||
        (allowedTypes != null && !allowedTypes.contains(type))) {
      throw const FormatException('Tipo de mensagem inválido.');
    }

    final tripId = json['tripId'];
    if (tripId is! String || tripId.isEmpty || tripId != expectedTripId) {
      throw const FormatException('Identificador da corrida inválido.');
    }

    final eventId = json['eventId'];
    if (eventId is! String || eventId.isEmpty) {
      throw const FormatException('Identificador do evento inválido.');
    }

    final sentAtRaw = json['sentAt'];
    final sentAt = sentAtRaw is String ? DateTime.tryParse(sentAtRaw) : null;
    if (sentAt == null) {
      throw const FormatException('Timestamp do evento inválido.');
    }

    final payload = json['payload'];
    if (payload is! Map<String, dynamic>) {
      throw const FormatException('Payload inválido.');
    }
    _validatePayload(type, payload);

    return TripBridgeMessage(
      schemaVersion: schemaVersion as int,
      type: type,
      eventId: eventId,
      tripId: tripId,
      sentAt: sentAt.toUtc(),
      payload: payload,
    );
  }

  factory TripBridgeMessage.decode(
    String raw, {
    required String expectedTripId,
    Set<String>? allowedTypes,
  }) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Envelope inválido.');
    }
    return TripBridgeMessage.fromJson(
      decoded,
      expectedTripId: expectedTripId,
      allowedTypes: allowedTypes,
    );
  }

  Map<String, dynamic> toJson() => {
    'schemaVersion': schemaVersion,
    'type': type,
    'eventId': eventId,
    'tripId': tripId,
    'sentAt': sentAt.toUtc().toIso8601String(),
    'payload': payload,
  };

  String encode() => jsonEncode(toJson());
}

void _validatePayload(String type, Map<String, dynamic> payload) {
  bool hasNumber(String key) => payload[key] is num;

  if (type == TripMessageType.vehicleLocation ||
      type == TripMessageType.passengerLocation) {
    final lat = payload['lat'];
    final lng = payload['lng'];
    final timestamp = payload['timestamp'] is String
        ? DateTime.tryParse(payload['timestamp'] as String)
        : null;
    if (!hasNumber('lat') ||
        !hasNumber('lng') ||
        (lat as num).toDouble() < -90 ||
        lat.toDouble() > 90 ||
        (lng as num).toDouble() < -180 ||
        lng.toDouble() > 180 ||
        payload['timestamp'] is! String ||
        timestamp == null ||
        !timestamp.isUtc) {
      throw const FormatException('Payload de localização inválido.');
    }
  }

  if (type == TripMessageType.routeReplaced &&
      (payload['routeId'] is! String ||
          payload['version'] is! num ||
          (payload['version'] as num) < 1 ||
          payload['calculatedAt'] is! String ||
          payload['origin'] is! Map ||
          payload['stops'] is! List ||
          payload['destination'] is! Map ||
          payload['coordinates'] is! List ||
          payload['instructions'] is! List)) {
    throw const FormatException('Payload de rota inválido.');
  }

  if (type == TripMessageType.bootstrap &&
      (payload['role'] is! String ||
          payload['tripStatus'] is! String ||
          payload['waiting'] is! Map ||
          payload['route'] is! Map ||
          (payload['route'] as Map)['instructions'] is! List)) {
    throw const FormatException('Payload de bootstrap inválido.');
  }

  if (type == TripMessageType.webLog && payload['message'] is! String) {
    throw const FormatException('Payload de log inválido.');
  }

  if (type == TripMessageType.externalNavigationRequested) {
    final provider = payload['provider'];
    final destination = payload['destination'];
    final origin = payload['origin'];
    final destinationIsValid =
        destination is Map &&
        destination['lat'] is num &&
        destination['lng'] is num &&
        (destination['lat'] as num) >= -90 &&
        (destination['lat'] as num) <= 90 &&
        (destination['lng'] as num) >= -180 &&
        (destination['lng'] as num) <= 180;
    final originIsValid =
        origin == null ||
        (origin is Map &&
            origin['lat'] is num &&
            origin['lng'] is num &&
            (origin['lat'] as num) >= -90 &&
            (origin['lat'] as num) <= 90 &&
            (origin['lng'] as num) >= -180 &&
            (origin['lng'] as num) <= 180);
    if ((provider != 'google_maps' && provider != 'waze') ||
        !destinationIsValid ||
        !originIsValid) {
      throw const FormatException('Payload de navegação externa inválido.');
    }
  }

  if (type == TripMessageType.statusChanged &&
      payload['tripStatus'] is! String) {
    throw const FormatException('Payload de status inválido.');
  }

  if (type == TripMessageType.waitingChanged &&
      (payload['active'] is! bool ||
          (payload['startedAt'] != null && payload['startedAt'] is! String))) {
    throw const FormatException('Payload de espera inválido.');
  }

  if (type == TripMessageType.connectionChanged &&
      payload['connected'] is! bool) {
    throw const FormatException('Payload de conexão inválido.');
  }

  if (type == TripMessageType.commandSucceeded &&
      (payload['commandEventId'] is! String ||
          payload['commandType'] is! String)) {
    throw const FormatException('Payload de comando inválido.');
  }

  if (type == TripMessageType.commandFailed &&
      (payload['commandEventId'] is! String ||
          payload['commandType'] is! String ||
          payload['reason'] is! String)) {
    throw const FormatException('Payload de falha inválido.');
  }
}

String _uuidV4() {
  final random = Random.secure();
  final bytes = List<int>.generate(16, (_) => random.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;
  final hex = bytes
      .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
      .join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
      '${hex.substring(12, 16)}-${hex.substring(16, 20)}-'
      '${hex.substring(20)}';
}
