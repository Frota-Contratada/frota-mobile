import 'package:flutter_dotenv/flutter_dotenv.dart';

const _fallbackEnv = '''
BASE_URL=http://localhost:3000
OSRM_BASE_URL=https://router.project-osrm.org
''';

Future<void> loadEnvironment() async {
  try {
    await dotenv.load(fileName: '.env');
  } on Object {
    dotenv.loadFromString(envString: _fallbackEnv);
  }
}
