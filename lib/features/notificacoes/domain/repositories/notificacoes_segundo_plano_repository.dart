abstract class NotificacoesSegundoPlanoRepository {
  Future<bool> iniciar();
  Future<void> parar();
  void atualizarPushAtivo(bool ativo);
}
