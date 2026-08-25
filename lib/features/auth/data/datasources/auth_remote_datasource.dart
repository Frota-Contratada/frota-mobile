import 'dart:convert';

import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_exception_mapper.dart';
import '../../domain/entities/auth_token.dart';
import '../../domain/entities/confirmar_pin_result.dart';
import '../../domain/entities/verificacao_email_result.dart';
import '../../domain/enums/perfil_usuario.dart';
import '../../domain/enums/tipo_token.dart';
import '../dtos/request/confirmar_pin_request_dto.dart';
import '../dtos/request/enviar_pin_email_request_dto.dart';
import '../dtos/request/login_request_dto.dart';
import '../dtos/request/sign_up_request_dto.dart';
import '../dtos/response/api_response_dto.dart';
import '../dtos/response/auth_token_dto.dart';
import '../dtos/response/confirmar_pin_response_dto.dart';
import '../dtos/response/verificacao_email_response_dto.dart';
import '../mappers/auth_mapper.dart';
import '../mocks/auth_mock_usuarios.dart';
import '../models/usuario_model.dart';

abstract class AuthRemoteDatasource {
  Future<VerificacaoEmailResult> verificarEmail(String email);

  Future<AuthToken> login(LoginRequestDto request);

  Future<UsuarioModel> buscarUsuarioAtual();

  Future<void> signUp(SignUpRequestDto request);

  Future<void> redefinirSenha(SignUpRequestDto request);

  Future<void> enviarPinEmail(EnviarPinEmailRequestDto request);

  Future<ConfirmarPinResult> confirmarPin(ConfirmarPinRequestDto request);
}

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final Dio dio;
  final String authBaseUrl;
  final String usuarioInfoBaseUrl;

  AuthRemoteDatasourceImpl({
    required this.dio,
    required this.authBaseUrl,
    required this.usuarioInfoBaseUrl,
  });

  @override
  Future<VerificacaoEmailResult> verificarEmail(String email) async {
    try {
      final response = await dio.get(
        '$authBaseUrl/primeiro-acesso/${Uri.encodeComponent(email)}',
      );
      final apiResponse = ApiResponseDto.fromJson(
        response.data as Map<String, dynamic>,
        VerificacaoEmailResponseDto.fromJson,
      );
      return AuthMapper.toVerificacaoEmailResult(
        dto: apiResponse.response,
        email: email,
      );
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  @override
  Future<AuthToken> login(LoginRequestDto request) async {
    try {
      final response = await dio.post(
        '$authBaseUrl/login',
        data: request.toJson(),
      );
      final apiResponse = ApiResponseDto.fromJson(
        response.data as Map<String, dynamic>,
        AuthTokenDto.fromJson,
      );
      return AuthMapper.toAuthToken(apiResponse.response);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  @override
  Future<UsuarioModel> buscarUsuarioAtual() async {
    try {
      final response = await dio.get('$usuarioInfoBaseUrl/me');
      final apiResponse = ApiResponseDto.fromJson(
        response.data as Map<String, dynamic>,
        UsuarioModel.fromJson,
      );
      return apiResponse.response;
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  @override
  Future<void> signUp(SignUpRequestDto request) async {
    try {
      await dio.post('$authBaseUrl/sign-up', data: request.toJson());
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  @override
  Future<void> redefinirSenha(SignUpRequestDto request) async {
    try {
      await dio.post('$authBaseUrl/redefinir-senha', data: request.toJson());
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  @override
  Future<void> enviarPinEmail(EnviarPinEmailRequestDto request) async {
    try {
      await dio.post('$authBaseUrl/pin/enviar', data: request.toJson());
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  @override
  Future<ConfirmarPinResult> confirmarPin(
    ConfirmarPinRequestDto request,
  ) async {
    try {
      final response = await dio.post(
        '$authBaseUrl/pin/confirmar',
        data: request.toJson(),
      );
      final apiResponse = ApiResponseDto.fromJson(
        response.data as Map<String, dynamic>,
        (json) => ConfirmarPinResponseDto.fromJson(
          json,
          tipoTokenFallback: request.tipoToken,
        ),
      );
      return AuthMapper.toConfirmarPinResult(apiResponse.response);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }
}

class AuthRemoteDatasourceFallback implements AuthRemoteDatasource {
  final AuthRemoteDatasource primary;
  final AuthRemoteDatasource mock;

  AuthRemoteDatasourceFallback({
    required this.primary,
    required this.mock,
  });

  bool _isMockUser(String email) {
    return AuthMockUsuarios.buscarPorEmail(email) != null;
  }

  Future<T> _callWithFallback<T>(
    String email,
    Future<T> Function() primaryCall,
    Future<T> Function() fallbackCall,
  ) async {
    try {
      return await primaryCall();
    } on ServerException catch (error) {
      if (!error.isNetworkError || !_isMockUser(email)) {
        rethrow;
      }
      return fallbackCall();
    }
  }

  @override
  Future<VerificacaoEmailResult> verificarEmail(String email) {
    return _callWithFallback(
      email,
      () => primary.verificarEmail(email),
      () => mock.verificarEmail(email),
    );
  }

  @override
  Future<AuthToken> login(LoginRequestDto request) {
    return _callWithFallback(
      request.email,
      () => primary.login(request),
      () => mock.login(request),
    );
  }

  @override
  Future<UsuarioModel> buscarUsuarioAtual() {
    return primary.buscarUsuarioAtual();
  }

  @override
  Future<void> signUp(SignUpRequestDto request) {
    return primary.signUp(request);
  }

  @override
  Future<void> redefinirSenha(SignUpRequestDto request) {
    return primary.redefinirSenha(request);
  }

  @override
  Future<void> enviarPinEmail(EnviarPinEmailRequestDto request) {
    return primary.enviarPinEmail(request);
  }

  @override
  Future<ConfirmarPinResult> confirmarPin(ConfirmarPinRequestDto request) {
    return primary.confirmarPin(request);
  }
}

// MOCK — substituir por [AuthRemoteDatasourceImpl] quando a API estiver pronta

class AuthRemoteDatasourceMock implements AuthRemoteDatasource {
  Future<void> _simularLatencia() async {
    await Future.delayed(const Duration(milliseconds: 600));
  }

  UsuarioModel? _buscarUsuario(String emailInformado) {
    return AuthMockUsuarios.buscarPorEmail(emailInformado);
  }

  String _criarAccessToken(UsuarioModel usuario) {
    final perfil = usuario.perfil == PerfilUsuario.passageiro
        ? 'solicitante'
        : 'motorista';
    final payload = base64Url.encode(
      utf8.encode(
        jsonEncode({
          'sub': usuario.id,
          'email': usuario.email,
          'perfis': [perfil],
        }),
      ),
    );
    return 'mock.$payload.mock';
  }

  @override
  Future<VerificacaoEmailResult> verificarEmail(String emailInformado) async {
    await _simularLatencia();

    final usuario = _buscarUsuario(emailInformado);
    if (usuario == null) {
      throw const ServerException(
        'Usuário não encontrado para o e-mail informado.',
      );
    }

    return VerificacaoEmailResult(
      usuario: usuario,
      precisaCadastroSenha: false,
    );
  }

  @override
  Future<AuthToken> login(LoginRequestDto request) async {
    await _simularLatencia();

    final usuario = _buscarUsuario(request.email);
    if (usuario == null || request.senha != AuthMockUsuarios.senha) {
      throw const ServerException('E-mail ou senha inválidos.');
    }

    return AuthToken(
      accessToken: _criarAccessToken(usuario),
      refreshToken: 'mock_refresh_token_${usuario.perfil.name}',
      expirationDate: DateTime.now().add(const Duration(hours: 8)),
    );
  }

  @override
  Future<UsuarioModel> buscarUsuarioAtual() async {
    await _simularLatencia();
    return AuthMockUsuarios.motorista;
  }

  @override
  Future<void> signUp(SignUpRequestDto request) async {
    await _simularLatencia();
  }

  @override
  Future<void> redefinirSenha(SignUpRequestDto request) async {
    await _simularLatencia();
  }

  @override
  Future<void> enviarPinEmail(EnviarPinEmailRequestDto request) async {
    await _simularLatencia();

    if (_buscarUsuario(request.email) == null) {
      throw const ServerException(
        'Usuário não encontrado para o e-mail informado.',
      );
    }
  }

  @override
  Future<ConfirmarPinResult> confirmarPin(
    ConfirmarPinRequestDto request,
  ) async {
    await _simularLatencia();

    if (_buscarUsuario(request.email) == null ||
        request.pin != AuthMockUsuarios.pin) {
      throw const ServerException('PIN inválido.');
    }

    return ConfirmarPinResult(
      token: 'mock_sign_up_token',
      tipoToken: TipoToken.fromValue(request.tipoToken),
      expirationDate: DateTime.now().add(const Duration(minutes: 30)),
    );
  }
}
