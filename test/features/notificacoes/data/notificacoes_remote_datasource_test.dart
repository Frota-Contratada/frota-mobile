import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frota_mobile/core/error/exceptions.dart';
import 'package:frota_mobile/features/notificacoes/data/datasources/notificacoes_remote_datasource.dart';

void main() {
  test('usa os endpoints REST e os envelopes de notificações', () async {
    final requests = <RequestOptions>[];
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          requests.add(options);
          if (options.method == 'GET' &&
              options.path.endsWith('/nao-lidas/quantidade')) {
            handler.resolve(
              Response(
                requestOptions: options,
                data: {
                  'response': {'quantidade': 2},
                },
              ),
            );
            return;
          }
          if (options.method == 'PATCH') {
            handler.resolve(
              Response(
                requestOptions: options,
                data: {
                  'response': _notificationJson(lidaEm: '2026-09-02T11:00:00Z'),
                },
              ),
            );
            return;
          }
          handler.resolve(
            Response(
              requestOptions: options,
              data: {
                'response': [_notificationJson()],
              },
            ),
          );
        },
      ),
    );
    final datasource = NotificacoesRemoteDatasourceImpl(
      dio: dio,
      notificacoesBaseUrl: 'https://api.example/notificacoes',
    );

    final notificacoes = await datasource.buscarTodas();
    final quantidade = await datasource.contarNaoLidas();
    final lida = await datasource.marcarComoLida('notification-1');

    expect(notificacoes, hasLength(1));
    expect(quantidade, 2);
    expect(lida.lidaEm, isNotNull);
    expect(requests.map((request) => request.path), [
      'https://api.example/notificacoes',
      'https://api.example/notificacoes/nao-lidas/quantidade',
      'https://api.example/notificacoes/notification-1/lida',
    ]);
  });

  test('converte envelope de listagem inválido em ServerException', () async {
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.resolve(
            Response(requestOptions: options, data: {'response': null}),
          );
        },
      ),
    );
    final datasource = NotificacoesRemoteDatasourceImpl(
      dio: dio,
      notificacoesBaseUrl: 'https://api.example/notificacoes',
    );

    expect(() => datasource.buscarTodas(), throwsA(isA<ServerException>()));
  });

  test('converte item inválido da listagem em ServerException', () async {
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.resolve(
            Response(
              requestOptions: options,
              data: {
                'response': [null],
              },
            ),
          );
        },
      ),
    );
    final datasource = NotificacoesRemoteDatasourceImpl(
      dio: dio,
      notificacoesBaseUrl: 'https://api.example/notificacoes',
    );

    expect(() => datasource.buscarTodas(), throwsA(isA<ServerException>()));
  });

  test('converte contador inválido em ServerException', () async {
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.resolve(
            Response(requestOptions: options, data: {'response': {}}),
          );
        },
      ),
    );
    final datasource = NotificacoesRemoteDatasourceImpl(
      dio: dio,
      notificacoesBaseUrl: 'https://api.example/notificacoes',
    );

    expect(() => datasource.contarNaoLidas(), throwsA(isA<ServerException>()));
  });

  test('converte notificação inválida do PATCH em ServerException', () async {
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.resolve(
            Response(
              requestOptions: options,
              data: {
                'response': {..._notificationJson()..remove('id')},
              },
            ),
          );
        },
      ),
    );
    final datasource = NotificacoesRemoteDatasourceImpl(
      dio: dio,
      notificacoesBaseUrl: 'https://api.example/notificacoes',
    );

    expect(
      () => datasource.marcarComoLida('notification-1'),
      throwsA(isA<ServerException>()),
    );
  });
}

Map<String, dynamic> _notificationJson({String? lidaEm}) => {
  'id': 'notification-1',
  'tipo': 'LEMBRETE_VIAGEM',
  'titulo': 'Lembrete',
  'mensagem': 'Mensagem',
  'criadaEm': '2026-09-02T10:30:00Z',
  'expiraEm': '2026-10-02T10:30:00Z',
  'lidaEm': lidaEm,
};
