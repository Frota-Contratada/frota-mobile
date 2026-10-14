import '../entities/preferencias_notificacao.dart';
import '../repositories/preferencias_notificacao_repository.dart';

class BuscarPreferenciasNotificacaoUsecase {
  final PreferenciasNotificacaoRepository repository;

  BuscarPreferenciasNotificacaoUsecase(this.repository);

  Future<PreferenciasNotificacao> call() => repository.buscar();
}
