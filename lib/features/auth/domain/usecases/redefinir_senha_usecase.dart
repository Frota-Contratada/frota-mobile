import '../repositories/auth_repository.dart';

class RedefinirSenhaUsecase {
  final AuthRepository repository;

  RedefinirSenhaUsecase(this.repository);

  Future<void> call({required String senha}) async {
    return repository.redefinirSenha(senha: senha);
  }
}
