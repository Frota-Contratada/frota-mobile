import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get baseUrl =>
      dotenv.env['BASE_URL'] ?? 'http://localhost:8080';

  static String get authBaseUrl => '$baseUrl/autenticacao';

  static String get motoristaViagensBaseUrl => '$baseUrl/motorista/viagens';
}