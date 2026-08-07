import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get baseUrl =>
      dotenv.env['BASE_URL'] ?? 'http://localhost:3000';

  static String get authBaseUrl => '$baseUrl/autenticacao';

  static String get usuarioBaseUrl => '$baseUrl/usuario';

  static String get motoristaViagensBaseUrl => '$baseUrl/motorista/viagens';

  static String get motoristaCorridasBaseUrl => '$baseUrl/motorista/corridas';
}
