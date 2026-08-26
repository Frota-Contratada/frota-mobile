import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

class Env {
  static const _definedBaseUrl = String.fromEnvironment('BASE_URL');
  static const _definedOsrmBaseUrl = String.fromEnvironment('OSRM_BASE_URL');
  static const _definedTripWebAppUrl = String.fromEnvironment(
    'TRIP_WEBAPP_URL',
  );
  static const _definedTripSocketUrl = String.fromEnvironment(
    'TRIP_SOCKET_URL',
  );
  static const _definedTripTrackingBaseUrl = String.fromEnvironment(
    'TRIP_TRACKING_BASE_URL',
  );

  static String get baseUrl => _definedBaseUrl.isNotEmpty
      ? _definedBaseUrl
      : dotenv.env['BASE_URL'] ?? 'http://localhost:3000';

  static String get authBaseUrl => '$baseUrl/autenticacao';

  static String get usuarioBaseUrl => '$baseUrl/usuario';

  static String get usuarioInfoBaseUrl => '$usuarioBaseUrl/info';

  static String get motoristaViagensBaseUrl => '$baseUrl/motorista/viagens';

  static String get motoristaCorridasBaseUrl => '$baseUrl/motorista/corridas';

  static String get motoristaPerfilBaseUrl => '$baseUrl/motorista/perfil';

  static String get solicitacoesBaseUrl => '$baseUrl/solicitacoes';

  static String get viagensBaseUrl => '$solicitacoesBaseUrl/viagens';

  static String get centrosCustoBaseUrl => '$baseUrl/centro-de-custo';

  /// Servidor de roteirização usado para traçar o caminho mais rápido.
  ///
  /// Em produção deve apontar para o OSRM interno. O padrão é o servidor
  /// público de demonstração, que só recebe coordenadas e serve para o app
  /// funcionar em ambiente de desenvolvimento.
  static String get osrmBaseUrl => _definedOsrmBaseUrl.isNotEmpty
      ? _definedOsrmBaseUrl
      : dotenv.env['OSRM_BASE_URL'] ?? 'https://router.project-osrm.org';

  static String get tripWebAppUrl => _definedTripWebAppUrl.isNotEmpty
      ? _definedTripWebAppUrl
      : dotenv.env['TRIP_WEBAPP_URL'] ?? 'http://10.0.2.2:5173';

  static String get tripSocketUrl => _definedTripSocketUrl.isNotEmpty
      ? _definedTripSocketUrl
      : dotenv.env['TRIP_SOCKET_URL'] ?? baseUrl;

  static String get tripTrackingBaseUrl =>
      _definedTripTrackingBaseUrl.isNotEmpty
      ? _definedTripTrackingBaseUrl
      : dotenv.env['TRIP_TRACKING_BASE_URL'] ?? '$baseUrl/corridas';

  static bool get tripTrackingMock {
    if (!kDebugMode) return false;
    final value = dotenv.env['TRIP_TRACKING_MOCK'] ?? 'true';
    return value.toLowerCase() == 'true';
  }

  static double get passengerDistanceAlertMeters =>
      double.tryParse(dotenv.env['PASSENGER_DISTANCE_ALERT_METERS'] ?? '') ??
      100;

  static int get passengerDistanceAlertReadings =>
      int.tryParse(dotenv.env['PASSENGER_DISTANCE_ALERT_READINGS'] ?? '') ?? 3;
}
