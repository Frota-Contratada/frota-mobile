import 'package:flutter_test/flutter_test.dart';
import 'package:frota_mobile/features/shared/trip_tracking/domain/entities/canonical_route.dart';
import 'package:frota_mobile/features/shared/trip_tracking/domain/entities/navigation_instruction.dart';
import 'package:frota_mobile/features/shared/trip_tracking/domain/entities/route_waypoint.dart';
import 'package:frota_mobile/features/shared/trip_tracking/domain/entities/tracked_position.dart';
import 'package:frota_mobile/features/shared/trip_tracking/presentation/services/passenger_distance_guard.dart';

void main() {
  test('descarta conceitualmente posição fora de ordem', () {
    final current = _position(DateTime.utc(2026, 8, 24, 15, 31));
    final delayed = _position(DateTime.utc(2026, 8, 24, 15, 30));
    expect(delayed.isNewerThan(current), isFalse);
    expect(current.isNewerThan(delayed), isTrue);
  });

  test('aceita somente versão de rota maior', () {
    final current = _route(2);
    expect(_route(1).isNewerThan(current), isFalse);
    expect(_route(2).isNewerThan(current), isFalse);
    expect(_route(3).isNewerThan(current), isTrue);
  });

  test('rota canônica serializa instruções de navegação', () {
    final route = CanonicalRoute(
      routeId: _route(1).routeId,
      version: 1,
      calculatedAt: _route(1).calculatedAt,
      origin: _route(1).origin,
      stops: const [],
      destination: _route(1).destination,
      coordinates: _route(1).coordinates,
      distanceMeters: 1000,
      durationSeconds: 100,
      instructions: const [
        NavigationInstruction(
          id: 'instruction-1',
          instruction: 'Vire à direita na Avenida Brasil',
          streetName: 'Avenida Brasil',
          distanceMeters: 350,
          durationSeconds: 40,
          type: 'turn',
          modifier: 'right',
          icon: 'corner-up-right',
          location: NavigationInstructionLocation(lat: -23.31, lng: -51.18),
          coordinateIndex: 1,
        ),
      ],
    );

    final decoded = CanonicalRoute.fromJson(route.toJson());
    expect(decoded.instructions, route.instructions);
    expect(decoded.instructions.single.coordinateIndex, 1);
  });

  test('alerta passageiro somente após leituras consecutivas', () {
    final guard = PassengerDistanceGuard(
      thresholdMeters: 100,
      requiredConsecutiveReadings: 3,
    );
    final vehicle = _position(DateTime.now().toUtc());
    final passenger = TrackedPosition(
      lat: vehicle.lat + 0.003,
      lng: vehicle.lng,
      accuracy: 5,
      speed: 0,
      heading: 0,
      timestamp: DateTime.now().toUtc(),
    );
    expect(guard.register(passenger: passenger, vehicle: vehicle), isFalse);
    expect(guard.register(passenger: passenger, vehicle: vehicle), isFalse);
    expect(guard.register(passenger: passenger, vehicle: vehicle), isTrue);
    guard.reset();
    expect(guard.register(passenger: passenger, vehicle: vehicle), isFalse);
  });
}

TrackedPosition _position(DateTime time) => TrackedPosition(
  lat: -23.3045,
  lng: -51.1696,
  accuracy: 5,
  speed: 10,
  heading: 90,
  timestamp: time,
);

CanonicalRoute _route(int version) {
  final time = DateTime.utc(2026, 8, 24);
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
    routeId: 'route-v$version',
    version: version,
    calculatedAt: time,
    origin: origin,
    stops: const [],
    destination: destination,
    coordinates: [_position(time), _position(time)],
    distanceMeters: 1000,
    durationSeconds: 100,
  );
}
