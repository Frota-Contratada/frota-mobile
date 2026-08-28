import 'dart:convert';

import '../../domain/entities/auth_token.dart';
import '../../domain/entities/confirmar_pin_result.dart';
import '../../domain/entities/verificacao_email_result.dart';
import '../../domain/enums/plataforma.dart';
import '../../domain/enums/tipo_token.dart';
import '../dtos/request/confirmar_pin_request_dto.dart';
import '../dtos/request/enviar_pin_email_request_dto.dart';
import '../dtos/request/login_request_dto.dart';
import '../dtos/response/auth_token_dto.dart';
import '../dtos/response/confirmar_pin_response_dto.dart';
import '../dtos/response/verificacao_email_response_dto.dart';
import '../models/usuario_model.dart';

class AuthMapper {
  static LoginRequestDto toLoginRequestDto({
    required String email,
    required String senha,
    Plataforma plataforma = Plataforma.mobile,
  }) {
    return LoginRequestDto(
      email: email,
      senha: senha,
      plataforma: plataforma.value,
    );
  }

  static EnviarPinEmailRequestDto toEnviarPinEmailRequestDto({
    required String email,
    required TipoToken tipoToken,
  }) {
    return EnviarPinEmailRequestDto(email: email, tipoToken: tipoToken.value);
  }

  static ConfirmarPinRequestDto toConfirmarPinRequestDto({
    required String pin,
    required String email,
    required TipoToken tipoToken,
  }) {
    return ConfirmarPinRequestDto(
      pin: pin,
      email: email,
      tipoToken: tipoToken.value,
    );
  }

  static AuthToken toAuthToken(AuthTokenDto dto) {
    return AuthToken(
      accessToken: dto.accessToken,
      refreshToken: dto.refreshToken,
      expirationDate: dto.expirationDate,
    );
  }

  static VerificacaoEmailResult toVerificacaoEmailResult({
    required VerificacaoEmailResponseDto dto,
    required String email,
  }) {
    return VerificacaoEmailResult(
      usuario: dto.usuario ?? UsuarioModel(nome: email, email: email),
      precisaCadastroSenha: dto.precisaCadastroSenha,
    );
  }

  static ConfirmarPinResult toConfirmarPinResult(ConfirmarPinResponseDto dto) {
    return ConfirmarPinResult(
      token: dto.token,
      tipoToken: TipoToken.fromValue(dto.tipoToken),
      expirationDate: dto.expirationDate,
    );
  }

  static UsuarioModel usuarioFromAccessToken(
    AuthToken token, {
    UsuarioModel? usuarioBase,
  }) {
    final payload = _decodeJwtPayload(token.accessToken);
    final rawId = payload['sub'];
    final id = rawId is num ? rawId.toInt() : int.tryParse('$rawId');
    if (id == null) {
      throw const FormatException('Token de acesso sem identificador válido.');
    }

    final email = payload['email'] as String? ?? usuarioBase?.email ?? '';
    final perfis = payload['perfis'] is List
        ? List<dynamic>.from(payload['perfis'] as List)
        : const <dynamic>[];

    return UsuarioModel.fromJson({
      'id': id,
      'nome': usuarioBase?.nome ?? payload['nome'] as String? ?? email,
      'email': email,
      'cpf': usuarioBase?.cpf,
      'dataAtivacao': usuarioBase?.dataAtivacao?.toIso8601String(),
      'dataDesativacao': usuarioBase?.dataDesativacao?.toIso8601String(),
      'perfis': perfis,
    });
  }

  static Map<String, dynamic> _decodeJwtPayload(String token) {
    final segments = token.split('.');
    if (segments.length != 3) {
      throw const FormatException('Token de acesso inválido.');
    }

    final normalized = base64Url.normalize(segments[1]);
    final payload = utf8.decode(base64Url.decode(normalized));
    final decoded = jsonDecode(payload);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Payload do token de acesso inválido.');
    }
    return decoded;
  }
}
