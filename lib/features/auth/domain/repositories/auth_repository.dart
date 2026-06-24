import '../entities/confirmar_pin_result.dart';
import '../entities/usuario.dart';
import '../entities/verificacao_email_result.dart';
import '../enums/tipo_token.dart';

abstract class AuthRepository {
  Future<VerificacaoEmailResult> verificarEmail(String email);

  Future<Usuario> login({required String email, required String senha});

  Future<void> signUp({required String senha});

  Future<void> redefinirSenha({required String senha});

  Future<void> enviarPinEmail({
    required String email,
    required TipoToken tipoToken,
  });

  Future<ConfirmarPinResult> confirmarPin({
    required String email,
    required String pin,
    TipoToken tipoToken = TipoToken.signUp,
  });

  Future<void> logout();
}