import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../auth/data/datasources/auth_local_datasource.dart';
import '../../../auth/data/services/auth_token_service.dart';
import '../../domain/entities/notificacao.dart';
import '../datasources/notificacoes_locais_datasource.dart';
import '../datasources/notificacoes_socket_datasource.dart';
import '../datasources/preferencias_notificacao_remote_datasource.dart';

class ChavesNotificacoesSegundoPlano {
  static const notificacoesBaseUrl = 'notificacoes_base_url';
  static const authBaseUrl = 'auth_base_url';
  static const pushAtivo = 'pushAtivo';
}

@pragma('vm:entry-point')
void iniciarNotificacoesEmSegundoPlano() {
  FlutterForegroundTask.setTaskHandler(NotificacoesTaskHandler());
}

class NotificacoesTaskHandler extends TaskHandler {
  final Set<String> _exibidas = {};
  NotificacoesSocketDatasource? _socket;
  PreferenciasNotificacaoRemoteDatasource? _preferencias;
  AuthLocalDatasource? _authLocal;
  StreamSubscription<Notificacao>? _criadasSubscription;
  final _locais = FlutterNotificacoesLocaisDatasource();
  bool _pushAtivo = true;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    final notificacoesBaseUrl = await FlutterForegroundTask.getData<String>(
      key: ChavesNotificacoesSegundoPlano.notificacoesBaseUrl,
    );
    final authBaseUrl = await FlutterForegroundTask.getData<String>(
      key: ChavesNotificacoesSegundoPlano.authBaseUrl,
    );
    if (notificacoesBaseUrl == null || authBaseUrl == null) {
      await FlutterForegroundTask.stopService();
      return;
    }

    final authLocal = AuthLocalDatasourceImpl(
      sharedPreferences: await SharedPreferences.getInstance(),
    );
    final tokenService = AuthTokenService(
      localDatasource: authLocal,
      authBaseUrl: authBaseUrl,
    );
    if (await authLocal.getAuthToken() == null) {
      await FlutterForegroundTask.stopService();
      return;
    }

    _authLocal = authLocal;
    _preferencias = PreferenciasNotificacaoRemoteDatasourceImpl(
      dio: _criarDio(tokenService),
      notificacoesBaseUrl: notificacoesBaseUrl,
    );
    await _locais.inicializar();
    unawaited(_atualizarPreferencias());

    final socket = NotificacoesSocketDatasourceImpl(
      notificacoesBaseUrl: notificacoesBaseUrl,
      authLocalDatasource: authLocal,
      authTokenProvider: tokenService,
    );
    _socket = socket;
    _criadasSubscription = socket.notificacoesCriadas.listen(_exibir);
    await socket.conectar();
  }

  Dio _criarDio(AuthTokenProvider tokenService) {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
      ),
    );
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            final token = await tokenService.obterTokenValido();
            if (token != null && token.accessToken.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer ${token.accessToken}';
            }
          } on Object {
            final token = await _authLocal?.getAuthToken();
            if (token != null) {
              options.headers['Authorization'] = 'Bearer ${token.accessToken}';
            }
          }
          handler.next(options);
        },
      ),
    );
    return dio;
  }

  Future<void> _atualizarPreferencias() async {
    try {
      _pushAtivo = (await _preferencias!.buscar()).pushAtivo;
    } on Object catch (e) {
      debugPrint('Preferências indisponíveis em segundo plano: $e');
    }
  }

  Future<void> _exibir(Notificacao notificacao) async {
    if (!_pushAtivo || !_exibidas.add(notificacao.id)) return;
    try {
      await _locais.exibir(notificacao);
    } on Object catch (e) {
      debugPrint('Falha ao exibir notificação em segundo plano: $e');
    }
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    unawaited(_verificarSessao());
  }

  Future<void> _verificarSessao() async {
    if (await _authLocal?.getAuthToken() == null) {
      await FlutterForegroundTask.stopService();
      return;
    }
    await _atualizarPreferencias();
  }

  @override
  void onReceiveData(Object data) {
    if (data is Map && data[ChavesNotificacoesSegundoPlano.pushAtivo] is bool) {
      _pushAtivo = data[ChavesNotificacoesSegundoPlano.pushAtivo] as bool;
    }
  }

  @override
  void onNotificationPressed() {
    FlutterForegroundTask.launchApp();
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    await _criadasSubscription?.cancel();
    await _socket?.desconectar();
  }
}
