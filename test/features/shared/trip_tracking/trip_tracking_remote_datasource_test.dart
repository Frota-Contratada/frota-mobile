import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frota_mobile/features/shared/trip_tracking/data/datasources/trip_tracking_remote_datasource.dart';
import 'package:frota_mobile/features/shared/trip_tracking/domain/entities/tracked_position.dart';

void main() {
  test('encaminha eventId como Idempotency-Key em todos os comandos', () async {
    final requests = <RequestOptions>[];
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          requests.add(options);
          final Object? data;
          if (options.path.endsWith('/route/reroute')) {
            data = _routeJson();
          } else if (options.path.contains('/waiting/')) {
            data = {'active': options.path.endsWith('/start')};
          } else {
            data = null;
          }
          handler.resolve(Response(requestOptions: options, data: data));
        },
      ),
    );
    final datasource = TripTrackingRemoteDatasourceImpl(
      dio: dio,
      baseUrl: 'https://api.example/corridas',
    );
    final position = TrackedPosition(
      lat: -23.3,
      lng: -51.1,
      accuracy: 5,
      speed: 10,
      heading: 90,
      timestamp: DateTime.utc(2026, 8, 24),
    );

    await datasource.requestReroute('123', position, 'event-reroute');
    await datasource.confirmWaiting('123', 'event-wait');
    await datasource.resumeWaiting('123', 'event-resume');
    await datasource.finishTrip('123', 'event-finish');

    expect(requests.map((request) => request.headers['Idempotency-Key']), [
      'event-reroute',
      'event-wait',
      'event-resume',
      'event-finish',
    ]);
  });
}

Map<String, dynamic> _routeJson() => {
  'routeId': 'route-2',
  'version': 2,
  'calculatedAt': DateTime.utc(2026, 8, 24).toIso8601String(),
  'origin': {
    'id': 'origin',
    'sequence': 0,
    'kind': 'origin',
    'label': 'Origem',
    'lat': -23.3,
    'lng': -51.1,
  },
  'stops': <Object>[],
  'destination': {
    'id': 'destination',
    'sequence': 1,
    'kind': 'destination',
    'label': 'Destino',
    'lat': -23.4,
    'lng': -51.2,
  },
  'coordinates': [
    {'lat': -23.3, 'lng': -51.1},
    {'lat': -23.4, 'lng': -51.2},
  ],
  'distanceMeters': 1000,
  'durationSeconds': 100,
  'trafficSections': <Object>[],
  'instructions': <Object>[],
};
