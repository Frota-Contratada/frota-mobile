import '../entities/confirmar_pin_result.dart';
import '../enums/tipo_token.dart';
import '../repositories/auth_repository.dart';

class ConfirmarPinUsecase {
  final AuthRepository repository;

  ConfirmarPinUsecase(this.repository);

  Future<ConfirmarPinResult> call({
    required String email,
    required String pin,
    TipoToken tipoToken = TipoToken.signUp,
  }) async {
    return repository.confirmarPin(
      email: email,
      pin: pin,
      tipoToken: tipoToken,
    );
  }
}
