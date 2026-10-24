import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frota_mobile/core/error/exceptions.dart';
import 'package:frota_mobile/features/auth/data/datasources/auth_remote_datasource.dart';

class _RespostaFixa implements HttpClientAdapter {
  final int status;
  final Map<String, dynamic> corpo;

  _RespostaFixa(this.status, this.corpo);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
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

AuthRemoteDatasourceImpl _datasource(int status, Map<String, dynamic> corpo) {
  final dio = Dio(BaseOptions(baseUrl: 'http://api.teste'))
    ..httpClientAdapter = _RespostaFixa(status, corpo);

  return AuthRemoteDatasourceImpl(
    dio: dio,
    authBaseUrl: 'http://api.teste/autenticacao',
    usuarioInfoBaseUrl: 'http://api.teste/usuario',
  );
}

void main() {
  test(
    'e-mail sem conta exibe a mensagem da API em vez do primeiro acesso',
    () async {
      final datasource = _datasource(404, {
        'message': 'Não encontramos uma conta com este e-mail.',
        'error': 'Not Found',
        'statusCode': 404,
      });

      await expectLater(
        datasource.verificarEmail('naoexiste@empresa.com'),
        throwsA(
          isA<ServerException>().having(
            (erro) => erro.message,
            'message',
            'Não encontramos uma conta com este e-mail.',
          ),
        ),
      );
    },
  );

  test('usuário sem senha segue para o primeiro acesso', () async {
    final datasource = _datasource(200, {
      'response': {'primeiroAcesso': true},
    });

    final resultado = await datasource.verificarEmail('novo@empresa.com');

    expect(resultado.precisaCadastroSenha, isTrue);
  });

  test('usuário com senha segue para a tela de senha', () async {
    final datasource = _datasource(200, {
      'response': {'primeiroAcesso': false},
    });

    final resultado = await datasource.verificarEmail('antigo@empresa.com');

    expect(resultado.precisaCadastroSenha, isFalse);
  });

  test(
    '404 sem message usa o fallback amigável e não expõe Not Found',
    () async {
      final datasource = _datasource(404, {
        'error': 'Not Found',
        'statusCode': 404,
      });

      await expectLater(
        datasource.verificarEmail('naoexiste@empresa.com'),
        throwsA(
          isA<ServerException>().having(
            (erro) => erro.message,
            'message',
            'Não encontramos o recurso solicitado.',
          ),
        ),
      );
    },
  );

  test(
    'payload de verificação malformado vira ServerException amigável',
    () async {
      final datasource = _datasource(200, {'response': 'não é um objeto'});

      await expectLater(
        datasource.verificarEmail('malformado@empresa.com'),
        throwsA(
          isA<ServerException>().having(
            (erro) => erro.message,
            'message',
            'Resposta inválida do servidor.',
          ),
        ),
      );
    },
  );

  // A resposta 200 com primeiroAcesso:false não distingue e-mail inexistente;
  // essa distinção depende do backend retornar HTTP 404.
}
