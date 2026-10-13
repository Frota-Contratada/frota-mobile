import '../entities/notificacao.dart';
import '../repositories/notificacoes_repository.dart';

class BuscarNotificacoesUsecase {
  final NotificacoesRepository repository;

  BuscarNotificacoesUsecase(this.repository);

  Future<List<Notificacao>> call() => repository.buscarTodas();
}
