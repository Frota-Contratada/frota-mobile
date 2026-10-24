import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frota_mobile/features/passageiro/solicitacoes/data/datasources/solicitacoes_remote_datasource.dart';

class _RespostaFixa implements HttpClientAdapter {
  RequestOptions? ultimaRequisicao;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    ultimaRequisicao = options;
    return ResponseBody.fromString(
      jsonEncode({
        'response': {
          'data': <dynamic>[],
          'totalCount': 0,
          'hasNextPage': false,
        },
      }),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  test(
    'envia janela operacional e não inclui solicitações anteriores',
    () async {
      final adapter = _RespostaFixa();
      final datasource = SolicitacoesRemoteDatasourceImpl(
        dio: Dio()..httpClientAdapter = adapter,
        solicitacoesBaseUrl: 'http://api.teste/solicitacoes',
      );
      final inicio = DateTime(2026, 8, 24);
      final fim = DateTime(2026, 8, 30, 23, 59, 59, 999999);

      await datasource.buscarVarias(
        dataInicio: inicio,
        dataFim: fim,
        incluirAnteriores: false,
      );

      expect(adapter.ultimaRequisicao?.queryParameters, {
        'page': 1,
        'limit': 50,
        'dataInicio': inicio.toUtc().toIso8601String(),
        'dataFim': fim.toUtc().toIso8601String(),
        'incluirAnteriores': 'false',
      });
    },
  );
}
