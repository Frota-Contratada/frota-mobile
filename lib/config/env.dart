import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get baseUrl =>
      dotenv.env['BASE_URL'] ?? 'http://localhost:3000';

  static String get authBaseUrl => '$baseUrl/autenticacao';

  static String get usuarioBaseUrl => '$baseUrl/usuario';

  static String get usuarioInfoBaseUrl => '$usuarioBaseUrl/info';

  static String get motoristaViagensBaseUrl => '$baseUrl/motorista/viagens';

  static String get motoristaCorridasBaseUrl => '$baseUrl/motorista/corridas';

  static String get solicitacoesBaseUrl => '$baseUrl/solicitacoes';

  /// Agenda de viagens aprovadas do passageiro.
  static String get viagensBaseUrl => '$solicitacoesBaseUrl/viagens';

  static String get centrosCustoBaseUrl => '$baseUrl/centro-de-custo';

  /// Servidor de roteirização usado para traçar o caminho mais rápido.
  ///
  /// Em produção deve apontar para o OSRM interno. O padrão é o servidor
  /// público de demonstração, que só recebe coordenadas e serve para o app
  /// funcionar em ambiente de desenvolvimento.
  static String get osrmBaseUrl =>
      dotenv.env['OSRM_BASE_URL'] ?? 'https://router.project-osrm.org';
}
