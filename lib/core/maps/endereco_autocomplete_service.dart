import 'package:dio/dio.dart';

import 'endereco_sugestao.dart';
import 'map_point.dart';

class BuscaEnderecoIndisponivelException implements Exception {
  const BuscaEnderecoIndisponivelException();
}

abstract class EnderecoAutocompleteService {
  Future<List<EnderecoSugestao>> buscarSugestoes(
    String busca, {
    MapPoint? proximoDe,
  });
}

class BackendEnderecoAutocompleteService
    implements EnderecoAutocompleteService {
  static const tamanhoMinimoBusca = 3;

  final Dio _dio;
  final String _url;

  BackendEnderecoAutocompleteService({required Dio dio, required String url})
    : _dio = dio,
      _url = url;

  @override
  Future<List<EnderecoSugestao>> buscarSugestoes(
    String busca, {
    MapPoint? proximoDe,
  }) async {
    final texto = busca.trim();
    if (texto.length < tamanhoMinimoBusca) return const [];

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        _url,
        queryParameters: {
          'busca': texto,
          if (proximoDe != null) 'latitude': proximoDe.latitude,
          if (proximoDe != null) 'longitude': proximoDe.longitude,
        },
      );

      final lista = response.data?['response'];
      if (lista is! List) return const [];

      return [
        for (final item in lista)
          if (item is Map<String, dynamic> &&
              item['latitude'] is num &&
              item['longitude'] is num)
            EnderecoSugestao.fromJson(item),
      ].where((sugestao) => sugestao.descricao.isNotEmpty).toList();
    } on DioException {
      throw const BuscaEnderecoIndisponivelException();
    }
  }
}

class _BuscaEnderecoDesativada implements EnderecoAutocompleteService {
  const _BuscaEnderecoDesativada();

  @override
  Future<List<EnderecoSugestao>> buscarSugestoes(
    String busca, {
    MapPoint? proximoDe,
  }) async => const [];
}

EnderecoAutocompleteService _servicoPadrao = const _BuscaEnderecoDesativada();

EnderecoAutocompleteService get enderecoAutocompleteService => _servicoPadrao;

set enderecoAutocompleteService(EnderecoAutocompleteService service) =>
    _servicoPadrao = service;
