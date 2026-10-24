import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frota_mobile/core/network/dio_exception_mapper.dart';

DioException _erro({int? status, dynamic data}) => DioException(
  requestOptions: RequestOptions(path: '/teste'),
  response: status == null
      ? null
      : Response<dynamic>(
          requestOptions: RequestOptions(path: '/teste'),
          statusCode: status,
          data: data,
        ),
  type: DioExceptionType.badResponse,
);

void main() {
  test('preserva message string e lista de mensagens', () {
    expect(
      mapDioException(
        _erro(status: 400, data: {'message': 'Campo inválido.'}),
      ).message,
      'Campo inválido.',
    );
    expect(
      mapDioException(
        _erro(
          status: 422,
          data: {
            'message': ['E-mail inválido.', 'Senha obrigatória.'],
          },
        ),
      ).message,
      'E-mail inválido.\nSenha obrigatória.',
    );
  });

  test('aceita mensagens em response e error sem expor nome técnico', () {
    expect(
      mapDioException(
        _erro(
          status: 400,
          data: {
            'response': {'message': 'Falha funcional.'},
          },
        ),
      ).message,
      'Falha funcional.',
    );
    expect(
      mapDioException(
        _erro(
          status: 404,
          data: {
            'error': {'message': 'Conta não encontrada.'},
          },
        ),
      ).message,
      'Conta não encontrada.',
    );
    expect(
      mapDioException(
        _erro(status: 404, data: {'error': 'Not Found', 'statusCode': 404}),
      ).message,
      'Não encontramos o recurso solicitado.',
    );
  });

  test('distingue 401 no login de 401 em sessão autenticada', () {
    expect(
      mapDioException(
        _erro(status: 401),
        context: DioExceptionContext.login,
      ).message,
      'E-mail ou senha inválidos.',
    );
    expect(
      mapDioException(_erro(status: 401)).message,
      'Sua sessão expirou. Entre novamente para continuar.',
    );
  });

  test('usa fallbacks amigáveis para 404, 409 e 422', () {
    expect(
      mapDioException(_erro(status: 404)).message,
      'Não encontramos o recurso solicitado.',
    );
    expect(
      mapDioException(_erro(status: 409)).message,
      'Não foi possível concluir porque o registro mudou. Tente novamente.',
    );
    expect(
      mapDioException(_erro(status: 422)).message,
      'Alguns dados enviados não são válidos. Revise e tente de novo.',
    );
  });
}
