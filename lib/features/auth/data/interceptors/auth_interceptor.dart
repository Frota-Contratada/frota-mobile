import 'package:dio/dio.dart';
import '../../../../core/network/dio_exception_mapper.dart';
import '../../domain/entities/auth_token.dart';
import '../datasources/auth_local_datasource.dart';
import '../dtos/response/api_response_dto.dart';
import '../dtos/response/auth_token_dto.dart';
import '../mappers/auth_mapper.dart';

class AuthInterceptor extends Interceptor {
  static const _retryKey = 'auth_retry';

  final Dio dio;
  final AuthLocalDatasource localDatasource;
  final String authBaseUrl;

  Future<AuthToken?>? _refreshFuture;

  AuthInterceptor({
    required this.dio,
    required this.localDatasource,
    required this.authBaseUrl,
  });

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (_isAuthRequest(options)) {
      handler.next(options);
      return;
    }

    var token = await localDatasource.getAuthToken();
    if (token != null &&
        token.refreshToken.isNotEmpty &&
        !_accessTokenStillValid(token)) {
      try {
        final refreshedToken = await _refresh(token.refreshToken);
        if (refreshedToken != null) {
          await localDatasource.salvarAuthToken(refreshedToken);
          token = refreshedToken;
        }
      } on Object {
        // O fluxo de erro abaixo ainda poderá tratar um access token expirado.
      }
    }

    if (token != null && token.accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer ${token.accessToken}';
    }
    handler.next(options);
  }

  bool _accessTokenStillValid(AuthToken token) {
    return token.expirationDate.isAfter(
      DateTime.now().add(const Duration(seconds: 30)),
    );
  }

  bool _isAuthRequest(RequestOptions request) {
    return request.uri.path.startsWith(Uri.parse(authBaseUrl).path);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (!_shouldRefresh(err)) {
      handler.next(err);
      return;
    }

    final storedToken = await localDatasource.getAuthToken();
    if (storedToken == null || storedToken.refreshToken.isEmpty) {
      handler.next(err);
      return;
    }

    try {
      final refreshedToken = await _refresh(storedToken.refreshToken);
      if (refreshedToken == null) {
        handler.next(err);
        return;
      }

      await localDatasource.salvarAuthToken(refreshedToken);
      final requestOptions = err.requestOptions;
      requestOptions.headers['Authorization'] =
          'Bearer ${refreshedToken.accessToken}';
      requestOptions.extra[_retryKey] = true;

      final response = await dio.fetch(requestOptions);
      handler.resolve(response);
    } on Object {
      await localDatasource.removerSessao();
      handler.next(err);
    }
  }

  bool _shouldRefresh(DioException error) {
    final request = error.requestOptions;
    final statusCode = error.response?.statusCode;

    return statusCode == 401 &&
        request.extra[_retryKey] != true &&
        !_isAuthRequest(request);
  }

  Future<AuthToken?> _refresh(String refreshToken) {
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

  Future<AuthToken?> _performRefresh(String refreshToken) async {
    final refreshDio = Dio(
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
