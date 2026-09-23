import '../entities/usuario.dart';
import '../repositories/auth_repository.dart';

class LoginUsecase {
  final AuthRepository repository;

  LoginUsecase(this.repository);

  Future<Usuario> call({required String email, required String senha}) async {
    return repository.login(email: email, senha: senha);
  }
}
