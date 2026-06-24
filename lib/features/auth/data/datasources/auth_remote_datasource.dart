import 'package:dio/dio.dart';
import '../../../../core/network/dio_exception_mapper.dart';
import '../../domain/entities/auth_token.dart';
import '../../domain/entities/confirmar_pin_result.dart';
import '../../domain/entities/verificacao_email_result.dart';
import '../dtos/request/confirmar_pin_request_dto.dart';
import '../dtos/request/enviar_pin_email_request_dto.dart';
import '../dtos/request/login_request_dto.dart';
import '../dtos/request/sign_up_request_dto.dart';
import '../dtos/response/api_response_dto.dart';
import '../dtos/response/auth_token_dto.dart';
import '../dtos/response/confirmar_pin_response_dto.dart';
import '../dtos/response/verificacao_email_response_dto.dart';
import '../mappers/auth_mapper.dart';

abstract class AuthRemoteDatasource {
  Future<VerificacaoEmailResult> verificarEmail(String email);

  Future<AuthToken> login(LoginRequestDto request);

  Future<void> signUp(SignUpRequestDto request);

  Future<void> redefinirSenha(SignUpRequestDto request);

  Future<void> enviarPinEmail(EnviarPinEmailRequestDto request);

  Future<ConfirmarPinResult> confirmarPin(ConfirmarPinRequestDto request);
}

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final Dio dio;
  final String authBaseUrl;

  AuthRemoteDatasourceImpl({
    required this.dio,
    required this.authBaseUrl,
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
