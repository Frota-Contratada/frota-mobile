abstract class Failure implements Exception {
  final String message;

  const Failure(this.message);

  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Erro ao comunicar com o servidor.']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message =
        'Sem conexão com a internet. Verifique sua rede e tente novamente.',
  ]);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}
