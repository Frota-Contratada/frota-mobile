import 'package:flutter/foundation.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import '../../domain/repositories/notificacoes_segundo_plano_repository.dart';
import '../background/notificacoes_task_handler.dart';

class NotificacoesSegundoPlanoRepositoryImpl
    implements NotificacoesSegundoPlanoRepository {
  final String notificacoesBaseUrl;
  final String authBaseUrl;

  NotificacoesSegundoPlanoRepositoryImpl({
    required this.notificacoesBaseUrl,
    required this.authBaseUrl,
  });

  bool get _suportado =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  @override
  Future<bool> iniciar() async {
    if (!_suportado) return false;
    try {
      FlutterForegroundTask.init(
        androidNotificationOptions: AndroidNotificationOptions(
          channelId: 'frota_notificacoes_conexao',
          channelName: 'Conexão das notificações',
          channelDescription:
              'Mantém o app conectado para receber avisos das viagens.',
          onlyAlertOnce: true,
        ),
        iosNotificationOptions: const IOSNotificationOptions(
          showNotification: false,
        ),
        foregroundTaskOptions: ForegroundTaskOptions(
          eventAction: ForegroundTaskEventAction.repeat(15 * 60 * 1000),
          autoRunOnBoot: true,
          autoRunOnMyPackageReplaced: true,
          allowWakeLock: true,
          allowAutoRestart: true,
          stopWithTask: false,
        ),
      );
      await FlutterForegroundTask.saveData(
        key: ChavesNotificacoesSegundoPlano.notificacoesBaseUrl,
        value: notificacoesBaseUrl,
      );
      await FlutterForegroundTask.saveData(
        key: ChavesNotificacoesSegundoPlano.authBaseUrl,
        value: authBaseUrl,
      );
      if (await FlutterForegroundTask.isRunningService) return true;

      final resultado = await FlutterForegroundTask.startService(
        serviceTypes: [ForegroundServiceTypes.remoteMessaging],
        notificationTitle: 'Frota Contratada',
        notificationText: 'Recebendo avisos das suas viagens',
        callback: iniciarNotificacoesEmSegundoPlano,
      );
      return resultado is ServiceRequestSuccess;
    } on Object catch (e) {
      debugPrint('Serviço de notificações indisponível: $e');
      return false;
    }
  }

  @override
  Future<void> parar() async {
    if (!_suportado) return;
    try {
      await FlutterForegroundTask.stopService();
    } on Object catch (e) {
      debugPrint('Falha ao parar o serviço de notificações: $e');
    }
  }

  @override
  void atualizarPushAtivo(bool ativo) {
    if (!_suportado) return;
    FlutterForegroundTask.sendDataToTask({
      ChavesNotificacoesSegundoPlano.pushAtivo: ativo,
    });
  }
}
