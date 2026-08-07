class ServerException implements Exception {
  final String message;
  final bool isNetworkError;

  const ServerException([
    this.message = 'Erro ao comunicar com o servidor.',
    this.isNetworkError = false,
  ]);

  @override
  String toString() => message;
}

class CacheException implements Exception {
  final String message;

  const CacheException(this.message);

  @override
  String toString() => message;
}
