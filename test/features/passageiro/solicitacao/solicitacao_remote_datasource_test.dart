import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frota_mobile/core/error/exceptions.dart';
import 'package:frota_mobile/core/maps/endereco_estruturado.dart';
import 'package:frota_mobile/features/passageiro/solicitacao/data/datasources/solicitacao_remote_datasource.dart';
import 'package:frota_mobile/features/passageiro/solicitacao/domain/entities/nova_solicitacao.dart';

class _RespostaFixa implements HttpClientAdapter {
  final Map<String, dynamic> corpo;

  _RespostaFixa(this.corpo);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => ResponseBody.fromString(
    jsonEncode(corpo),
    200,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );

  @override
  void close({bool force = false}) {}
}

NovaSolicitacao _solicitacao() => NovaSolicitacao(
  dataCorrida: DateTime.utc(2026, 8, 24, 15),
  tipoCorridaId: 1,
  motivoSolicitacaoId: 2,
  origem: const EnderecoEstruturado(
    logradouro: 'Origem',
    cidade: 'Londrina',
    uf: 'PR',
    latitude: -23.3,
    longitude: -51.1,
  ),
  destino: const EnderecoEstruturado(
    logradouro: 'Destino',
    cidade: 'Londrina',
    uf: 'PR',
    latitude: -23.4,
    longitude: -51.2,
  ),
  centrosCustoIds: const [1],
);

void main() {
  test('simulação rejeita números inválidos e fornecedor ausente', () async {
    final dio = Dio()
      ..httpClientAdapter = _RespostaFixa({
        'response': {
          'distanciaEstimadaKm': 'não-numérico',
          'duracaoEstimadaMinutos': 12,
          'valorEstimado': 20.5,
          'fornecedorId': null,
          'fornecedorNome': '',
        },
      });
    final datasource = SolicitacaoRemoteDatasourceImpl(
      dio: dio,
      solicitacoesBaseUrl: 'http://api.teste/solicitacoes',
      centrosCustoBaseUrl: 'http://api.teste/centros-custo',
    );

    await expectLater(
      datasource.simular(_solicitacao()),
      throwsA(
        isA<ServerException>().having(
          (erro) => erro.message,
          'message',
          'Resposta de estimativa inválida.',
        ),
      ),
    );
  });

  test('simulação sem response mantém mensagem amigável', () async {
    final dio = Dio()..httpClientAdapter = _RespostaFixa(<String, dynamic>{});
    final datasource = SolicitacaoRemoteDatasourceImpl(
      dio: dio,
      solicitacoesBaseUrl: 'http://api.teste/solicitacoes',
      centrosCustoBaseUrl: 'http://api.teste/centros-custo',
    );

    await expectLater(
      datasource.simular(_solicitacao()),
      throwsA(
        isA<ServerException>().having(
          (erro) => erro.message,
          'message',
          'Resposta do servidor sem conteúdo.',
        ),
      ),
    );
  });
}
