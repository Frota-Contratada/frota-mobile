class ServerException implements Exception {
  final String message;

  const ServerException([this.message = 'Erro ao comunicar com o servidor.']);

  @override
  String toString() => message;
}

class CacheException implements Exception {
  final String message;

  const CacheException(this.message);

  @override
  String toString() => message;
}
