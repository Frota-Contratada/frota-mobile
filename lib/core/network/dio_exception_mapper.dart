import 'dart:io';

import 'package:dio/dio.dart';
import '../error/exceptions.dart';

const semInternet =
    'Sem conexão com a internet. Verifique sua rede e tente novamente.';
const conexaoDemorou =
    'A conexão demorou mais do que o esperado. Verifique sua internet e tente novamente.';
const servidorIndisponivel =
    'Não foi possível falar com o servidor agora. Tente novamente em instantes.';

ServerException mapDioException(DioException exception) {
  if (_ehFalhaDeConexao(exception)) {
    return const ServerException(semInternet, true);
  }

  if (_ehTimeout(exception)) {
    return const ServerException(conexaoDemorou, true);
  }

  if (exception.type == DioExceptionType.badCertificate) {
    return const ServerException(
      'Não foi possível validar a conexão segura com o servidor.',
      true,
    );
  }

  if (exception.type == DioExceptionType.cancel) {
    return const ServerException('Operação cancelada.');
  }

  final mensagemDoServidor = _mensagemDoServidor(exception.response?.data);

  if (mensagemDoServidor != null) {
    return ServerException(mensagemDoServidor);
  }

  return ServerException(_mensagemPorStatus(exception.response?.statusCode));
}

bool _ehFalhaDeConexao(DioException exception) {
  if (exception.type == DioExceptionType.connectionError) return true;

  return exception.response == null && exception.error is SocketException;
}

bool _ehTimeout(DioException exception) {
  return exception.type == DioExceptionType.connectionTimeout ||
      exception.type == DioExceptionType.sendTimeout ||
      exception.type == DioExceptionType.receiveTimeout;
}

String? _mensagemDoServidor(dynamic data) {
  if (data is! Map<String, dynamic>) return null;

  final message = data['message'];

  if (message is String && message.isNotEmpty) return message;

  if (message is List && message.isNotEmpty) {
    return message.map((item) => item.toString()).join('\n');
  }

  return null;
}

String _mensagemPorStatus(int? status) {
  if (status == null) return servidorIndisponivel;

  return switch (status) {
    400 => 'Alguns dados enviados não são válidos. Revise e tente de novo.',
    401 => 'Sua sessão expirou. Entre novamente para continuar.',
    403 => 'Você não tem permissão para fazer isso.',
    404 => 'Não encontramos o que você procurou.',
    409 => 'Essa operação conflita com o estado atual do registro.',
    422 => 'Alguns dados enviados não são válidos. Revise e tente de novo.',
    >= 500 => servidorIndisponivel,
    _ => servidorIndisponivel,
  };
}
