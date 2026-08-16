import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../config/env.dart';
import '../network/dio_factory.dart';
import 'map_point.dart';
import 'map_route.dart';

// Calcula o trajeto recomendado entre os pontos selecionados pelo usuário.
abstract class RoutingService {
  // Retorna `null` quando não é possível calcular o trajeto, para que a
  Future<MapRoute?> buscarRota(List<MapPoint> pontos);
}

// Implementação baseada em OSRM.

// O OSRM otimiza por tempo de deslocamento, então a primeira rota devolvida
// já é o caminho mais rápido entre os pontos, respeitando a ordem informada.
class OsrmRoutingService implements RoutingService {
  final Dio _dio;
  final String _baseUrl;

  // Evita recalcular o mesmo trajeto a cada reconstrução da tela.
  final Map<String, MapRoute> _cache = {};

  static const _limiteCache = 30;

  OsrmRoutingService({required Dio dio, required String baseUrl})
    : _dio = dio,
      _baseUrl = baseUrl;

  @override
  Future<MapRoute?> buscarRota(List<MapPoint> pontos) async {
    if (pontos.length < 2) return null;

    final chave = _chaveDe(pontos);
    final emCache = _cache[chave];

    if (emCache != null) return emCache;

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '${_baseUrl.replaceAll(RegExp(r'/+$'), '')}/route/v1/driving/$chave',
        queryParameters: const {
          'overview': 'full',
          'geometries': 'geojson',
          'alternatives': 'false',
          'steps': 'false',
        },
      );

      final rota = _paraRota(response.data);

      if (rota != null) {
        _guardarEmCache(chave, rota);
      }

      return rota;
    } catch (error, stackTrace) {
      debugPrint('Erro ao calcular rota: $error');
      debugPrintStack(stackTrace: stackTrace);

      return null;
    }
  }

  MapRoute? _paraRota(Map<String, dynamic>? corpo) {
    if (corpo == null || corpo['code'] != 'Ok') return null;

    final rotas = corpo['routes'];

    if (rotas is! List || rotas.isEmpty) return null;

    final rota = rotas.first;

    if (rota is! Map) return null;

    final geometria = rota['geometry'];

    if (geometria is! Map) return null;

    final coordenadas = geometria['coordinates'];

    if (coordenadas is! List || coordenadas.length < 2) return null;

    final pontos = <MapPoint>[];

    for (final coordenada in coordenadas) {
      // O GeoJSON do OSRM usa a ordem [longitude, latitude].
      if (coordenada is List && coordenada.length >= 2) {
        final longitude = coordenada[0];
        final latitude = coordenada[1];

        if (longitude is num && latitude is num) {
          pontos.add(MapPoint(latitude.toDouble(), longitude.toDouble()));
        }
      }
    }

    if (pontos.length < 2) return null;

    final metros = rota['distance'];
    final segundos = rota['duration'];

    return MapRoute(
      points: pontos,
      distanceKm: metros is num ? metros.toDouble() / 1000 : 0,
      duration: Duration(seconds: segundos is num ? segundos.round() : 0),
    );
  }

  void _guardarEmCache(String chave, MapRoute rota) {
    if (_cache.length >= _limiteCache) {
      _cache.remove(_cache.keys.first);
    }

    _cache[chave] = rota;
  }

  String _chaveDe(List<MapPoint> pontos) =>
      pontos.map((ponto) => '${ponto.longitude},${ponto.latitude}').join(';');
}

RoutingService? _servicoPadrao;

// Serviço usado pelos widgets de mapa quando nenhum outro é informado.

// Usa um [Dio] próprio, sem o interceptor de autenticação: o servidor de
// roteirização não deve receber o token da API.
RoutingService get mapRoutingService => _servicoPadrao ??= OsrmRoutingService(
  dio: createDio(),
  baseUrl: Env.osrmBaseUrl,
);

@visibleForTesting
set mapRoutingService(RoutingService service) => _servicoPadrao = service;
