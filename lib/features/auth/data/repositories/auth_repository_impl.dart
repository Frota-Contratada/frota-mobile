import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/confirmar_pin_result.dart';
import '../../domain/entities/usuario.dart';
import '../../domain/entities/verificacao_email_result.dart';
import '../../domain/enums/plataforma.dart';
import '../../domain/enums/tipo_token.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../dtos/request/sign_up_request_dto.dart';
import '../mappers/auth_mapper.dart';
import '../models/usuario_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource remoteDatasource;
  final AuthLocalDatasource localDatasource;

  AuthRepositoryImpl({
    required this.remoteDatasource,
    required this.localDatasource,
  });

  @override
  Future<VerificacaoEmailResult> verificarEmail(String email) async {
    return _handleRemoteCall(() async {
      final result = await remoteDatasource.verificarEmail(email);
      await localDatasource.salvarUsuarioPendente(
        UsuarioModel(
          id: result.usuario.id,
          nome: result.usuario.nome,
          email: result.usuario.email,
          cpf: result.usuario.cpf,
          dataAtivacao: result.usuario.dataAtivacao,
          dataDesativacao: result.usuario.dataDesativacao,
        ),
      );
      if (result.precisaCadastroSenha) {
        await remoteDatasource.enviarPinEmail(
          AuthMapper.toEnviarPinEmailRequestDto(
            email: email,
            tipoToken: TipoToken.signUp,
          ),
        );
      }
      return result;
    });
  }

  @override
  Future<Usuario> login({
    required String email,
    required String senha,
  }) async {
    return _handleRemoteCall(() async {
      final authToken = await remoteDatasource.login(
        AuthMapper.toLoginRequestDto(
          email: email,
          senha: senha,
          plataforma: Plataforma.mobile,
        ),
      );
      await localDatasource.salvarAuthToken(authToken);

      final pendente = await localDatasource.getUsuarioPendente();
      final usuario = UsuarioModel(
        id: pendente?.id,
        nome: pendente?.nome ?? email,
        email: email,
        cpf: pendente?.cpf,
        dataAtivacao: pendente?.dataAtivacao,
        dataDesativacao: pendente?.dataDesativacao,
      );
      await localDatasource.salvarUsuario(usuario);
      return usuario;
    });
  }

  @override
  Future<void> signUp({required String senha}) async {
    final token = await localDatasource.getSignUpToken();
    if (token == null) {
      throw const CacheFailure(
        'Token de cadastro não encontrado. Confirme o PIN primeiro.',
      );
    }
    await _handleRemoteCall(
      () => remoteDatasource.signUp(SignUpRequestDto(token: token, senha: senha)),
    );
    await localDatasource.limparSignUpToken();
  }

  @override
  Future<void> redefinirSenha({required String senha}) async {
    final token = await localDatasource.getRedefinirSenhaToken();
    if (token == null) {
      throw const CacheFailure(
        'Token de redefinição não encontrado. Confirme o PIN primeiro.',
      );
    }
    await _handleRemoteCall(
      () => remoteDatasource.redefinirSenha(
        SignUpRequestDto(token: token, senha: senha),
      ),
    );
    await localDatasource.limparRedefinirSenhaToken();
  }

  @override
  Future<void> enviarPinEmail({
    required String email,
    required TipoToken tipoToken,
  }) async {
    await _handleRemoteCall(
      () => remoteDatasource.enviarPinEmail(
        AuthMapper.toEnviarPinEmailRequestDto(
          email: email,
          tipoToken: tipoToken,
        ),
      ),
    );
  }

  @override
  Future<ConfirmarPinResult> confirmarPin({
    required String email,
    required String pin,
    TipoToken tipoToken = TipoToken.signUp,
  }) async {
    return _handleRemoteCall(() async {
      final result = await remoteDatasource.confirmarPin(
        AuthMapper.toConfirmarPinRequestDto(
          pin: pin,
          email: email,
          tipoToken: tipoToken,
        ),
      );
      if (result.tipoToken == TipoToken.signUp) {
        await localDatasource.salvarSignUpToken(result.token);
      } else if (result.tipoToken == TipoToken.redefinirSenha) {
        await localDatasource.salvarRedefinirSenhaToken(result.token);
      }
      return result;
    });
  }

  @override
  Future<void> logout() async {
    try {
      await localDatasource.removerSessao();
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    }
  }

  Future<T> _handleRemoteCall<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } on CacheException catch (e) {
      throw CacheFailure(e.message);
    }
  }
}
