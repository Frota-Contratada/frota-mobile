import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frota_mobile/core/maps/endereco_autocomplete_service.dart';
import 'package:frota_mobile/core/maps/map_point.dart';
import 'package:frota_mobile/core/maps/routing_service.dart';

class _RespostaFixa implements HttpClientAdapter {
  final int status;
  final Map<String, dynamic> corpo;
  RequestOptions? ultimaRequisicao;

  _RespostaFixa(this.status, this.corpo);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    ultimaRequisicao = options;
    return ResponseBody.fromString(
      jsonEncode(corpo),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Dio _dio(_RespostaFixa adapter) => Dio()..httpClientAdapter = adapter;

void main() {
  group('BackendRoutingService', () {
    const pontos = [MapPoint(-23.30, -51.16), MapPoint(-23.33, -51.14)];

    test('converte o traçado e a duração da API', () async {
      final adapter = _RespostaFixa(200, {
        'response': {
          'distanciaKm': 6.48,
          'duracaoMinutos': 16,
          'coordenadas': [
            {'latitude': -23.30, 'longitude': -51.16},
            {'latitude': -23.31, 'longitude': -51.15},
            {'latitude': -23.33, 'longitude': -51.14},
          ],
        },
      });

      final rota = await BackendRoutingService(
        dio: _dio(adapter),
        url: 'http://api.teste/solicitacoes/rota',
      ).buscarRota(pontos);

      expect(rota?.points, hasLength(3));
      expect(rota?.distanceKm, 6.48);
      expect(rota?.duration, const Duration(minutes: 16));
      expect(adapter.ultimaRequisicao?.data, {
        'pontos': [
          {'latitude': -23.30, 'longitude': -51.16},
          {'latitude': -23.33, 'longitude': -51.14},
        ],
      });
    });

    test('retorna nulo quando a API não traz traçado', () async {
      final rota = await BackendRoutingService(
        dio: _dio(
          _RespostaFixa(200, {
            'response': {
              'distanciaKm': 6.48,
              'duracaoMinutos': 16,
              'coordenadas': <dynamic>[],
            },
          }),
        ),
        url: 'http://api.teste/solicitacoes/rota',
      ).buscarRota(pontos);

      expect(rota, isNull);
    });
  });

  group('BackendEnderecoAutocompleteService', () {
    test('converte as sugestões da API', () async {
      final adapter = _RespostaFixa(200, {
        'response': [
          {
            'descricao': 'Avenida Higienópolis, 100, Centro, Londrina, PR',
            'latitude': -23.31,
            'longitude': -51.16,
            'logradouro': 'Avenida Higienópolis',
            'numero': '100',
            'bairro': 'Centro',
            'cidade': 'Londrina',
            'uf': 'PR',
          },
        ],
      });

      final sugestoes = await BackendEnderecoAutocompleteService(
        dio: _dio(adapter),
        url: 'http://api.teste/solicitacoes/enderecos/sugestoes',
      ).buscarSugestoes('Higienópolis');

      expect(sugestoes, hasLength(1));
      expect(sugestoes.single.titulo, 'Avenida Higienópolis, 100');
      expect(sugestoes.single.subtitulo, 'Centro, Londrina, PR');
      expect(sugestoes.single.ponto, const MapPoint(-23.31, -51.16));
      expect(adapter.ultimaRequisicao?.queryParameters, {
        'busca': 'Higienópolis',
      });
    });

    test('não consulta a API com menos de 3 caracteres', () async {
      final adapter = _RespostaFixa(200, {'response': <dynamic>[]});

      final sugestoes = await BackendEnderecoAutocompleteService(
        dio: _dio(adapter),
        url: 'http://api.teste/solicitacoes/enderecos/sugestoes',
      ).buscarSugestoes('Av');

      expect(sugestoes, isEmpty);
      expect(adapter.ultimaRequisicao, isNull);
    });

    test('sinaliza indisponibilidade quando a API falha', () async {
      final servico = BackendEnderecoAutocompleteService(
        dio: _dio(_RespostaFixa(500, {'message': 'erro'})),
        url: 'http://api.teste/solicitacoes/enderecos/sugestoes',
      );

      await expectLater(
        servico.buscarSugestoes('Higienópolis'),
        throwsA(isA<BuscaEnderecoIndisponivelException>()),
      );
    });
  });
}
