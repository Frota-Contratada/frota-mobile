import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_exception_mapper.dart';
import '../../domain/entities/notificacao.dart';
import '../dtos/response/notificacao_response_dto.dart';
import '../dtos/response/quantidade_notificacoes_response_dto.dart';
import '../mappers/notificacoes_mapper.dart';

abstract class NotificacoesRemoteDatasource {
  Future<List<Notificacao>> buscarTodas();
  Future<int> contarNaoLidas();
  Future<Notificacao> marcarComoLida(String id);
}

class NotificacoesRemoteDatasourceImpl implements NotificacoesRemoteDatasource {
  final Dio dio;
  final String notificacoesBaseUrl;

  NotificacoesRemoteDatasourceImpl({
    required this.dio,
    required this.notificacoesBaseUrl,
  });

  @override
  Future<List<Notificacao>> buscarTodas() async {
    try {
      final response = await dio.get<Map<String, dynamic>>(notificacoesBaseUrl);
      final dynamic payload = response.data;
      if (payload is! Map) {
        throw const ServerException('Resposta de notificações inválida.');
      }

      final itens = payload['response'];
      if (itens is! List) {
        throw const ServerException('Resposta de notificações inválida.');
      }

      try {
        return itens.map((item) {
          if (item is! Map) {
            throw const FormatException('Item de notificação inválido.');
          }
          return NotificacoesMapper.toEntity(
            NotificacaoResponseDto.fromJson(Map<String, dynamic>.from(item)),
          );
        }).toList();
      } on FormatException catch (e) {
        throw ServerException(e.message);
      } on TypeError {
        throw const ServerException('Resposta de notificações inválida.');
      }
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  @override
  Future<int> contarNaoLidas() async {
    try {
      final response = await dio.get<Map<String, dynamic>>(
        '$notificacoesBaseUrl/nao-lidas/quantidade',
      );
      final dynamic payload = response.data;
      if (payload is! Map) {
        throw const ServerException('Resposta da quantidade inválida.');
      }

      try {
        return QuantidadeNotificacoesResponseDto.fromJson(
          Map<String, dynamic>.from(payload),
        ).quantidade;
      } on FormatException catch (e) {
        throw ServerException(e.message);
      } on TypeError {
        throw const ServerException('Resposta da quantidade inválida.');
      }
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  @override
  Future<Notificacao> marcarComoLida(String id) async {
    try {
      final response = await dio.patch<Map<String, dynamic>>(
        '$notificacoesBaseUrl/$id/lida',
      );
      final dynamic payload = response.data;
      if (payload is! Map) {
        throw const ServerException('Resposta do servidor sem conteúdo.');
      }
      final item = payload['response'];
      if (item is! Map) {
        throw const ServerException('Resposta do servidor sem conteúdo.');
      }

      try {
        return NotificacoesMapper.toEntity(
          NotificacaoResponseDto.fromJson(Map<String, dynamic>.from(item)),
        );
      } on FormatException catch (e) {
        throw ServerException(e.message);
      } on TypeError {
        throw const ServerException('Resposta de notificação inválida.');
      }
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }
}
