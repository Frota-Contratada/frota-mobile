import 'package:dio/dio.dart';
import '../../../../core/network/dio_exception_mapper.dart';
import '../../domain/entities/auth_token.dart';
import '../datasources/auth_local_datasource.dart';
import '../dtos/response/api_response_dto.dart';
import '../dtos/response/auth_token_dto.dart';
import '../mappers/auth_mapper.dart';

abstract class AuthTokenProvider {
  Future<AuthToken?> obterTokenValido();
  Future<AuthToken?> renovarToken(String refreshToken);
}

class AuthTokenService implements AuthTokenProvider {
  final AuthLocalDatasource localDatasource;
  final String authBaseUrl;
  final Dio Function()? refreshDioFactory;
  Future<AuthToken?>? _refreshFuture;

  AuthTokenService({
    required this.localDatasource,
    required this.authBaseUrl,
    this.refreshDioFactory,
  });

  @override
  Future<AuthToken?> obterTokenValido() async {
    final token = await localDatasource.getAuthToken();
    if (token == null || token.accessToken.isEmpty) return token;
    if (_accessTokenStillValid(token) || token.refreshToken.isEmpty) {
      return token;
    }

    final refreshedToken = await renovarToken(token.refreshToken);
    if (refreshedToken != null) {
      await localDatasource.salvarAuthToken(refreshedToken);
      return refreshedToken;
    }
    return token;
  }

  @override
  Future<AuthToken?> renovarToken(String refreshToken) {
    final currentRefresh = _refreshFuture;
    if (currentRefresh != null) return currentRefresh;

    final future = _performRefresh(refreshToken);
    _refreshFuture = future;
    future.then<void>(
      (_) {
        if (identical(_refreshFuture, future)) {
          _refreshFuture = null;
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        if (identical(_refreshFuture, future)) {
          _refreshFuture = null;
        }
      },
    );
    return future;
  }

  bool _accessTokenStillValid(AuthToken token) {
    return token.expirationDate.isAfter(
      DateTime.now().add(const Duration(seconds: 30)),
    );
  }

  Future<AuthToken?> _performRefresh(String refreshToken) async {
    final refreshDio =
        refreshDioFactory?.call() ??
        Dio(
          BaseOptions(
            connectTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 30),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        );

    try {
      final response = await refreshDio.post(
        '$authBaseUrl/refresh',
        data: {'refreshToken': refreshToken},
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
}
