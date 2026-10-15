import 'package:dio/dio.dart';
import '../datasources/auth_local_datasource.dart';
import '../services/auth_token_service.dart';

class AuthInterceptor extends Interceptor {
  static const _retryKey = 'auth_retry';

  final Dio dio;
  final AuthLocalDatasource localDatasource;
  final AuthTokenProvider tokenProvider;
  final String authBaseUrl;

  AuthInterceptor({
    required this.dio,
    required this.localDatasource,
    required this.tokenProvider,
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
    try {
      final tokenValido = await tokenProvider.obterTokenValido();
      if (tokenValido != null) token = tokenValido;
    } on Object {
      token ??= await localDatasource.getAuthToken();
    }

    if (token != null && token.accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer ${token.accessToken}';
    }
    handler.next(options);
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
      final refreshedToken = await tokenProvider.renovarToken(
        storedToken.refreshToken,
      );
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
}
