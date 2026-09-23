import '../enums/tipo_token.dart';
import '../repositories/auth_repository.dart';

class EnviarPinEmailUsecase {
  final AuthRepository repository;

  EnviarPinEmailUsecase(this.repository);

  Future<void> call({
    required String email,
    required TipoToken tipoToken,
  }) async {
    return repository.enviarPinEmail(email: email, tipoToken: tipoToken);
  }
}
