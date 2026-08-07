import 'package:flutter_dotenv/flutter_dotenv.dart';

const _fallbackEnv = 'BASE_URL=http://localhost:3000';

Future<void> loadEnvironment() async {
  try {
    await dotenv.load(fileName: '.env');
  } on Object {
    dotenv.loadFromString(envString: _fallbackEnv);
  }
}
