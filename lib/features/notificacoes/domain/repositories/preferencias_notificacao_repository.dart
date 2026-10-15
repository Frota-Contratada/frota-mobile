import '../entities/preferencias_notificacao.dart';

abstract class PreferenciasNotificacaoRepository {
  Stream<PreferenciasNotificacao> get alteracoes;
  Future<PreferenciasNotificacao> buscar();
  Future<PreferenciasNotificacao> atualizar({
    bool? pushAtivo,
    Map<CategoriaNotificacao, bool>? categorias,
  });
}
