class Env {
  static const String baseUrl =
      String.fromEnvironment('BASE_URL', defaultValue: 'https://api.frota.jbs.com.br');

  static const String apiVersion = '/api/v1';

  static String get authBaseUrl => '$baseUrl$apiVersion/auth';
}