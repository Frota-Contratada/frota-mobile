import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'map_point.dart';
import 'map_route.dart';

abstract class RoutingService {
  Future<MapRoute?> buscarRota(List<MapPoint> pontos);
}

class BackendRoutingService implements RoutingService {
  final Dio _dio;
  final String _url;
  final Map<String, MapRoute> _cache = {};

  static const _limiteCache = 30;

  BackendRoutingService({required Dio dio, required String url})
    : _dio = dio,
      _url = url;

  @override
  Future<MapRoute?> buscarRota(List<MapPoint> pontos) async {
    if (pontos.length < 2) return null;

    final chave = _chaveDe(pontos);
    final emCache = _cache[chave];

    if (emCache != null) return emCache;

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        _url,
        data: {
          'pontos': [
            for (final ponto in pontos)
              {'latitude': ponto.latitude, 'longitude': ponto.longitude},
          ],
        },
      );

      final rota = _paraRota(response.data?['response']);

      if (rota != null) _guardarEmCache(chave, rota);

      return rota;
    } catch (_) {
      debugPrint('Falha ao calcular a rota.');
      return null;
    }
  }

  MapRoute? _paraRota(dynamic corpo) {
    if (corpo is! Map) return null;

    final coordenadas = corpo['coordenadas'];
    if (coordenadas is! List) return null;

    final pontos = <MapPoint>[
      for (final coordenada in coordenadas)
        if (coordenada is Map &&
            coordenada['latitude'] is num &&
            coordenada['longitude'] is num)
          MapPoint(
            (coordenada['latitude'] as num).toDouble(),
            (coordenada['longitude'] as num).toDouble(),
          ),
    ];

    if (pontos.length < 2) return null;

    final distancia = corpo['distanciaKm'];
    final minutos = corpo['duracaoMinutos'];

    return MapRoute(
      points: pontos,
      distanceKm: distancia is num ? distancia.toDouble() : 0,
      duration: Duration(minutes: minutos is num ? minutos.round() : 0),
    );
  }

  void _guardarEmCache(String chave, MapRoute rota) {
    if (_cache.length >= _limiteCache) {
      _cache.remove(_cache.keys.first);
    }

    _cache[chave] = rota;
  }

  String _chaveDe(List<MapPoint> pontos) =>
      pontos.map((ponto) => '${ponto.latitude},${ponto.longitude}').join(';');
}

class _RoteirizacaoIndisponivel implements RoutingService {
  const _RoteirizacaoIndisponivel();

  @override
  Future<MapRoute?> buscarRota(List<MapPoint> pontos) async => null;
}

RoutingService _servicoPadrao = const _RoteirizacaoIndisponivel();

RoutingService get mapRoutingService => _servicoPadrao;

set mapRoutingService(RoutingService service) => _servicoPadrao = service;
