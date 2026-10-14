import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../domain/entities/notificacao.dart';
import '../../domain/entities/toque_notificacao.dart';

abstract class NotificacoesLocaisDatasource {
  Stream<ToqueNotificacao> get toques;
  Future<bool> inicializar();
  Future<bool> solicitarPermissao();
  Future<void> exibir(Notificacao notificacao);
  Future<ToqueNotificacao?> toqueInicial();
}

String codificarToque(ToqueNotificacao toque) => jsonEncode({
  'notificacaoId': ?toque.notificacaoId,
  if (toque.acao != null) 'rota': toque.acao!.rota,
  if (toque.acao != null) 'parametros': toque.acao!.parametros,
});

ToqueNotificacao? decodificarToque(String? payload) {
  if (payload == null || payload.isEmpty) return null;
  try {
    final json = jsonDecode(payload);
    if (json is! Map) return null;
    final notificacaoId = json['notificacaoId'];
    final rota = json['rota'];
    final parametros = json['parametros'];
    return ToqueNotificacao(
      notificacaoId: notificacaoId is String ? notificacaoId : null,
      acao: rota is String
          ? AcaoNotificacao(
              rota: rota,
              parametros: parametros is Map
                  ? {
                      for (final e in parametros.entries)
                        if (e.key is String && e.value is String)
                          e.key as String: e.value as String,
                    }
                  : const {},
            )
          : null,
    );
  } on FormatException {
    return null;
  }
}

class FlutterNotificacoesLocaisDatasource
    implements NotificacoesLocaisDatasource {
  static const _canalId = 'frota_notificacoes';
  static const _canalNome = 'Notificações da frota';

  final FlutterLocalNotificationsPlugin _plugin;
  final _toques = StreamController<ToqueNotificacao>.broadcast();
  Future<bool>? _inicializacao;

  FlutterNotificacoesLocaisDatasource({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  @override
  Stream<ToqueNotificacao> get toques => _toques.stream;

  @override
  Future<bool> inicializar() => _inicializacao ??= _inicializar();

  Future<bool> _inicializar() async {
    try {
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
        ),
        onDidReceiveNotificationResponse: (resposta) {
          final toque = decodificarToque(resposta.payload);
          if (toque != null) _toques.add(toque);
        },
      );
      await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(
            const AndroidNotificationChannel(
              _canalId,
              _canalNome,
              importance: Importance.high,
            ),
          );
      return true;
    } on Object catch (e) {
      debugPrint('Notificações locais indisponíveis: $e');
      return false;
    }
  }

  @override
  Future<bool> solicitarPermissao() async {
    if (!await inicializar()) return false;
    try {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (android != null) {
        return await android.requestNotificationsPermission() ?? false;
      }
      final ios = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      return await ios?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    } on Object catch (e) {
      debugPrint('Falha ao pedir permissão de notificação: $e');
      return false;
    }
  }

  @override
  Future<void> exibir(Notificacao notificacao) async {
    if (!await inicializar()) return;
    await _plugin.show(
      id: notificacao.id.hashCode & 0x7fffffff,
      title: notificacao.titulo,
      body: notificacao.mensagem,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _canalId,
          _canalNome,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBanner: true,
          presentSound: true,
        ),
      ),
      payload: codificarToque(
        ToqueNotificacao(notificacaoId: notificacao.id, acao: notificacao.acao),
      ),
    );
  }

  @override
  Future<ToqueNotificacao?> toqueInicial() async {
    if (!await inicializar()) return null;
    try {
      final detalhes = await _plugin.getNotificationAppLaunchDetails();
      if (detalhes?.didNotificationLaunchApp != true) return null;
      return decodificarToque(detalhes!.notificationResponse?.payload);
    } on Object {
      return null;
    }
  }
}
