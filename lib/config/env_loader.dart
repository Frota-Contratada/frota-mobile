import 'package:flutter_dotenv/flutter_dotenv.dart';

const _fallbackEnv = '''
BASE_URL=http://localhost:3000
OSRM_BASE_URL=https://router.project-osrm.org
TRIP_WEBAPP_URL=http://10.0.2.2:5173
TRIP_SOCKET_URL=http://10.0.2.2:3000
TRIP_TRACKING_BASE_URL=http://10.0.2.2:3000/corridas
TRIP_TRACKING_MOCK=true
PASSENGER_DISTANCE_ALERT_METERS=100
PASSENGER_DISTANCE_ALERT_READINGS=3
''';

Future<void> loadEnvironment() async {
  try {
    await dotenv.load(fileName: '.env.example');
  } on Object {
    dotenv.loadFromString(envString: _fallbackEnv);
  }
}
