import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:socket_io_client/src/manager.dart';
import 'package:frota_mobile/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:frota_mobile/features/auth/data/models/usuario_model.dart';
import 'package:frota_mobile/features/auth/data/services/auth_token_service.dart';
import 'package:frota_mobile/features/auth/domain/entities/auth_token.dart';
import 'package:frota_mobile/features/notificacoes/data/datasources/notificacoes_socket_datasource.dart';

void main() {
  test('publica somente eventos criados válidos', () async {
    final datasource = NotificacoesSocketDatasourceImpl(
      notificacoesBaseUrl: 'https://api.example/notificacoes',
      authLocalDatasource: _FakeAuthLocalDatasource(token: null),
    );
    final eventos = <String>[];
    final subscription = datasource.notificacoesCriadas.listen(
      (notificacao) => eventos.add(notificacao.id),
    );

    datasource.processarNotificacaoCriada({'schemaVersion': 2});
    datasource.processarNotificacaoCriada({
      'schemaVersion': 1,
      'notificacao': _notificationJson(),
    });
    datasource.processarNotificacaoRemovida({
      'schemaVersion': 1,
      'notificacaoId': 'notification-1',
    });
    await Future<void>.delayed(Duration.zero);

    expect(eventos, ['notification-1']);
    await subscription.cancel();
    await datasource.desconectar();
  });

  test('renova token expirado antes de criar o socket', () async {
    final auth = _FakeAuthLocalDatasource(token: _expiredAuthToken());
    final refreshDio = Dio();
    refreshDio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.resolve(
            Response(
              requestOptions: options,
              data: {
                'response': {
                  'accessToken': 'renewed-access',
                  'refreshToken': 'renewed-refresh',
                  'validade': '2099-10-02T10:30:00Z',
                },
              },
            ),
          );
        },
      ),
    );
    final tokenProvider = AuthTokenService(
      localDatasource: auth,
      authBaseUrl: 'https://api.example/auth',
      refreshDioFactory: () => refreshDio,
    );
    final headers = <Map<String, String>>[];
    final datasource = NotificacoesSocketDatasourceImpl(
      notificacoesBaseUrl: 'https://api.example/notificacoes',
      authLocalDatasource: auth,
      authTokenProvider: tokenProvider,
      socketFactory: (url, options) {
        headers.add(Map<String, String>.from(options['extraHeaders'] as Map));
        return _TestSocket();
      },
    );

    await datasource.conectar();

    expect(headers, [
      {'Authorization': 'Bearer renewed-access'},
    ]);
    expect(auth.token?.accessToken, 'renewed-access');
    await datasource.desconectar();
  });

  test('busca token atualizado antes de recriar o socket', () async {
    final auth = _FakeAuthLocalDatasource(token: _authToken('first'));
    final tokenProvider = _FakeAuthTokenProvider(auth);
    final headers = <Map<String, String>>[];
    final sockets = <_TestSocket>[];
    final datasource = NotificacoesSocketDatasourceImpl(
      notificacoesBaseUrl: 'https://api.example/notificacoes',
      authLocalDatasource: auth,
      authTokenProvider: tokenProvider,
      socketFactory: (url, options) {
        headers.add(Map<String, String>.from(options['extraHeaders'] as Map));
        final socket = _TestSocket();
        sockets.add(socket);
        return socket;
      },
    );

    await datasource.conectar();
    auth.token = _authToken('second');
    sockets.first.emitReserved('disconnect');
    await Future<void>.delayed(const Duration(milliseconds: 1100));

    expect(headers, [
      {'Authorization': 'Bearer first'},
      {'Authorization': 'Bearer second'},
    ]);
    expect(tokenProvider.calls, 2);
    await datasource.desconectar();
  });
}

Map<String, dynamic> _notificationJson() => {
  'id': 'notification-1',
  'tipo': 'LEMBRETE_VIAGEM',
  'titulo': 'Lembrete',
  'mensagem': 'Mensagem',
  'criadaEm': '2026-09-02T10:30:00Z',
  'expiraEm': '2026-10-02T10:30:00Z',
  'lidaEm': null,
};

AuthToken _authToken(String value) => AuthToken(
  accessToken: value,
  refreshToken: 'refresh-$value',
  expirationDate: DateTime.utc(2026, 10, 2),
);

AuthToken _expiredAuthToken() => AuthToken(
  accessToken: 'expired-access',
  refreshToken: 'expired-refresh',
  expirationDate: DateTime.utc(2020, 10, 2),
);

class _TestSocket extends io.Socket {
  _TestSocket()
    : super(
        Manager(
          uri: 'https://api.example',
          options: {'autoConnect': false, 'reconnection': false},
        ),
        '/',
        {'autoConnect': false},
      );

  @override
  io.Socket connect() {
    connected = true;
    return this;
  }

  @override
  io.Socket disconnect() {
    connected = false;
    return this;
  }
}

class _FakeAuthTokenProvider implements AuthTokenProvider {
  final _FakeAuthLocalDatasource auth;
  int calls = 0;

  _FakeAuthTokenProvider(this.auth);

  @override
  Future<AuthToken?> obterTokenValido() async {
    calls++;
    return auth.token;
  }

  @override
  Future<AuthToken?> renovarToken(String refreshToken) async => auth.token;
}

class _FakeAuthLocalDatasource implements AuthLocalDatasource {
  AuthToken? token;

  _FakeAuthLocalDatasource({this.token});

  @override
  Future<AuthToken?> getAuthToken() async => token;

  @override
  Future<UsuarioModel?> getUsuarioPendente() async => null;

  @override
  Future<String?> getRedefinirSenhaToken() async => null;

  @override
  Future<String?> getSignUpToken() async => null;

  @override
  Future<void> limparSignUpToken() async {}

  @override
  Future<void> limparRedefinirSenhaToken() async {}

  @override
  Future<void> removerSessao() async {}

  @override
  Future<void> salvarAuthToken(AuthToken token) async {
    this.token = token;
  }

  @override
  Future<void> salvarRedefinirSenhaToken(String token) async {}

  @override
  Future<void> salvarSignUpToken(String token) async {}

  @override
  Future<void> salvarUsuario(UsuarioModel usuario) async {}

  @override
  Future<void> salvarUsuarioPendente(UsuarioModel usuario) async {}
}
