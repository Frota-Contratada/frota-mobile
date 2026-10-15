import '../entities/preferencias_notificacao.dart';
import '../repositories/preferencias_notificacao_repository.dart';

class AtualizarPreferenciaNotificacaoUsecase {
  final PreferenciasNotificacaoRepository repository;

  AtualizarPreferenciaNotificacaoUsecase(this.repository);

  Future<PreferenciasNotificacao> push(bool ativo) =>
      repository.atualizar(pushAtivo: ativo);

  Future<PreferenciasNotificacao> categoria(
    CategoriaNotificacao categoria,
    bool ativa,
  ) => repository.atualizar(categorias: {categoria: ativa});
}
