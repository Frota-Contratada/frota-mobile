import '../repositories/notificacoes_repository.dart';

class ContarNotificacoesNaoLidasUsecase {
  final NotificacoesRepository repository;

  ContarNotificacoesNaoLidasUsecase(this.repository);

  Future<int> call() => repository.contarNaoLidas();
}
