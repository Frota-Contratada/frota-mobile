import '../repositories/auth_repository.dart';

class SignUpUsecase {
  final AuthRepository repository;

  SignUpUsecase(this.repository);

  Future<void> call({required String senha}) async {
    return repository.signUp(senha: senha);
  }
}
