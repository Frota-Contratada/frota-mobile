import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:frota_mobile/features/shared/trip_tracking/data/dtos/trip_bridge_message.dart';
import 'package:frota_mobile/features/shared/trip_tracking/presentation/services/trip_web_bridge.dart';

void main() {
  const tripId = 'trip-123';

  test('serializa e desserializa envelope versionado', () {
    final message = TripBridgeMessage.create(
      type: TripMessageType.webReady,
      tripId: tripId,
    );
    final decoded = TripBridgeMessage.decode(
      message.encode(),
      expectedTripId: tripId,
      allowedTypes: TripMessageType.fromWeb,
    );
    expect(decoded.schemaVersion, 1);
    expect(decoded.type, TripMessageType.webReady);
    expect(decoded.tripId, tripId);
    expect(decoded.eventId, isNotEmpty);
    expect(decoded.sentAt.isUtc, isTrue);
  });

  test('rejeita versão, tipo e corrida inválidos', () {
    final base = TripBridgeMessage.create(
      type: TripMessageType.webReady,
      tripId: tripId,
    ).toJson();
    expect(
      () => TripBridgeMessage.fromJson({
        ...base,
        'schemaVersion': 2,
      }, expectedTripId: tripId),
      throwsFormatException,
    );
    expect(
      () => TripBridgeMessage.fromJson({
        ...base,
        'tripId': 'other',
      }, expectedTripId: tripId),
      throwsFormatException,
    );
    expect(
      () => TripBridgeMessage.fromJson(
        {...base, 'type': 'window.open'},
        expectedTripId: tripId,
        allowedTypes: TripMessageType.fromWeb,
      ),
      throwsFormatException,
    );
  });

  test('valida solicitação de navegação externa', () {
    final valid = TripBridgeMessage.create(
      type: TripMessageType.externalNavigationRequested,
      tripId: tripId,
      payload: const {
        'provider': 'google_maps',
        'origin': {'lat': -23.5, 'lng': -46.6},
        'destination': {'lat': -23.6, 'lng': -46.7},
      },
    ).toJson();
    expect(
      TripBridgeMessage.fromJson(
        valid,
        expectedTripId: tripId,
        allowedTypes: TripMessageType.fromWeb,
      ).type,
      TripMessageType.externalNavigationRequested,
    );
    expect(
      () => TripBridgeMessage.fromJson(
        {
          ...valid,
          'payload': {...valid['payload'] as Map, 'provider': 'browser'},
        },
        expectedTripId: tripId,
        allowedTypes: TripMessageType.fromWeb,
      ),
      throwsFormatException,
    );
  });

  test('ponte segura mensagens até web.ready e envia depois', () async {
    final scripts = <String>[];
    final bridge = TripWebBridge(
      tripId: tripId,
      runJavaScript: (script) async => scripts.add(script),
    );
    await bridge.send(
      TripBridgeMessage.create(
        type: TripMessageType.connectionChanged,
        tripId: tripId,
        payload: const {'connected': true},
      ),
    );
    expect(scripts, isEmpty);

    final ready = TripBridgeMessage.create(
      type: TripMessageType.webReady,
      tripId: tripId,
    );
    await bridge.handleJavaScriptMessage(jsonEncode(ready.toJson()));
    expect(scripts, hasLength(1));

    await bridge.send(
      TripBridgeMessage.create(
        type: TripMessageType.connectionChanged,
        tripId: tripId,
        payload: const {'connected': false},
      ),
    );
    expect(scripts, hasLength(2));
    await bridge.dispose();
  });
}
