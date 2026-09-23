import '../entities/verificacao_email_result.dart';
import '../repositories/auth_repository.dart';

class VerificarEmailUsecase {
  final AuthRepository repository;

  VerificarEmailUsecase(this.repository);

  Future<VerificacaoEmailResult> call(String email) async {
    return repository.verificarEmail(email);
  }
}
