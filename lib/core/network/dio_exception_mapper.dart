import 'dart:io';

import 'package:dio/dio.dart';
import '../error/exceptions.dart';

const semInternet =
    'Sem conexão com a internet. Verifique sua rede e tente novamente.';
const conexaoDemorou =
    'A conexão demorou mais do que o esperado. Verifique sua internet e tente novamente.';
const servidorIndisponivel =
    'Não foi possível falar com o servidor agora. Tente novamente em instantes.';

enum DioExceptionContext { geral, login }

ServerException mapDioException(
  DioException exception, {
  DioExceptionContext context = DioExceptionContext.geral,
}) {
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

  final mensagemDoServidor =
      _mensagemDoServidor(exception.response?.data) ??
      _mensagemDoServidor(exception.error);

  if (mensagemDoServidor != null) {
    return ServerException(mensagemDoServidor);
  }

  return ServerException(
    _mensagemPorStatus(exception.response?.statusCode, context: context),
  );
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
  if (data is Map) {
    for (final chave in const ['message', 'messages', 'detail']) {
      final mensagem = _mensagemLegivel(data[chave]);
      if (mensagem != null) return mensagem;
    }

    final response = data['response'];
    final mensagemDaResposta = _mensagemLegivel(response);
    if (mensagemDaResposta != null) return mensagemDaResposta;

    final erro = _mensagemLegivel(data['error']);
    if (erro != null) return erro;
  }

  return _mensagemLegivel(data);
}

String? _mensagemLegivel(dynamic valor) {
  if (valor is String) {
    final mensagem = valor.trim();
    if (mensagem.isEmpty || _mensagemTecnica(mensagem)) return null;
    return mensagem;
  }

  if (valor is List) {
    final mensagens = valor
        .map(_mensagemLegivel)
        .whereType<String>()
        .toSet()
        .toList();
    return mensagens.isEmpty ? null : mensagens.join('\n');
  }

  if (valor is Map) {
    for (final chave in const ['message', 'messages', 'detail', 'error']) {
      final mensagem = _mensagemLegivel(valor[chave]);
      if (mensagem != null) return mensagem;
    }
  }

  return null;
}

bool _mensagemTecnica(String mensagem) {
  final normalizada = mensagem.toLowerCase();
  return const {
    'not found',
    'bad request',
    'unauthorized',
    'forbidden',
    'internal server error',
    'service unavailable',
  }.contains(normalizada);
}

String _mensagemPorStatus(
  int? status, {
  DioExceptionContext context = DioExceptionContext.geral,
}) {
  if (status == null) return servidorIndisponivel;

  return switch (status) {
    400 => 'Alguns dados enviados não são válidos. Revise e tente de novo.',
    401 =>
      context == DioExceptionContext.login
          ? 'E-mail ou senha inválidos.'
          : 'Sua sessão expirou. Entre novamente para continuar.',
    403 => 'Você não tem permissão para fazer isso.',
    404 => 'Não encontramos o recurso solicitado.',
    409 =>
      'Não foi possível concluir porque o registro mudou. Tente novamente.',
    422 => 'Alguns dados enviados não são válidos. Revise e tente de novo.',
    >= 500 => servidorIndisponivel,
    _ => servidorIndisponivel,
  };
}
