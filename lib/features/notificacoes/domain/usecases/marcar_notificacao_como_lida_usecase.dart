import '../entities/notificacao.dart';
import '../repositories/notificacoes_repository.dart';

class MarcarNotificacaoComoLidaUsecase {
  final NotificacoesRepository repository;

  MarcarNotificacaoComoLidaUsecase(this.repository);

  Future<Notificacao> call(String id) => repository.marcarComoLida(id);
}
